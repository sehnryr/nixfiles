{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.codex;

  nodejsPkg = pkgs.nodejs_22;

  context7ApiKeyPath = config.programs.onepassword-secrets.secretPaths.context7ApiKey;
  githubPersonalAccessTokenPath =
    config.programs.onepassword-secrets.secretPaths.githubPersonalAccessToken;

  context7Runner = pkgs.writeShellScript "context7-mcp-runner" ''
    export PATH="${lib.makeBinPath [ nodejsPkg ]}:$PATH"
    export CONTEXT7_API_KEY="$(${pkgs.coreutils}/bin/cat ${context7ApiKeyPath})"
    exec "${nodejsPkg}/bin/npx" -y @upstash/context7-mcp
  '';

  githubRunner = pkgs.writeShellScript "github-mcp-runner" ''
    export GITHUB_PERSONAL_ACCESS_TOKEN="$(${pkgs.coreutils}/bin/cat ${githubPersonalAccessTokenPath})"
    exec "${pkgs.unstable.github-mcp-server}/bin/github-mcp-server" stdio
  '';
in
{
  config = lib.mkIf cfg.enable {
    programs.codex = {
      package = pkgs.codex;
      custom-instructions = ''
        You are Codex, an AI coding assistant for this repo.

        - Use the **context7 MCP** for all extended project context (searching, loading, or summarizing files beyond what is directly provided).
        - Use the **GitHub MCP** only for **read-only** access (viewing files, branches, commits, PRs, and issues); you cannot modify anything on GitHub.

        Default to:

        - `context7 MCP` for repo context
        - `GitHub MCP` for remote read-only context
      '';
      settings = {
        mcp_servers = {
          context7 = {
            command = "${context7Runner}";
            args = [ ];
          };
          github = {
            command = "${githubRunner}";
            args = [ ];
          };
        };
      };
    };
  };
}
