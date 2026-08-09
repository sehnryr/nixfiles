---
name: moerae-second-memory
description: Use moerae as an out-of-context second memory to cut the tokens sent to the AI platform. Use when a session handles large artifacts (logs, dumps, API responses, file trees, transcripts, research notes), when context is filling up, when facts must survive across sessions, or when the user asks to reduce token usage / context size / cost.
---

# Moerae as a second memory

Moerae is a local memory database (`put` / `search`, no network). Move bulk
content there and keep only pointers in context:

> Large content goes to moerae. A one-line summary and a node id stay in context.
> Full content comes back only when a specific task needs it.

## Setup

`moerae search` **without `-c` creates a new empty conversation and returns
nothing**, the single most common mistake. Pin one UUID at session start and
reuse it. `-p` defaults to `default`; always pass a real project name.

```sh
CONV=$(moerae put -p "$PROJECT" "session start: <one line on what we are doing>")
```

## Offloading

Anything over ~128 tokens needs a `-m` summary. **Only the summary is
embedded and searched**; the full body is fetched on demand via `get`. Write
the summary as the question it answers ("auth service 502s caused by expired
upstream cert"), not a title ("logs"), since the summary is what gets matched.

**Omitting `-m` on over-limit content currently fails silently**: nothing
is stored, nothing is printed, and the exit status is 0. Never trim
content to fit the limit instead of passing `-m` — trimming discards the
detail the record exists to preserve, while `-m` keeps the whole body. If
a write matters, confirm it landed: `moerae stats -p "$PROJECT" | grep nodes`.

```sh
kubectl logs deploy/api --since=1h \
  | moerae put -p "$PROJECT" -c "$CONV" --stdin \
      -m "api pod logs 2026-08-06 14:00-15:00, repeated 502 from upstream auth"
```

## Retrieving

```sh
moerae search -p "$PROJECT" -c "$CONV" -n 3 "why did auth start failing"
# 0.8412  17  api pod logs 2026-08-06 14:00-15:00, repeated 502 from upstream auth
moerae get -p "$PROJECT" 17   # only if the summary isn't enough
```

Output is `score<TAB>node_id<TAB>data`; use `--json` when parsing. Keep `-n`
small (3-5): the default of 10 puts ten summaries in context per lookup.

## Persisting durable facts

`--persist` content is never evicted and is visible at project scope from
any conversation, no UUID needed. But `--project-scope` only searches
**closed** segments; a segment stays open until a later call re-enters the
same conversation (any `put`/`search` with `-c <uuid>` against it), which
closes and promotes it as a side effect. A `--persist` immediately followed
by `--project-scope` in the same process will find nothing:

```sh
CONV=$(moerae put -p "$PROJECT" --persist "deploy runbook: ./ops/deploy.sh, needs VAULT_TOKEN")
moerae search -p "$PROJECT" --project-scope "how to deploy"   # empty, segment still open
moerae put -p "$PROJECT" -c "$CONV" --persist "still here"    # re-entering closes the prior segment
moerae search -p "$PROJECT" --project-scope "how to deploy"   # now finds it
```

Verified 2026-08-07 against the moerae source (`src/conversation.rs`,
`src/storage/queries.rs`: `get_promoted_segments` filters
`WHERE promoted = 1 AND state = 'closed'`).

`~/.moerae` is a plaintext local SQLite database. Store the *location* of a
secret, never the value.

## Working loop

1. Before answering a recall-flavoured question, search moerae first instead
   of asking the user to re-paste.
2. After producing or receiving anything bulky, `put` it and keep the node
   id in the reply, not the content. Persist durable outcomes so they
   survive past this conversation.

## Relationship to moerae-error-memory

This skill is for bulk content. For failure/fix records, use the sibling
`moerae-error-memory` skill instead.
