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

  context7Runner = pkgs.writeShellScriptBin "context7-mcp-runner" ''
    export PATH="${lib.makeBinPath [ nodejsPkg ]}:$PATH"
    export CONTEXT7_API_KEY="$(${pkgs.coreutils}/bin/cat ${context7ApiKeyPath})"
    exec "${nodejsPkg}/bin/npx" -y @upstash/context7-mcp
  '';

  githubRunner = pkgs.writeShellScriptBin "github-mcp-runner" ''
    export GITHUB_PERSONAL_ACCESS_TOKEN="$(${pkgs.coreutils}/bin/cat ${githubPersonalAccessTokenPath})"
    exec "${pkgs.unstable.github-mcp-server}/bin/github-mcp-server" stdio
  '';
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      context7Runner
      githubRunner
    ];

    programs.codex = {
      package = pkgs.unstable.codex;
      custom-instructions = ''
        Always use context7 when I need code generation, setup or configuration steps, or
        library/API documentation. This means you should automatically use the Context7 MCP
        tools to resolve library id and get library docs without me having to explicitly ask.

        Always use github when I need to interact with GitHub repositories, such as reading
        pull requests, issues, or fetching repository information.
      '';
      settings = {
        mcp_servers = {
          context7 = {
            command = "context7-mcp-runner";
            args = [ ];
          };
          github = {
            command = "github-mcp-runner";
            args = [ ];
          };
        };
      };
    };
  };
}
