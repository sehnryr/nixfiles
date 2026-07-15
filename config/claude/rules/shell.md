# Nushell syntax detail

The user's interactive shell is nushell. Any command suggested for the user to run (for example with the `!` prefix) must be nushell syntax:

- Command substitution: `(cmd)`, not `$(cmd)`.
- Environment: `$env.X = "..."`, not `export X=...` or a `X=val cmd` prefix.
- Sequencing: `;`, not `&&` or `||`.
- No heredocs.
- Structured data: use nushell pipelines instead of external text tools. Parse with `from json` or `from yaml`, select with `get`, filter with `where`, emit with `to json`. This removes any need for `jq`.

Confirm nushell syntax instead of assuming bash carries over.

# NixOS environment

The user does not have `jq`, `python`, `python3`, `fd`, or `rg` installed globally; they live in per-project devShells. Claude Code puts its own `rg` on the Bash tool's PATH, so the Bash tool can use `rg`, but do not assume the user's shell can. For a genuine one-off need, run the tool ephemerally with `nix run nixpkgs#<tool> -- ...`.
