---
name: compress
description: >
  One-shot rewrite of a prose file (memory index, rule file, CLAUDE.md, notes)
  into a token-cheaper form while keeping technical substance byte-exact.
  Cuts input tokens on every future session that loads the file. Use when the
  user says "compress <path>", "shrink this memory file", "/compress", or
  asks to reduce input-token cost of a specific file. Not a chat persona; the
  House output style governs replies. Refuse for source code, config files,
  or files that encode multi-step protocols the user needs preserved verbatim.
  If the ask is "Claude ignores this rule" or "this file is bloated" rather
  than a plain token-cost request, that's the distill skill's job: it triages
  what to delete or move before this skill's rewrite ever runs.
argument-hint: "<path>"
---

# Compress

Rewrite a prose file so it costs fewer input tokens to load each session, without losing what the file is for.

## Why this saves tokens

Anthropic's tokenizer treats common English words as single tokens. Dropping filler ("the", "just", "really", "in order to") saves 1 token per drop, recurring for every session that loads the file. Caveman-compress receipts on real memory files: ~46% mean prose reduction (59.6% on their CLAUDE.md). Ponytail's `/ponytail-gain` shows the input-side savings are the durable win; output personas cost more than they save (Ponytail agentic benchmark 2026-06-18: caveman-as-persona +7% tokens, +3% cost).

## When to run

- The file is prose that loads every session: `~/.claude/rules/*.md`, `MEMORY.md` entries, `CLAUDE.md`, project notes, saved research notes.
- The user pointed at a specific path.
- The file is not source code, not YAML/TOML/JSON config, not a `SKILL.md` that encodes ordered protocols.

## When to refuse

- `.py`, `.js`, `.ts`, `.rs`, `.nix`, `.json`, `.yaml`, `.toml`, `.env`, `.lock`, `.sql`, `.sh`, `.css`, `.html`. Refuse and say why.
- A `SKILL.md` whose body is a numbered protocol (e.g. `verify`, `code-review`, `deep-research`). Published research (arXiv 2512.17920) shows compression degrades constraint compliance faster than semantic accuracy: ordered steps and formatting rules are exactly what breaks first. Offer to compress only the prose sections (rationale, examples) and leave numbered lists untouched.
- Files under version control with uncommitted changes. Run `jj status` (or `git status`) first. If dirty, tell the user and stop; user chose "no `.original.md` backup, rely on VCS".

## Method

1. Read the file end to end. Note the sections and what each is for.
2. Identify byte-exact regions and mark them mentally as read-only. See "Preserve exactly" below.
3. Compress prose regions using the rules under "Rewrite". Do not compress across a byte-exact boundary.
4. Re-read the rewritten file. Verify each preserved region matches the original character-for-character. Verify the compressed prose still says the same thing an operator would need.
5. Write the file in place via the `Write` tool. Report the before/after character count and the sections you compressed. Do not report a token count you did not measure.
6. If verification step 4 fails on any preserved region, abort without writing and report which region drifted.

## Preserve exactly (never touch)

- YAML/frontmatter blocks (` --- ` fenced).
- Fenced code blocks (```` ``` ```` and ```` ~~~ ```` in all languages).
- Indented code blocks (4-space or tab).
- Inline code (`` `...` ``).
- URLs and markdown links, including link text.
- File paths, both absolute and relative.
- CLI commands and flags.
- Environment variables (`$HOME`, `NODE_ENV`).
- Error strings, log excerpts quoted verbatim.
- Numbers, versions, dates, hashes.
- Proper nouns: project names, tool names, people, companies.
- Standard headings (`## `, `### `) exactly as-is.

## Rewrite (apply to prose only)

Drop:
- Articles: `a`, `an`, `the` when the sentence stays unambiguous.
- Filler: `just`, `really`, `basically`, `actually`, `simply`, `essentially`, `generally`.
- Pleasantries: `sure`, `certainly`, `of course`, `happy to`, `I'd recommend`, `you should`, `make sure to`, `remember to`.
- Hedging: `it might be worth`, `you could consider`, `it would be good to`, `perhaps`, `maybe`.
- Filler transitions: `however`, `furthermore`, `additionally`, `in addition`, `moreover`, `it's worth noting that`, `it's important to note that`.
- Redundant phrasing: `in order to` → `to`, `make sure to` → `ensure`, `the reason is because` → `because`, `utilize` → `use`.

Rewrite:
- Fragments are fine: "Run tests before commit." not "You should always run the tests before committing."
- Prefer the short synonym when both are common English words: `big` not `extensive`, `fix` not `implement a solution for`, `use` not `utilize`.
- Merge bullets that state the same thing twice.
- Keep one example where multiple examples show the same pattern.

Do NOT do:
- Invented abbreviations (`cfg`, `impl`, `req`, `res`, `fn`, `auth`, `deps`). The Anthropic tokenizer splits these into more tokens than the full word, and reader clarity drops. Caveman's own SKILL.md forbids them for the same reason.
- Arrows or symbol substitution (`→`, `&`) in prose. Each is its own token, saves nothing.
- Wenyan or any non-English rewrite unless the user asked. Language switch changes what the model can retrieve.
- Cross-section merging. If the original has `## Setup` and `## Usage` as separate headings, keep them separate.
- Reordering. Section order is often load-bearing.

## Verification checklist

Before writing:
- Every fenced block matches original character-for-character.
- Every inline `` `x` `` matches.
- Every URL matches.
- Every file path, CLI command, env var matches.
- Headings match (text and level).
- No sentence lost its subject or object such that meaning changes.
- No compressed sentence introduces ambiguity around cause, order, or negation.

If any check fails, revert that region to the original text and note it in the report.

## Output

After a successful write, report:

```
compressed: <path>
chars: <before> → <after> (<pct>% cut)
sections rewritten: <list>
regions preserved verbatim: <count> code blocks, <count> inline code, <count> links
```

If the user asked to run and the file is a protocol-style `SKILL.md`, refuse and explain: compression risks breaking constraint compliance in ordered steps (arXiv 2512.17920). Offer to compress only prose paragraphs, leaving numbered lists intact.

## Boundaries

- One file per invocation.
- No recursive directory walk. If the user says "compress ~/.claude/rules", ask which file first, then compress one at a time and let the user diff between passes.
- No `.original.md` backup: user chose to rely on `jj`/`git`. Bail out on a dirty working tree.
- The House output style still governs everything you write in chat. This skill only governs the file rewrite.
- `stop compress` / `normal mode` reverts.
