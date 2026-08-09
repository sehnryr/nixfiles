# Nix

- Pick formatter by this order: if flake defines `formatter` output, use `nix fmt`; otherwise default to `nixfmt-rfc-style` (`nix run nixpkgs#nixfmt-rfc-style -- .`). Exception: repo already formatted with different tool and no `formatter` output, match its existing style instead of reformatting, since `nixfmt-rfc-style`, `alejandra`, and `nixpkgs-fmt` produce incompatible output. Confirm guessed formatter with `--check` (already-formatted file exits 0) before writing.
- Run `nix flake check` only when flake defines `checks`; without them it re-evaluates standard outputs and can trigger slow builds. Prefer building specific target you changed.
- Validate change by building, not switching. NixOS: `nixos-rebuild build --flake .#<host>`. home-manager: `nix build .#homeConfigurations.<name>.activationPackage`. Successful build is validation; report build errors verbatim.
- For fast eval-only check without full build, evaluate derivation path, for example `nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`.
- Never run `switch` yourself; it mutates running system. Suggest command with `!` prefix so user runs it in session, let them decide.
