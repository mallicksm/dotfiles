# Atuin (shell history) -- all bash setup, in one place.
#
# This file is symlinked into ~/.bash_atuin.sh by `dotfiles.sh linkrc`
# (default link_map mapping: bash_atuin.sh -> $HOME/.bash_atuin.sh).
# It is sourced from the VERY LAST line of ~/.bashrc so it runs after fzf
# and the explicit Up/Down history-search-* binds.
#
# Co-conspirators:
#   - ~/dotfiles/initrc/atuin.toml    -> symlinked to ~/.config/atuin/config.toml
#   - ~/.local/share/atuin/           -> sqlite DB + encryption key (machine-local)
#
# Binding policy: WE own every binding. atuin v18.16's `init bash` would
# otherwise auto-install:
#   Up arrow -> atuin picker (clobbers history-search-backward)
#   Ctrl-R   -> atuin picker (clobbers fzf's __fzf_history__)
#   ?        -> _atuin_ai_question_mark (clobbers vi-search-again in vi-command,
#                                        and self-insert elsewhere)
# All three are disabled via `--disable-*` flags below. We then explicitly
# bind only the keys we actually want pointing at atuin (Ctrl-A).

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

# --- 3. atuin init (NO automatic key bindings) ------------------------------
# Registers preexec/precmd hooks so commands flow into the SQLite DB.
# The --disable-* flags suppress atuin's default bindings on Up arrow,
# Ctrl-R, and ?. We install our own below.
eval "$(atuin init bash --disable-up-arrow --disable-ctrl-r --disable-ai)"

# --- 4. Keybindings (the only place atuin touches the keymap) ---------------
# Final desired keymap (these are the only atuin-related keys):
#   Ctrl-A -> atuin GLOBAL picker (rich metadata, fuzzy)
#
# Everything else stays as the rest of the shell config left it:
#   Up / Down -> history-search-{backward,forward}  (from ~/.bashrc)
#   Ctrl-R    -> __fzf_history__                    (from bash_fzf.sh)
#   ?         -> bash native (vi-search-again in vi-command, self-insert elsewhere)
#
# Side effect of direct bind -x for Ctrl-A (vs atuin's two-step macro chain
# that we're no longer using): pressing Enter on a selected entry in the
# picker INSERTS the command at the prompt without auto-running it. Press
# Enter a second time to execute.
#
# Note: emacs-mode Ctrl-A was beginning-of-line; in vi-insert (set -o vi
# in ~/.bashrc) it was unused, so reclaiming it is essentially free.
bind -m vi-insert  -x '"\C-a": __atuin_history --keymap-mode=vim-insert'
bind -m vi-command -x '"\C-a": __atuin_history --keymap-mode=vim-normal'
bind -m emacs      -x '"\C-a": __atuin_history --keymap-mode=emacs'
