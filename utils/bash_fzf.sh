#-------------------------------------------------------------------------------
# Note: fzf
#
# Most of this file was copied verbatim from `~/.fzf/install` and lightly
# tweaked over time. Of the three keybindings fzf installs by default:
#   Ctrl+R -> history fuzzy search    (actually used; kept)
#   Ctrl+T -> file picker             (never used at Ctrl+T -- rebound to Ctrl+E below)
#   Alt+C  -> fuzzy cd                (never used -- have z, b, cd.., cd_func)
# See the "Personal rebinds" block at the bottom for the real key map.
#-------------------------------------------------------------------------------

# This file only configures interactive line editing (fzf keybindings and
# completions). Bail in non-interactive shells (rsync/scp/cron/ssh-exec) so
# the `bind` calls below don't emit "line editing not enabled" warnings.
case $- in *i*) ;; *) return 0 ;; esac

# Configuration
# -------------
# Auto-completion
# ---------------
modpath ~/.fzf/bin b
source "${HOME}/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "${HOME}/.fzf/shell/key-bindings.bash"

export FZF_DEFAULT_COMMAND="fd --type f --follow --exclude '.git'"
export FZF_DEFAULT_OPTS='--height 100% --layout=reverse --border=double --margin=1 --padding=1 --multi --inline-info'

# These FZF_CTRL_T_* vars are read by `fzf-file-widget` regardless of which
# key triggers it -- the variable name is fzf-internal, not the actual chord.
# In this config they back the Ctrl+E rebinding below.
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
   --height 100% 
   --preview 'bat -n --color=always {}'
   --bind 'ctrl-/:change-preview-window(down|hidden|)'
   --bind 'enter:become(bash -c \"vi {} < /dev/tty > /dev/tty\")'
   --color header:italic
   --header 'File explorer  |  Enter=open in nvim  |  CTRL-/=toggle preview  (<esc> to quit)'"

export FZF_CTRL_R_OPTS="
   --preview 'echo {}' --preview-window up:3:hidden:wrap
   --bind 'ctrl-/:toggle-preview'
   --color header:italic
   --header 'History search  |  Enter=paste at prompt  |  CTRL-/=toggle preview  (<esc> to quit)'"

# Alt+C / fuzzy-cd vars -- DEAD. The binding is unbound below; these vars
# were only consumed by `__fzf_cd__` which `\ec` wraps. Kept here, commented,
# so the recipe survives if I ever want to re-enable fuzzy directory jump.
# export FZF_ALT_C_COMMAND="fd --type d . --color=never --hidden --exclude '.git'"
# export FZF_ALT_C_OPTS="
#    --preview 'tree -C {}'
#    --bind 'ctrl-/:toggle-preview'
#    --color header:italic
#    --header 'Press CTRL-/ to toggle preview'"

export FZF_TMUX=1
# for more info see fzf/shell/completion.zsh
_fzf_compgen_path() {
   fd . "$1"
}
_fzf_compgen_dir() {
   fd --type d . "$1"
}

# (EXPERIMENTAL) Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
   cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
   export|unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
   ssh)          fzf "$@" --preview 'dig {}' ;;
   *)            fzf "$@" ;;
  esac
}

#-------------------------------------------------------------------------------
# Personal rebinds: replace the fzf installer's default chords with what my
# fingers actually reach for. These run AFTER the `source key-bindings.bash`
# above, so they override whatever fzf installed.
#-------------------------------------------------------------------------------

# Ctrl+E ("E for Edit") -> zz_explorer (bash_nvim.sh): fzf file picker whose
# selection opens in the REAL `vi` wrapper. Using `bind -x` to a shell function
# (not fzf's fzf-file-widget / become(bash -c "vi ...")) means the open runs in
# THIS interactive shell -- full env, aliases, and vi() split/tab logic, not a
# "canned" non-interactive nvim. Bound only in vi modes; emacs-standard keeps
# its default end-of-line so Ctrl+Z (toggle to emacs editing) still behaves.
bind -m vi-insert  -x '"\C-e": zz_explorer'
bind -m vi-command -x '"\C-e": zz_explorer'

# Ctrl+G ("G for grep") -> live ripgrep + fzf with type-filter hotkeys.
# Defined in ~/dotfiles/utils/bash_vgrep.sh (function rgrep). F1-F6 inside
# fzf swap the type filter; Enter opens the matched line in nvim.
# Note: overrides bash readline default Ctrl+G (vi: clear-pending-vi-cmd).
bind -m vi-insert  -x '"\C-g": rgrep'
bind -m vi-command -x '"\C-g": rgrep'

# Ctrl+F ("F for Find") -> fzf history widget (fuzzy text over ~/.bash_history).
# Moved off Ctrl+R because atuin owns Ctrl+R (see bash_atuin.sh). Ctrl+F's
# previous bash default was forward-char which is redundant with Right arrow.
bind -m vi-insert  -x '"\C-f": __fzf_history__'
bind -m vi-command -x '"\C-f": __fzf_history__'
bind -m emacs      -x '"\C-f": __fzf_history__'

# Drop the fzf installer's bindings I never use:
#   Ctrl+T -> file picker  (replaced by Ctrl+E above; dual binding would confuse)
#   Alt+C  -> fuzzy cd     (redundant with z, b, cd.., bash_cd_func.sh)
#
# Note: `bind -r` only removes MACRO bindings, not `-x` execute-command
# bindings, on bash 4.4 (RHEL 8). fzf installs Ctrl+T as `-x`, so a plain
# `bind -r` silently no-ops on it. Workaround: overwrite both with `-x`
# bindings that run the no-op `:` builtin. \ec needs both treatments
# because fzf installs it as a macro in vi modes and as an -x macro in
# emacs-standard.
for keymap in vi-insert vi-command emacs-standard; do
   bind -m "$keymap" -x '"\C-t": :'
   bind -m "$keymap" -x '"\ec":  :'
done
