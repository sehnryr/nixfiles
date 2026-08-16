import * as fs from "node:fs";
import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

interface Diagnostic {
  line: number;
  rule: string;
  message: string;
}

interface LineRange {
  start: number;
  end: number;
}

const proseExtensions = new Set([".md", ".rst", ".txt", ".adoc"]);

const checks: Array<[string, RegExp, string]> = [
  ["typography.dash", /[—–]/u, "Use punctuation appropriate to the sentence instead of an em or en dash."],
  ["typography.curly-quote", /[‘’“”]/u, "Use straight quotation marks and apostrophes."],
  ["register.canned-transition", /\b(additionally|moreover|furthermore|it(?:'s| is) (?:important|worthwhile|worth) (?:to note|noting|mentioning))\b/i, "Remove the canned transition and state the claim directly."],
  ["register.preamble", /\b(let me (?:explain|clarify)|as you may know|certainly|sure thing|of course)\b/i, "Remove conversational preamble or interjection."],
  ["register.sign-off", /\b(i hope this helps|let me know if|happy to help|feel free to)\b/i, "Remove the canned sign-off or offer."],
  ["semantics.vague-attribution", /\b(experts|observers|critics|researchers|studies|industry reports) (?:say|argue|believe|suggest|show|indicate|have (?:said|argued|noted|shown))\b/i, "Name the source or own the claim."],
  ["rhetoric.framing", /\b(the real question is|the honest answer is|what this really means is)\b/i, "State the claim without an insight-promising frame."],
  ["rhetoric.negative-parallelism", /\bnot (?:just|only|merely)\b[^.!?\n]{0,100}\bbut\b/i, "State the positive claim directly; preserve each substantive qualification."],
  ["rhetoric.no-just-triad", /\bno\b[^.!?\n]{0,50},\s*\bno\b[^.!?\n]{0,50},\s*\bjust\b/i, "Replace the rhetorical triad with a direct claim."],
  ["content.placeholder", /\[(?:insert|add|describe|explain)\b[^\]]*\]|\b(?:details to follow|this section would cover)\b/i, "Write the content or state the concrete blocker."],
  ["register.puffery", /\b(?:stands|serves) as (?:a )?testament\b|\bplays? (?:a )?(?:vital|crucial|pivotal) role\b|\b(?:underscores?|highlights?) the importance\b|\bsets? the stage for\b/i, "Replace promotional or generic significance language with a specific claim."],
];

function lint(file: string): Diagnostic[] {
  const extension = path.extname(file).toLowerCase();
  if (!proseExtensions.has(extension)) return [];

  const lines = fs.readFileSync(file, "utf8").split(/\r?\n/);
  const diagnostics: Diagnostic[] = [];
  let inFence = false;
  let inFrontmatter = extension === ".md" && lines[0]?.trim() === "---";

  for (let index = 0; index < lines.length; index++) {
    const source = lines[index];
    if (inFrontmatter) {
      if (index > 0 && source.trim() === "---") inFrontmatter = false;
      continue;
    }
    if (extension === ".md" && /^\s*(```|~~~)/.test(source)) {
      inFence = !inFence;
      continue;
    }
    if (!source || inFence || /^\s*\|.*\|\s*$/.test(source)) continue;

    for (const [rule, pattern, message] of checks) {
      if (pattern.test(source)) diagnostics.push({ line: index + 1, rule, message });
    }
  }

  return diagnostics;
}

function changedPath(event: { toolName: string; input: unknown }): string | undefined {
  if (event.toolName !== "write" && event.toolName !== "edit") return undefined;
  const input = event.input as { path?: unknown };
  return typeof input.path === "string" ? input.path.replace(/^@/, "") : undefined;
}

function lineAt(content: string, offset: number): number {
  return content.slice(0, offset).split("\n").length;
}

function changedRanges(toolName: string, input: unknown, content: string): LineRange[] {
  if (toolName === "write") return [{ start: 1, end: content.split("\n").length }];
  if (toolName !== "edit") return [];

  const edits = (input as { edits?: Array<{ newText?: unknown }> }).edits ?? [];
  const ranges: LineRange[] = [];
  let searchFrom = 0;

  for (const edit of edits) {
    if (typeof edit.newText !== "string" || edit.newText.length === 0) continue;
    let offset = content.indexOf(edit.newText, searchFrom);
    if (offset === -1) offset = content.indexOf(edit.newText);
    if (offset === -1) continue;

    const start = lineAt(content, offset);
    ranges.push({ start, end: start + edit.newText.split("\n").length - 1 });
    searchFrom = offset + edit.newText.length;
  }

  return ranges;
}

export default function writingPolicy(pi: ExtensionAPI) {
  pi.on("tool_result", async (event, ctx) => {
    if (event.isError) return;
    const target = changedPath(event);
    if (!target) return;

    const file = path.resolve(ctx.cwd, target);
    if (!fs.existsSync(file) || !fs.statSync(file).isFile()) return;

    const content = fs.readFileSync(file, "utf8");
    const ranges = changedRanges(event.toolName, event.input, content);
    const diagnostics = lint(file).filter((item) =>
      ranges.some((range) => item.line >= range.start && item.line <= range.end),
    );
    if (diagnostics.length === 0) return;

    const report = diagnostics
      .slice(0, 10)
      .map((item) => `${target}:${item.line} ${item.rule}: ${item.message}`)
      .join("\n");
    const omitted = diagnostics.length > 10
      ? `\n${diagnostics.length - 10} additional diagnostic(s) omitted. Fix these findings, then run the check again.`
      : "";

    return {
      content: [
        ...event.content,
        {
          type: "text" as const,
          text: `Writing-policy diagnostics:\n${report}${omitted}\nFix applicable findings without changing meaning.`,
        },
      ],
    };
  });
}
