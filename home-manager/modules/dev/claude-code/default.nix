{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.claude-code;

  context7KeyFile = config.age.secrets.context7Key.path;

  render = pkgs.writeShellScript "claude-render" ''
    ${pkgs.jq}/bin/jq -c '
      .delta
      | gsub("[‘’]"; "\u0027")
      | gsub("[“”]"; "\"")
      | gsub("–"; "-")
      | {hookSpecificOutput: {hookEventName: "MessageDisplay", displayContent: .}}
    '
  '';
in
{
  config = lib.mkIf cfg.enable {
    modules.age.enable = true;
    age.secrets = {
      context7Key.file = ../../../../secrets/context7-key.age;
    };

    home.packages = [
      pkgs.rtk
      pkgs.moerae
    ];

    programs.claude-code = {
      package = pkgs.claude-code;
      mcpServers = {
        context7 = {
          command = pkgs.writeShellScript "context7-mcp" ''
            export PATH="${lib.makeBinPath [ pkgs.nodejs ]}:$PATH"
            export CONTEXT7_API_KEY="$(cat ${context7KeyFile})"
            exec ${pkgs.nodejs}/bin/npx -y @upstash/context7-mcp
          '';
          type = "stdio";
        };
      };
    };

    home.file.".claude/rules" = {
      source = config.lib.file.mkRelativeOutOfStoreSymlink ./rules;
    };

    home.file.".claude/skills" = {
      source = config.lib.file.mkRelativeOutOfStoreSymlink ./skills;
    };

    home.file.".claude/output-styles" = {
      source = config.lib.file.mkRelativeOutOfStoreSymlink ./output-styles;
    };

    home.file.".claude/settings.json" = {
      source = config.lib.file.mkRelativeOutOfStoreSymlink ./settings.json;
    };

    # Stable path for settings.json to reference instead of a hashed store path.
    home.file.".claude/hooks/render".source = render;

    programs.git.ignores = lib.mkIf config.programs.git.enable [
      "**/.claude/settings.local.json"
    ];
  };
}
