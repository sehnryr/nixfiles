{
  config,
  ...
}:
{
  config = {
    modules.age.enable = true;
    age.secrets.agentToml = {
      file = ../../../secrets/1password-agent.toml.age;
      path = "${config.xdg.configHome}/1Password/ssh/agent.toml";
    };
  };
}
