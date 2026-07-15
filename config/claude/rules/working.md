# Avoiding lazy failure modes

- Before a factual claim about how a tool, library, or upstream project behaves, open its source and cite the file. "I recall", "I believe", "typically", "usually" are red flags: replace with a verified reference or say "I do not know, let me check".
- Before proposing a workaround, ask how a known-good prior art solves the same problem. If a comparable feature exists upstream (`runNixOSTest`, an equivalent library API, a sibling module in the same repo), read it and match its approach. Divergence from prior art requires a specific reason.
- Treat "just turn the safety off" as a smell: `__noChroot`, `sandbox = relaxed`, `--no-verify`, `--force`, `--no-gpg-sign`, `NODE_TLS_REJECT_UNAUTHORIZED=0`, disabling type checks. Read the source of whatever is objecting and address the real cause.
- On user pushback, treat it as "re-verify from scratch", not "restate in different words". Re-read the source.
- After the first correction in a session, raise the verification bar on adjacent claims: each subsequent non-trivial assertion gets a citation or a "not verified" tag.

# Irreversible actions

Confirm before irreversible or outward-facing actions: commits, pushes, deleting files, rewriting history, sending to external services. Approval for one such action does not extend to the next.
