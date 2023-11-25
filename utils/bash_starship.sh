# Starship configuration
export STARSHIP_CONFIG=$HOME/.starship.toml
export STARSHIP_LOG=error
function set_win_title(){
   # set title
   echo -ne "\033]0; [$SHLVL] $USER@$(hostname -s)  $PWD\007"
   # sync history across windows
   history -a;history -c;history -r
}
starship_precmd_user_func="set_win_title"
eval "$(starship init bash)"

