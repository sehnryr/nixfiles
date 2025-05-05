$env.config.show_banner = false
$env.config.buffer_editor = "/usr/bin/nvim"
$env.config.history = {
    file_format: sqlite
    max_size: 1_000_000
    sync_on_enter: true
    isolation: true
}
$env.config.ls = {
    clickable_links: false
}
$env.config.rm = {
    always_trash: true
}

$env.SSH_AUTH_SOCK = $env.XDG_RUNTIME_DIR | path join "ssh-agent.socket"

$env.PROMPT_COMMAND_RIGHT = ""

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

use std/util 'path add'
path add ($env.HOME | path join ".local/bin")
path add ($env.HOME | path join ".cargo/bin")
path add ($env.HOME | path join ".deno/bin")

alias vi = nvim
alias vim = nvim

alias zed = zeditor

use completions/cargo-completions.nu *
use completions/curl-completions.nu *
use completions/docker-completions.nu *
use completions/git-completions.nu *
use completions/less-completions.nu *
use completions/make-completions.nu *
use completions/man-completions.nu *
use completions/nix-completions.nu *
use completions/rustup-completions.nu *
use completions/ssh-completions.nu *
use completions/tar-completions.nu *
use completions/tldr-completions.nu *
use completions/uv-completions.nu *
