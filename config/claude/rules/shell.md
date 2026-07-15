# Nushell syntax detail

User's interactive shell is nushell. Any command suggested for user to run (for example with `!` prefix) must be nushell syntax:

- Command substitution: `(cmd)`, not `$(cmd)`.
- Environment: `$env.X = "..."`, not `export X=...` or `X=val cmd` prefix.
- Sequencing: `;`, not `&&` or `||`.
- No heredocs.
- Structured data: use nushell pipelines instead of external text tools. Parse with `from json` or `from yaml`, select with `get`, filter with `where`, emit with `to json`. Removes need for `jq`.

Confirm nushell syntax instead of assuming bash carries over.

# NixOS environment

User does not have `jq`, `python`, `python3`, `fd`, or `rg` installed globally; they live in per-project devShells. Claude Code puts its own `rg` on Bash tool's PATH, so Bash tool can use `rg`, but do not assume user's shell can. For genuine one-off need, run tool ephemerally with `nix run nixpkgs#<tool> -- ...`.
