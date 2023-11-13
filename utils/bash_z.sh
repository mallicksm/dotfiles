# z settings
[[ -f ~/dotfiles/initrc/z.sh ]] && source ~/dotfiles/initrc/z.sh
# configure fzf with  z
# Note: https://github.com/junegunn/fzf/wiki/Examples#integration-with-z
unalias z 2> /dev/null
z() {
  if [[ -z "$*" ]]; then
    cd "$(_z -l 2>&1 | fzf +s --tac | sed 's/^[0-9,.]* *//')"
  else
    _last_z_args="$@"
    _z "$@"
  fi
}

zz() {
  cd "$(_z -l 2>&1 | sed 's/^[0-9,.]* *//' | fzf -q "$_last_z_args")"
}
