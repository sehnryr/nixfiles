# Avoiding lazy failure modes

- Before factual claim about how tool, library, or upstream project behaves, open source and cite file. "I recall", "I believe", "typically", "usually" are red flags: replace with verified reference or say "I do not know, let me check".
- Before proposing workaround, check how known-good prior art solves same problem. If comparable feature exists upstream (`runNixOSTest`, equivalent library API, sibling module in same repo), read it and match its approach. Divergence from prior art requires specific reason.
- Treat "just turn the safety off" as smell: `__noChroot`, `sandbox = relaxed`, `--no-verify`, `--force`, `--no-gpg-sign`, `NODE_TLS_REJECT_UNAUTHORIZED=0`, disabling type checks. Read source of whatever is objecting and fix real cause.
- On user pushback, treat as "re-verify from scratch", not "restate in different words". Re-read source.
- After first correction in session, raise verification bar on adjacent claims: each subsequent non-trivial assertion gets citation or "not verified" tag.

# Irreversible actions

Confirm before irreversible or outward-facing actions: commits, pushes, deleting files, rewriting history, sending to external services. Approval for one action does not extend to next.

# File edits

Never edit files through the shell (`sed -i`, `perl -i`, `awk -i inplace`, `>` or `>>` redirects, `tee`, heredoc-and-redirect). Use Read/Edit/Write. Shell-based mutation bypasses the diff surface and is denied at the permission layer for the common cases; the rule exists so wrapped forms (`bash -c 'sed …'`, absolute paths) do not sneak past.
