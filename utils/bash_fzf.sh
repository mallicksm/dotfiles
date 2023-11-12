#-------------------------------------------------------------------------------
# Note: fzf
# Configuration
# -------------
export FZF_DEFAULT_COMMAND="fd --type f --follow --exclude '.git'"
export FZF_DEFAULT_OPTS='--height 100% --layout=reverse --border=double --margin=1 --padding=1 --multi --info=inline'

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
   --height 100% 
   --preview 'bat -n --color=always {}'
   --bind 'ctrl-/:change-preview-window(down|hidden|)'
   --bind 'enter:become(vim {} < /dev/tty > /dev/tty)'
   --color header:italic
   --header 'Press CTRL-/ to toggle preview'"

export FZF_CTRL_R_OPTS="
   --preview 'echo {}' --preview-window up:3:hidden:wrap
   --bind 'ctrl-/:toggle-preview'
   --color header:italic
   --header 'Press CTRL-/ to toggle preview'"

export FZF_ALT_C_COMMAND="fd --type d . --color=never --hidden --exclude '.git'"
export FZF_ALT_C_OPTS="
   --preview 'tree -C {}'
   --bind 'ctrl-/:toggle-preview'
   --color header:italic
   --header 'Press CTRL-/ to toggle preview'"

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
