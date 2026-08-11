---
name: distill
description: >
    Triage a rules/instruction file (CLAUDE.md, rules/*.md, a SKILL.md's prose
    sections) into hook-worthy, already-default, narrowly-scoped, or globally
    load-bearing, then restructure accordingly (propose a hook, delete, move to
    a new skill file, or keep) before running lexical compression on what
    survives. Use when the user says "distill <path>", "triage this rules
    file", "this file is bloated", "Claude ignores half of it", or asks to cut
    context/attention pollution from instruction files. Distinct from /compress,
    which only shortens wording in place and does not restructure or delete.
argument-hint: "<path>"
---

# Distill

A rules file wastes attention two ways: words that carry no constraint, and rules that don't belong in an always-loaded file at all. `/compress` fixes the first. This skill fixes both, restructuring before shortening.

## Why triage before compression

- Anthropic's context-rot research (Chroma, 18 models): retrieval degrades continuously as input grows, worse mid-context than at the start, worse with near-duplicate distractors. A rule buried in a long file competes with everything around it.
- Anthropic's context-engineering guidance: aim for "the minimal set of information that fully outlines expected behavior"; minimal is not the same as short. A short but incomplete rule and a long but padded one both waste the budget.
- Skill-authoring guidance: default assumption is "Claude is already very smart." Every line should be tested against "does this justify its token cost," not just "can this be worded shorter."
- Claude Code's own best-practices doc: "bloated CLAUDE.md files cause Claude to ignore your actual instructions." Past some length, repeating or emphasizing a rule stops helping; pruning does.
- Hooks are deterministic, rules are advisory. Anything mechanically checkable costs zero context and zero attention as a hook, versus nonzero cost and probabilistic compliance as prose, every session.

## When to run

- File is prose loaded every session and suspected bloated, ignored, or over-scoped: `~/.claude/rules/*.md`, `CLAUDE.md`, a SKILL.md's rationale/example sections.
- User reports a symptom ("Claude ignores this rule," "this file feels heavy") rather than a pure token-cost ask. A pure token-cost ask with no bloat symptom is `/compress`'s job; offer that instead, or run this first and compress after.
- The user pointed at a specific path.

## When to refuse

- Same hard refusals as `compress`: source code, YAML/JSON/TOML/env config, lockfiles.
- File under version control with uncommitted changes: check `jj status` / `git status` first, stop if dirty.
- Never delete a rule, extract content to a new file, or write a hook silently. Every HOOK, DEFAULT, and SCOPED action is a proposal until the user approves it item by item.

## Method

### Phase 1: inventory

Read the file end to end. Split it into discrete rule units, roughly one bullet, one sentence, or one short paragraph per unit, each making one claim. Number them.

### Phase 2: classify each unit

- **HOOK** — mechanically checkable by a script: a forbidden command, a required post-edit step, a formatting pass. Test: could a PreToolUse/PostToolUse/Stop hook enforce this with no false positives?
- **DEFAULT** — Claude already does this unprompted. Test: would removing this line change observed behavior? If you have an actual instance from this conversation confirming the default, cite it; otherwise don't guess, downgrade to CORE.
- **SCOPED** — true and useful, but relevant only to a narrow recurring task, not most sessions that load this file. Belongs in a skill loaded on trigger, not the always-loaded file.
- **CORE** — globally load-bearing, can't be automated, applies broadly enough to justify permanent residency.

### Phase 3: restructure

- HOOK units: draft the matcher and command as a proposal. Do not write `settings.json`; hand off to the `update-config` skill or ask directly.
- DEFAULT units: mark for deletion with the reasoning (the confirming instance, or "no counterexample observed but low confidence" flagged as such).
- SCOPED units: propose a destination, an existing skill or a new one, and the trigger description that would load it. Do not create the file without confirmation.
- CORE units: rewrite at the right freedom level.
    - High-freedom (judgment call, several valid approaches): one short heuristic sentence, no enumeration.
    - Low-freedom (fragile, must-be-exact): the literal command or string, marked "run exactly this."
    - Replace an edge-case enumeration with one canonical example when the pattern is inferable from it.
    - Prefer disjoint short fragments and headers over connected prose paragraphs: non-narrative structure retrieves better than flowing prose per the context-rot findings above.

### Phase 4: lexical compression

Apply the `compress` skill's rewrite rules to the CORE survivors only: read `compress/SKILL.md` in this same skills directory for the exact "Rewrite" and "Preserve exactly" lists and follow them verbatim rather than re-deriving them here.

### Phase 5: present the plan

Before writing anything, show:

- A table: unit, classification, action.
- Counts: kept (compressed), deleted, moved to hooks, moved to skills.
- The rewritten CORE content, diff-style.
- Any proposed hook(s), verbatim.
- Any proposed new skill file(s), verbatim.

Write only after approval. Apply whichever items the user approves if they don't approve all.

## Verification

Same checklist as `compress` for anything staying in the file: no fenced block, URL, path, command, env var, or heading altered. Re-confirm every DELETE unit has no distinguishable effect on behavior seen in this conversation; if unsure, downgrade to CORE and keep it rather than delete on a guess.

## Output

After approval and write:

```
distilled: <path>
kept (compressed): <N>
deleted (already-default): <N>
moved to hooks: <N> -> <settings.json matcher(s)>
moved to skills: <N> -> <new/existing skill path(s)>
chars: <before> -> <after> in <path>
```

## Boundaries

- One source file per invocation. Multi-file moves are a byproduct of triage, not a batch mode over a directory.
- Never edit `settings.json` or create a skill file without explicit per-item confirmation.
- No `.original.md` backup: rely on `jj`/`git`, bail out on a dirty tree.
- House output style still governs chat. This skill governs the restructuring plan and file writes only.
