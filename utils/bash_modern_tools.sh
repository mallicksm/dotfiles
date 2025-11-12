#-------------------------------------------------------------------------------
# Note: cat ll la and lt aliases
unalias cat 2> /dev/null # blow away any previous aliases if any
function cat() {
   if command -v bat >/dev/null ; then
      command bat "$@"
   else
      command cat "$@"
   fi
}
unalias ll 2> /dev/null
source ucol.sh
function l() {
   if command -v eza >/dev/null ; then
      command eza --color=always --classify --icons --sort=Ext --group-directories-first --time-style=long-iso "$@"
   else
      command ls -Fslr --color=auto "$@"
   fi
}
function ll() {
   if command -v eza >/dev/null ; then
      command eza --long --classify --header -s modified --time-style=long-iso "$@"
   else
      command ls -Fslr --color=auto "$@"
   fi
}
function lsd() {
   if command -v eza >/dev/null ; then
      args=$@*/
      command eza --long --classify --header -s modified -d --time-style=long-iso $args
   else
      command ls -Fslr --color=auto "$@"
   fi
}
unalias la 2> /dev/null
function la() {
   if command -v eza >/dev/null ; then
      command eza --long --classify --header -s modified -a --time-style=long-iso "$@"
   else
      command ls -Fslra --color=auto "$@"
   fi
}
unalias lt 2> /dev/null
function lt() {
   if command -v eza >/dev/null ; then
      command eza --tree "$@"
   else
      command tree
   fi
}
unalias du 2> /dev/null
function du() {
   if command -v ncdu >/dev/null ; then
      command ncdu "$@"
   else
      command du -k "$@"
   fi
}
unalias df 2> /dev/null
function df() {
   if command -v pydf >/dev/null ; then
      command pydf "$@"
   else
      command df -h --total "$@"
   fi
}

