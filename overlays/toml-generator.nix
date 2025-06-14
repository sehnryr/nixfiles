final: prev:
let
  tomlFmt = final.pkgs.formats.toml { };
in
{
  lib = prev.lib.extend (
    f: p: {
      generators = p.generators // {
        toTOML = value: builtins.readFile (tomlFmt.generate "inline.toml" value);
      };
    }
  );
}
