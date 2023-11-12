fkill() {
   local pid description
   fzf_header='Select processes to kill
   TAB to select multi
   ENTER to kill
   CTRL-R to refresh
   '
   if [ "$UID" != "0" ]; then
      # For non-root users
      pid=$(ps -f -u $UID | sed 1d | fzf -m --header="$fzf_header" --bind="ctrl-r:+reload(ps -f -u $UID)" | awk '{print $2}')

   else
      # For root user
      pid=$(ps -ef | sed 1d | fzf -m --header="$fzf_header" --bind="ctrl-r:+reload(ps -ef)" | awk '{print $2}')
   fi

   if [ "x$pid" != "x" ]; then
      # Print header only once
      info "Killing selected processes:"
      header_printed=false
      for id in $pid; do
         description=$(ps -p $id -o user,pid,vsz=MEM -o comm,args=ARG)
         
         # Print header if not printed yet
         if [ "$header_printed" = false ]; then
            echo "$description"
            header_printed=true
         else
            echo "$description" | sed 1d
         fi
      done
      echo $pid | xargs kill -${1:-9}
   else
      echo "No process selected."
   fi
}
