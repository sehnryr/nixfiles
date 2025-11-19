{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.codex;

  nodejsPkg = pkgs.nodejs_22;

  context7ApiKeyPath = config.programs.onepassword-secrets.secretPaths."context7ApiKey";

  context7Runner = pkgs.writeShellScriptBin "context7-mcp-runner" ''
    export PATH="${lib.makeBinPath [ nodejsPkg ]}:$PATH"
    export CONTEXT7_API_KEY="$(${pkgs.coreutils}/bin/cat ${context7ApiKeyPath})"
    exec "${nodejsPkg}/bin/npx" -y @upstash/context7-mcp
  '';
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      context7Runner
    ];

    programs.codex = {
      package = pkgs.unstable.codex;
      custom-instructions = ''
        Always use context7 when I need code generation, setup or configuration steps, or
        library/API documentation. This means you should automatically use the Context7 MCP
        tools to resolve library id and get library docs without me having to explicitly ask.
      '';
      settings = {
        mcp_servers = {
          context7 = {
            command = "context7-mcp-runner";
            args = [ ];
          };
        };
      };
    };
  };
}
