# Forge CLI detail

- Prefer `jj` over `git` for VCS.
- `gh` for GitHub, `glab` for GitLab. No forge MCP servers are configured; do not look for `mcp__github__*` or `mcp__gitlab__*` tools.
- When parsing result, use structured output: `--json` for `gh`, `-F json` or `--output json` for `glab`.
