---
name: lint
description: >
  Audit a target against the full user rule set (the compact style rules plus
  the deeper rule files in ~/.claude/rules). Use when the user says "lint",
  "audit rules", "check against rules", "does this follow the rules", or when
  they want a rule-conformance pass on a diff, a reply, or a file. Reports
  concrete violations; does not rewrite. Distinct from the House output style,
  which governs replies persistently; `lint` is an on-demand deep check that
  also covers Nix, Rust, shell, vcs, and working-method rules the output style
  omits.
argument-hint: "[diff|reply|<path>]"
allowed-tools: Read(//home/youn/.claude/rules/**), Read(//home/youn/.claude/output-styles/**)
---

# Lint

On-demand audit against the full rule set. Not a persona; run it, report, stop.

## What to audit

Pick a target from the argument or infer from context:

- `diff` (default when in a git or jj repo): audit the pending changes.
  - jj repo: `jj diff` for uncommitted work; `jj diff -r @-` for the last commit.
  - git repo without jj: `git diff` for uncommitted, `git diff HEAD~1` for the last commit.
- `reply`: audit the previous assistant reply in this conversation.
- `<path>`: audit the file at that path.

If unclear, ask which one.

## Rule sources

Read every markdown file in `~/.claude/rules/` at audit time, plus `~/.claude/output-styles/house.md` for the compact style rules. Load fresh; do not cache. The current rule set:

- `nix.md`: formatter selection, `flake check` gate, build-not-switch validation, eval-only check, never run `switch`.
- `rust.md`: `cargo fmt` without `+nightly` under a flake toolchain.
- `shell.md`: nushell syntax detail, NixOS missing-CLI list.
- `vcs.md`: forge CLI structured-output convention.
- `working.md`: lazy failure modes (unverified claims, workarounds without prior-art check, "turn the safety off" smells, pushback handling, session-level verification bar), confirmation before irreversible actions.

The compact style rules (writing register, banned words, negative parallelism, working-method basics) live in the House output style (`~/.claude/output-styles/house.md`) and apply to prose. `lint` also enforces them on any target that contains prose (`reply` and `.md` files under `<path>`).

## How to run

1. Read every `~/.claude/rules/*.md`.
2. Collect the target text (run the diff command, fetch the reply, or read the file).
3. Compare rule by rule. Skip inapplicable rules (do not flag a Rust rule against a Nix diff).
4. Report only concrete violations with a pointer to the location and the specific rule broken.

## Output shape

- If no violations: `OK`, one line, nothing else.
- Otherwise, one line per violation:
  ```
  <file:line or reply-line-N> "<offending snippet>": <rule name>, <one-sentence reason>
  ```
- Group violations by rule when the same rule fires many times.
- No rewriting, no "consider ..." suggestions, no summary paragraph. The user asked for an audit, not a fix.

## Judgement calls

- Never flag text inside straight double quotes or backticks; treat it as a mention or example.
- Ignore code blocks, inline code, file paths, and command-line flags for prose-style rules.
- If unsure whether something violates a rule, do not flag it. Prefer `OK` on ambiguity.
- Weight false positives heavily: a wrongly flagged item is worse than a missed one, because the user has to sift.

## Boundaries

Does not rewrite; does not commit or push. If the user asks to fix the violations, hand back to the main loop; do not fix inside the audit.
