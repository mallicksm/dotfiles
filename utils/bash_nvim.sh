# shellcheck shell=bash
#-------------------------------------------------------------------------------
# vi alias -- wraps nvim with appname switching and split-on-multi-file behavior.
#
# Flags:
#   -x   wrap launch in xterm (backgrounded)
#   -p   use ~/dotfiles/nvim.pack (vim.pack-based config) instead of nvim.easy
#        (note: nvim's own -p "open in tabs" is consumed by this wrapper. To
#         force tabs explicitly, pass -p<N> e.g. -p5 -- it falls through to nvim.)
#   -O   explicit vertical split (suppresses auto split/tab behavior below)
#   anything else starting with - is forwarded verbatim to nvim
#
# Auto layout (only when user didn't pass -O or -p<N>):
#   1..3 real files on disk -> prepend -O   (vertical split)
#   4+   real files on disk -> prepend -p   (open each in its own tab)
#   0    real files         -> no layout flag added
#-------------------------------------------------------------------------------
unalias vi 2>/dev/null

vi() {
   local -A opt
   local -a args=()
   local -a extra_opts=()
   local nfiles=0
   local appname='nvim.easy'   # default config (lazy.nvim-based)

   while (( $# )); do
      case $1 in
         -x)
            opt[XTERM]='xterm -geom 110x50-100-200 -e'
            shift
         ;;
         -p)
            # -p selects nvim.pack -- the parallel config powered by nvim's
            # built-in vim.pack package manager (see ~/dotfiles/nvim.pack/).
            # Plugins/state are isolated under ~/.local/{share,state,cache}/nvim.pack/
            # so toggling between vi and `vi -p` will not touch the .easy data dir.
            appname='nvim.pack'
            shift
         ;;
         -*)
            extra_opts+=("$1")
            shift
         ;;
         *)
            args+=("$1")
            shift
         ;;
      esac
   done

   local f
   for f in "${args[@]}"; do
      [[ -f $f ]] && (( ++nfiles ))
   done

   # Detect a user-supplied layout flag so we don't double up. Bare -p is
   # consumed earlier as the appname switch; any -p<N> form falls through into
   # extra_opts and counts as an explicit tabs request.
   #   -O  vertical split          -o  horizontal split
   #   -d  diff mode (implies -O)  -p<N>  explicit tabs
   # All four suppress the auto -O / -p prepend below.
   local has_layout=0 o
   for o in "${extra_opts[@]}"; do
      [[ $o == -O || $o == -o || $o == -d || $o == -p* ]] && has_layout=1
   done

   local -a auto_layout=()
   if (( ! has_layout )); then
      if   (( nfiles >= 1 && nfiles <= 3 )); then auto_layout=(-O)
      elif (( nfiles >= 4 ));                then auto_layout=(-p)
      fi
   fi

   (
      # shellcheck disable=SC2030,SC2031
      export XDG_CONFIG_HOME=~/dotfiles/
      # shellcheck disable=SC2030,SC2031
      export NVIM_APPNAME=$appname

      # NVIM_TEST=1 suppresses ONE specific warning in defaults.lua:
      #   "Did not detect DSR response from terminal..."
      # On X-forwarded SSH the OSC 11 / DSR probe doesn't always answer in
      # the 100 ms window, the WARN-level notify fires before noice is
      # loaded, and nvim's built-in echo path then triggers a hit-enter
      # prompt on startup. Search the runtime: NVIM_TEST gates *only* this
      # single call (runtime/lua/vim/_core/defaults.lua:984), no other
      # nvim subsystem checks it -- safe to set unconditionally.
      # shellcheck disable=SC2030,SC2031
      export NVIM_TEST=1

      # COLORTERM=truecolor short-circuits the truecolor probe in
      # defaults.lua (DECRQSS round-trip), shaving another startup query
      # on the same SSH+X11 pipe. Most terminals we use already advertise
      # this; setting it explicitly is harmless on the rest.
      # shellcheck disable=SC2030,SC2031
      export COLORTERM=${COLORTERM:-truecolor}

      # (huge-file fallback removed -- snacks.bigfile in the active config now
      # disables expensive features at BufReadPre on a per-buffer basis. See
      # snacks.lua's `bigfile = { size = 10 MB }`. No need to swap NVIM_APPNAME.)

      local -a cmd
      cmd=(nvim "${auto_layout[@]}" "${extra_opts[@]}" "${args[@]}")
      printf 'Note: %s\n' "${cmd[*]}"

      if [[ -n ${opt[XTERM]:-} ]]; then
         # xterm wrapper is a single string we want word-split into argv
         # shellcheck disable=SC2086
         ${opt[XTERM]} "${cmd[@]}" &
      else
         "${cmd[@]}"
      fi
   )
}
export -f vi

#-------------------------------------------------------------------------------
# zz_explorer : fzf file picker that opens the selection in the REAL nvim
# wrapper (vi), with full interactive environment.
#
# It is bound to Ctrl-E (and, under kitty, Ctrl-3) via `bind -x` in
# bash_fzf.sh. `bind -x` runs the function in the CURRENT interactive shell,
# so `vi` resolves to the wrapper above (config/appname/env) and the tty is
# handed straight to fzf and nvim -- unlike fzf's `become(bash -c "vi ...")`,
# which spawns a fresh non-interactive shell ("canned" nvim, missing env).
#
# TAB multi-selects; the vi() wrapper then auto-splits (1-3 files) or opens
# tabs (4+). Callable by name too: `zz_explorer`.
#-------------------------------------------------------------------------------
zz_explorer() {
   local out
   local -a files
   out=$(
      FZF_DEFAULT_COMMAND="${FZF_CTRL_T_COMMAND:-fd --type f --follow --exclude .git}" \
      fzf --multi --height=100% --layout=reverse --border=double \
          --preview 'bat -n --color=always {} 2>/dev/null || cat {}' \
          --preview-window='right,60%,wrap' \
          --header 'File explorer  |  TAB=multi-select  |  Enter=open in nvim  |  esc=cancel'
   ) || return
   [[ -n $out ]] || return
   mapfile -t files <<<"$out"
   vi "${files[@]}"
}

#-------------------------------------------------------------------------------
# vim alias -- vimscript-based original nvim installation (nvim.vim)
#-------------------------------------------------------------------------------
vim() {
   local -a extra_opts=()
   local -a args=()
   while (( $# )); do
      case $1 in
         -*) extra_opts+=("$1"); shift ;;
         *)  args+=("$1");       shift ;;
      esac
   done

   (
      # shellcheck disable=SC2030,SC2031
      export XDG_CONFIG_HOME=~/dotfiles/
      # shellcheck disable=SC2030,SC2031
      export NVIM_APPNAME=nvim.vim
      # See `vi()` above for rationale -- silences the DSR hit-enter prompt
      # over X-forwarded SSH and skips the truecolor DECRQSS probe.
      # shellcheck disable=SC2030,SC2031
      export NVIM_TEST=1
      # shellcheck disable=SC2030,SC2031
      export COLORTERM=${COLORTERM:-truecolor}
      printf 'Note: nvim %s %s\n' "${extra_opts[*]}" "${args[*]}"
      nvim "${extra_opts[@]}" "${args[@]}"
   )
}
