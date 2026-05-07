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
source $HOME/dotfiles/utils/ucol.sh
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

#-------------------------------------------------------------------------------
# psh / psm / psg: process viewers (top CPU / top memory / grep by name).
# Prefer `procs` (modern Rust ps replacement) when available, else fall back
# to GNU ps + pgrep.
#
# psh / psm default to YOUR processes only -- on shared boxes other users'
# verif simulations (Synopsys simv with 1500-char +arg lines) make the output
# unreadable. Pass `all` as the second arg to open it up to every user.
#
# Usage:
#   psh           # top 10 CPU,    you only
#   psh 25        # top 25 CPU,    you only
#   psh 25 all    # top 25 CPU,    every user on the box
#   psm  / psm 25 / psm 25 all   -- same shape but sorted by memory
#   psg <pattern> -- grep ALL users for processes matching pattern
#-------------------------------------------------------------------------------
function psh() {
   local n=${1:-10}
   local scope=${2:-self}
   if command -v procs >/dev/null ; then
      if [[ "$scope" == "all" ]]; then
         command procs --sortd cpu | head -n $((n + 1))   # +1 for header
      else
         command procs --sortd cpu "$USER" | head -n $((n + 1))
      fi
   else
      if [[ "$scope" == "all" ]]; then
         command ps -eo pid,user,pcpu,pmem,etime,cmd --sort=-pcpu | head -n $((n + 1))
      else
         command ps -u "$USER" -o pid,pcpu,pmem,etime,cmd --sort=-pcpu | head -n $((n + 1))
      fi
   fi
}

function psm() {
   local n=${1:-10}
   local scope=${2:-self}
   if command -v procs >/dev/null ; then
      if [[ "$scope" == "all" ]]; then
         command procs --sortd mem | head -n $((n + 1))
      else
         command procs --sortd mem "$USER" | head -n $((n + 1))
      fi
   else
      if [[ "$scope" == "all" ]]; then
         command ps -eo pid,user,pcpu,pmem,etime,cmd --sort=-pmem | head -n $((n + 1))
      else
         command ps -u "$USER" -o pid,pcpu,pmem,etime,cmd --sort=-pmem | head -n $((n + 1))
      fi
   fi
}

function psg() {
   if [[ -z "$1" ]]; then
      echo "usage: psg <pattern>" >&2
      return 1
   fi
   if command -v procs >/dev/null ; then
      command procs "$1"
   else
      command pgrep -af "$1"
   fi
}

