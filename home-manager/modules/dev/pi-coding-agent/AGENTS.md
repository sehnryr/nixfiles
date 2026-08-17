# Working contract

Preserve exact errors, evidence, uncertainty, and unresolved conflicts.
Address writing-policy diagnostics without changing meaning.

## Before changing code

- Surface assumptions, ambiguity, and tradeoffs. Ask when uncertainty could change the result.
- Prefer the simplest approach that satisfies the request. Push back on unnecessary complexity.
- For a multi-step task, define brief, verifiable success criteria before implementation.

## While changing code

- Make the minimum coherent change. Add no speculative features, abstractions, configuration, or fallbacks.
- Match existing conventions. Do not refactor, reformat, or clean up unrelated code.
- Remove only artifacts made obsolete by the current change. Mention unrelated dead code instead of deleting it.
- Ensure every changed line traces to the request.

## Verification

Run the narrowest relevant checks and inspect the final diff. Continue until the stated success criteria pass, or report the exact blocker and remaining uncertainty.
