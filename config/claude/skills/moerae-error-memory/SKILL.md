---
name: moerae-error-memory
description: Use moerae to remember failures and their fixes across sessions, so past mistakes are not repeated. Use when a task fails and gets resolved (a bug, a wrong approach, a broken build, a misread API), and before attempting a task that resembles one that failed before. Distinct from moerae-second-memory, which is for offloading bulk content.
---

# Moerae as error memory

Moerae (`put` / `search`, local, no network) holds problem-to-fix pairs,
searchable by symptom before the same mistake happens again:

> Before attempting something that could fail the way a past task did, search.
> After resolving a failure, put the symptom and the fix, not the whole transcript.

Use the same project name as `moerae-second-memory` for this codebase.
Records are always `--persist`ed and searched with `--project-scope`, so no
conversation UUID is needed for a *later* search. But a segment only
becomes visible at project scope once it's closed, which does not happen
at `put` time: it happens the next time that conversation is re-entered
(any later `put`/`search` with `-c <uuid>` against it). A record written
and searched for in the same breath, with nothing in between touching its
conversation, will not be found yet. In practice this is rarely an issue,
since the record and the search that finds it happen in different
sessions; do not rely on a record being searchable in the same process
that wrote it.

## The ~128 token limit, and why a `put` can vanish

`put` only embeds content up to `max_indexable_tokens` (default **128**,
roughly 500-900 characters). Over that, it needs a `-m/--metadata`
summary — and **without one it currently fails silently: nothing is
stored, nothing is printed, and the exit status is 0.** A record that
looks written can simply not exist.

When a record would run long, **always reach for `-m` rather than
trimming the text.** Trimming throws away the detail that makes the
record worth having (the file:line that proves the cause, the exact
error string a future search will match). With `-m` the full body is
stored and fetchable via `get`; only the summary is embedded and
searched, so write the summary as the symptom you would search for:

```sh
moerae put -p "$PROJECT" --persist \
  -m "error: nix build --rebuild aborts without running the test after a failure" \
  "error: ... <the full record, however long> ... fix: ..."
```

Because the failure is silent, verify anything you cannot afford to lose.
The node count is the cheapest check:

```sh
moerae stats -p "$PROJECT" | grep nodes
```

## Recording a resolved failure

Once a failure is understood and fixed, store one record in this exact
shape, so search matches on symptom and the fix is visible in the same hit:

```sh
moerae put -p "$PROJECT" --persist \
  "error: pytest hangs on test_upload since adding httpx client \
   fix: httpx.Client() opens a real connection pool; use httpx.MockTransport \
   in the fixture instead of a bare Client()"
```

Keep symptom and fix in one string, not two `put` calls: a hit with the fix
detached from its symptom is a wasted round trip. Add `cause: <why>` inline
only when the fix isn't self-explanatory.

Do not record: still-open failures, one-off typos with no generalizable
lesson, or anything containing secrets or credentials (store where the
secret lives, never the value).

## Searching before attempting

Before work that resembles a past failure (same subsystem, same library,
same class of task), search proactively, not only when asked:

```sh
moerae search -p "$PROJECT" --project-scope -n 3 "pytest hangs httpx"
```

Search using the symptom as it presents now, not the fix. No result means
this failure hasn't been recorded yet; proceed normally.

## Superseded fixes

Moerae has no edge-invalidation: an old fix is never marked invalid when a
better one is found. If a recorded fix turns out wrong, put a new record
that says so explicitly, e.g. `fix (supersedes earlier note): ...`. Both
records will surface on search; prefer the one marked "supersedes".
