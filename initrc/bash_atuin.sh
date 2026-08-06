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

# --- 0. Pin config dir (defensive) ------------------------------------------
# atuin resolves its config dir as: $ATUIN_CONFIG_DIR -> $XDG_CONFIG_HOME/atuin
# -> ~/.config/atuin, and auto-writes a default config.toml there if missing.
# Our `vi` nvim wrapper (utils/bash_nvim.sh) exports XDG_CONFIG_HOME=~/dotfiles
# for Neovim, and that leaks into ANY interactive shell spawned inside nvim
# (snacks terminal <leader>vt, :terminal, lazygit shell-outs). Without this,
# atuin would then read/create ~/dotfiles/atuin/config.toml -- a stray default
# that pollutes the dotfiles repo. Pinning ATUIN_CONFIG_DIR (highest priority,
# verified on atuin 18.16.1) makes atuin always use the real, symlinked config
# regardless of XDG_CONFIG_HOME. Exported before the interactive guard so every
# atuin invocation (init, precmd hooks, Ctrl-R) inherits it.
export ATUIN_CONFIG_DIR="$HOME/.config/atuin"

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
#   Ctrl-R -> atuin picker (rich metadata, fuzzy)
#
# Everything else stays as the rest of the shell config left it:
#   Up / Down -> history-search-{backward,forward}  (from ~/.bashrc)
#   Ctrl-F    -> __fzf_history__                    (from bash_fzf.sh)
#   Ctrl-A    -> bash default (emacs: beginning-of-line; vi modes: unbound)
#   ?         -> bash native (vi-search-again in vi-command, self-insert elsewhere)
#
# We run AFTER bash_fzf.sh (which is sourced via bash_functions.sh during
# .bashrc), so our Ctrl-R bind overwrites whatever fzf's key-bindings.bash
# installed on Ctrl-R during its init. fzf's history widget remains
# reachable via Ctrl-F (see bash_fzf.sh).
#
# Side effect of direct bind -x for atuin (vs atuin's two-step macro chain
# that we're no longer using): pressing Enter on a selected entry in the
# picker INSERTS the command at the prompt without auto-running it. Press
# Enter a second time to execute.
bind -m vi-insert  -x '"\C-r": __atuin_history --keymap-mode=vim-insert'
bind -m vi-command -x '"\C-r": __atuin_history --keymap-mode=vim-normal'
bind -m emacs      -x '"\C-r": __atuin_history --keymap-mode=emacs'
