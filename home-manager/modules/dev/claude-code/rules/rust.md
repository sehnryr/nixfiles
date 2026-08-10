---
paths: ["**/*.rs", "**/Cargo.toml", "**/Cargo.lock"]
---

# Rust

- When project uses Nix flake (flake.nix) to provide Rust toolchain, always use `cargo fmt` without `+nightly`. Toolchain channel is managed by devShell, so `cargo +nightly fmt` will fail.
