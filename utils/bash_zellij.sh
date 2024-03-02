export ZELLIJ_CONFIG_DIR=~/dotfiles/initrc/zellij
function zm() {
   session=$(zellij ls 2>/dev/null | fzf --exit-0 --ansi) && zellij attach "${session%% *}" || echo "No sessions found."
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

