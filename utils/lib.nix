{
  defaultSystems,
}:
{
  eachDefaultSystem =
    f:
    builtins.zipAttrsWith (_: builtins.foldl' (acc: x: acc // x) { }) (
      map (
        system:
        builtins.mapAttrs (_: value: {
          ${system} = value;
        }) (f system)
      ) defaultSystems
    );
}
