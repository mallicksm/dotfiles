export ZELLIJ_CONFIG_DIR=~/dotfiles/initrc/zellij
function zm () {
   if [[ ! -z $ZELLIJ ]]; then
      echo "Attention: cannot be run from within zellij"
      return
   fi
   session=$(zellij ls 2>/dev/null | fzf --exit-0 --ansi --header 'Enter to open:') && zellij attach "${session%% *}"
}
function zr () { 
   zellij run --name "$*" -- bash -ic "$*";}
function zrf () { 
   zellij run --name "$*" --floating -- bash -ic "$*";
}
function ze () { 
   zellij edit "$*";
}
function zef () { 
   zellij edit --floating "$*";
}
function zsc () { 
   zellij action edit-scrollback;
}

