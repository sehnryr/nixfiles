let
  fileNames = builtins.attrNames (builtins.readDir ./.);
  files = builtins.map (name: ./. + ("/" + name)) fileNames;
  filterOut = file: files: builtins.filter (file': file' != file) files;
in
{
  imports = filterOut ./default.nix files;
}
