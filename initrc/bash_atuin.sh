# Atuin (shell history) -- all bash setup, in one place.
#
# This file is symlinked into ~/.bash_atuin.sh by `dotfiles.sh linkrc`
# (default link_map mapping: bash_atuin.sh -> $HOME/.bash_atuin.sh).
# It is sourced from the VERY LAST line of ~/.bashrc so it runs after
# fzf, the explicit Up/Down history-search-* binds, and anything else
# that touches readline. atuin's keybind override depends on coming last.
#
# Co-conspirators:
#   - ~/dotfiles/initrc/atuin.toml    -> symlinked to ~/.config/atuin/config.toml
#   - ~/.local/share/atuin/           -> sqlite DB + encryption key (machine-local)

# --- 1. PATH (idempotent prepend) -------------------------------------------
if [[ -d "$HOME/.atuin/bin" && ":$PATH:" != *":$HOME/.atuin/bin:"* ]]; then
   export PATH="$HOME/.atuin/bin:$PATH"
fi

# Skip everything below in non-interactive shells (script subshells, $(SETUP)
# in synth Makefiles, etc.) or if atuin isn't installed on this machine.
[[ $- != *i* ]] && return 0
command -v atuin >/dev/null 2>&1 || return 0

# --- 2. bash-preexec ---------------------------------------------------------
# atuin's preexec/precmd hooks ride on top of rcaloras/bash-preexec.
# The atuin installer drops bash-preexec.sh at ~/.bash-preexec.sh on first
# install; only source if present (graceful no-op on machines without it).
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh

# --- 3. atuin init -----------------------------------------------------------
# Registers preexec/precmd hooks (so commands flow into the SQLite DB) AND
# installs atuin's default Ctrl-R / Up / Down bindings. atuin v18 has no
# opt-out env var (no ATUIN_NOBIND or equivalent), and its include guard
# makes a second `atuin init bash` call a no-op -- so we can't "skip"
# bindings here. We just install everything, then manually override the
# keys we want pointing elsewhere (see section 4 below).
eval "$(atuin init bash)"

# --- 4. Final keybinding choreography ---------------------------------------
# After atuin init runs (above), it has bound Ctrl-R / Up / Down to its
# own widgets. We don't want all of those. Final desired keymap:
#   Up     -> history-search-backward    (vanilla bash; prefix-filtered)
#   Down   -> history-search-forward     (vanilla bash; prefix-filtered)
#   Ctrl-A -> atuin GLOBAL               (rich-metadata picker)
#   Ctrl-R -> fzf                        (fuzzy text over ~/.bash_history)
#
# Direct `bind -x` writes win over atuin's macro-chain binds in the same
# keymap, so the four `bind` calls below are the final word on each key.
#
# Inside atuin's picker, Ctrl-R cycles filter modes
# (global <-> host <-> session <-> workspace <-> directory) -- that's
# atuin's internal TUI keybind, independent of readline.
#
# Side effect of the direct bind -x for Ctrl-A (vs atuin's two-step macro
# chain): pressing Enter on a selected entry in atuin's picker will INSERT
# but not auto-execute. Press Enter a second time to run.
#
# Note: emacs-mode Ctrl-A was beginning-of-line; in vi-insert (set -o vi
# in ~/.bashrc) it was unused, so reclaiming it is essentially free.

# Up / Down: restore vanilla bash history-search-{backward,forward}. The
# explicit bashrc binds for these run BEFORE we source this file, but
# atuin's macro-chain bind clobbered them. Re-install here.
bind -m vi-insert  '"\e[A": history-search-backward'
bind -m vi-insert  '"\e[B": history-search-forward'
bind -m vi-command '"\e[A": history-search-backward'
bind -m vi-command '"\e[B": history-search-forward'
bind -m emacs      '"\e[A": history-search-backward'
bind -m emacs      '"\e[B": history-search-forward'

# Ctrl-R: restore fzf-history-widget. fzf's bind installed earlier via
# bash_fzf.sh; atuin's init clobbered it; we re-install here.
bind -m vi-insert  -x '"\C-r": __fzf_history__'
bind -m vi-command -x '"\C-r": __fzf_history__'
bind -m emacs      -x '"\C-r": __fzf_history__'

# Ctrl-A: atuin GLOBAL picker (rich metadata). The one bind we genuinely
# add on top of the bash defaults.
bind -m vi-insert  -x '"\C-a": __atuin_history --keymap-mode=vim-insert'
bind -m vi-command -x '"\C-a": __atuin_history --keymap-mode=vim-normal'
bind -m emacs      -x '"\C-a": __atuin_history --keymap-mode=emacs'
