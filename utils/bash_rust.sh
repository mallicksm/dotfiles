# Rust (rustup-managed toolchain, installed under ~/.local — no root needed)
export CARGO_HOME="$HOME/.local/cargo"
export RUSTUP_HOME="$HOME/.local/rustup"
# Idempotent prepend (modpath from bash_first) so re-sourcing ~/.bashrc doesn't
# stack duplicate entries onto PATH.
modpath "$CARGO_HOME/bin" b

