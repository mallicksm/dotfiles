function ex() {
   # Store the STDOUT of fzf in a variable
   selection=$(fd --type d --exclude '.git'| fzf --ansi --multi --height=80% --border=sharp \
--preview='tree -C {}' \
--preview-window='45%,border-sharp' \
--prompt='Dirs > ' \
--bind='del:execute(rm -ri {+})' \
--bind='ctrl-p:toggle-preview' \
--bind='ctrl-d:change-prompt(Dirs > )' \
--bind='ctrl-d:+reload(fd --type d)' \
--bind='ctrl-d:+change-preview(tree -C {})' \
--bind='ctrl-d:+refresh-preview' \
--bind='ctrl-f:change-prompt(Files > )' \
--bind='ctrl-f:+reload(fd --type f)' \
--bind='ctrl-f:+change-preview(bat -n --color=always {})' \
--bind='ctrl-f:+refresh-preview' \
--bind='ctrl-a:select-all' \
--bind='ctrl-x:deselect-all' \
--header '
CTRL-D to display directories | CTRL-F to display files
CTRL-A to select all | CTRL-x to deselect all
ENTER to edit | DEL to delete
CTRL-P to toggle preview
'
)

# Determine what to do depending on the selection
   if [ -d "$selection" ]; then
      cd "$selection" && ex || exit
   elif [[ -f "$selection" ]]; then
      eval "$EDITOR $selection"
   else
      echo "Done with ${FUNCNAME[0]}"
   fi
}
