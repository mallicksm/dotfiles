# Starship configuration
export STARSHIP_CONFIG=$HOME/.starship.toml
export STARSHIP_LOG=error
function set_win_title(){
   # set title
   echo -ne "\033]0; [$SHLVL] $USER@$(hostname -s)  $PWD\007"
   # sync history across windows
   # Append  the ``new'' history lines to the given $HISTFILE.$$ file
   history -a $HISTFILE.$$; 
   history -c; # Clear the history list of the current buffer
   for h in $(command ls $HISTFILE.[0-9]* 2>/dev/null);do
      if [[ $h =~ $HISTFILE.$$ ]]; then
         continue
      fi
      # Read the contents of the other shells history file 
      history -r $h
   done
   # Read the contents of the current shells history file 
      # and use them as the current history in this buffer
      # and give it highest precedence
   history -r $HISTFILE.$$; 
}
starship_precmd_user_func="set_win_title"
eval "$(starship init bash)"

