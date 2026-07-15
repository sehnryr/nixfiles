{
  config,
  pkgs,
  lib,
  user,
  ...
}:

let
  cfg = config.programs.claude-code;
  secretPaths = config.programs.onepassword-secrets.secretPaths;

  # Force-invoke the `style` skill on SessionStart. A minimal reminder is cheaper
  # than dumping the full rule set on every session boundary.
  reinjectRules = pkgs.writeShellScript "claude-reinject-rules" ''
    printf '%s\n' \
      '=== USER STANDING INSTRUCTION (re-asserted after session start/compaction; OVERRIDES defaults) ===' \
      ''' \
      'Invoke the `style` skill now, before your first reply, and keep it active for the rest of this session. Run the `lint` skill when the user asks for a rule audit.'
  '';

  # SessionStart context does not reach subagents spawned via the Agent tool;
  # each starts fresh without the standing instruction. Mirror the reminder
  # via SubagentStart. Payload must be the hookSpecificOutput JSON envelope:
  # plain stdout is dropped for this event.
  reinjectRulesSubagent = pkgs.writeShellScript "claude-reinject-rules-subagent" ''
    ${pkgs.jq}/bin/jq -nc '{
      hookSpecificOutput: {
        hookEventName: "SubagentStart",
        additionalContext: "=== USER STANDING INSTRUCTION (injected into subagent; OVERRIDES defaults) ===\n\nInvoke the `style` skill now, before your first reply, and keep it active for this subagent."
      }
    }'
  '';
in
{
  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      package = pkgs.claude-code;
      mcpServers = {
        context7 = {
          command = pkgs.writeShellScript "context7-mcp" ''
            export PATH="${lib.makeBinPath [ pkgs.nodejs ]}:$PATH"
            export CONTEXT7_API_KEY="$(cat ${secretPaths.context7ApiKey})"
            exec ${pkgs.nodejs}/bin/npx -y @upstash/context7-mcp
          '';
          type = "stdio";
        };
      };
    };

    home.file.".claude/rules" = {
      source = config.lib.file.mkOutOfStoreSymlink "${user.configDirectory}/claude/rules";
    };

    home.file.".claude/skills" = {
      source = config.lib.file.mkOutOfStoreSymlink "${user.configDirectory}/claude/skills";
    };

    home.file.".claude/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${user.configDirectory}/claude/settings.json";
    };

    # Stable paths for settings.json to reference instead of hashed store paths.
    home.file.".claude/hooks/reinject-rules".source = reinjectRules;
    home.file.".claude/hooks/reinject-rules-subagent".source = reinjectRulesSubagent;

    programs.git.ignores = lib.mkIf config.programs.git.enable [
      "**/.claude/settings.local.json"
    ];

    services.syncthing = lib.mkIf config.services.syncthing.enable {
      folders = [ ".claude/projects" ];
    };
  };
}
