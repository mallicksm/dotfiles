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
export LS_COLORS="*.c=31:*.h=32;;01:*.svh=32:*.sv=33;;01:*.tcl=34;;01:*.f=35:*.qel=34:*.v=33:*.tdf=36:*.cmm=37"
function l() {
   if command -v exa >/dev/null ; then
      command exa --color=always --icons --sort=Ext --group-directories-first "$@"
   else
      command ls -Fslr --color=auto "$@"
   fi
}
function ll() {
   if command -v exa >/dev/null ; then
      command exa --long --header --group -s modified "$@"
   else
      command ls -Fslr --color=auto "$@"
   fi
}
function lsd() {
   if command -v exa >/dev/null ; then
      command exa --long --header --group -s modified -D "$@"
   else
      command ls -Fslr --color=auto "$@"
   fi
}
unalias la 2> /dev/null
function la() {
   if command -v exa >/dev/null ; then
      command exa --long --header --group -s modified -a "$@"
   else
      command ls -Fslra --color=auto "$@"
   fi
}
unalias lt 2> /dev/null
function lt() {
   if command -v exa >/dev/null ; then
      command exa --tree "$@"
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

