export ZELLIJ_CONFIG_DIR=~/dotfiles/initrc/zellij
function zm() {
   session=$(zellij ls 2>/dev/null | fzf --exit-0 --ansi) && zellij attach "${session%% *}" || echo "No sessions found."
}

