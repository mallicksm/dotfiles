#!/usr/bin/env bash
#===============================================================================
# install_all.sh -- orchestrator for ~/dotfiles/install/*.
#
# Runs every local (non-root) tool installer in a sensible order: quick
# prebuilt binaries first, RPM-extracted + app-style installs next, slow
# from-source builds last, then the Python CLI tools. Each installer runs in
# its own subshell; a failure is logged and the run CONTINUES, with a PASS/FAIL
# summary at the end (exit non-zero if anything failed).
#
# Usage:
#   ./install_all.sh                 # run everything
#   ./install_all.sh --list          # list available tools (grouped)
#   ./install_all.sh rg fd starship  # run only these (match by tool/script name)
#   ./install_all.sh --group prebuilt
#   ./install_all.sh --group prebuilt,rpm
#
# Groups: prebuilt | rpm | app | source | pip
# Version control is per-tool via *_VERSION env vars (see each script); the
# default is "latest". Logs: $WORKROOT/logs/<tool>.log
#===============================================================================
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$here/lib.sh"

# group -> ordered list of scripts (relative to $here).
# NB: must NOT be named GROUPS -- that's a bash builtin array (your gid list).
declare -A TOOL_GROUPS=(
   [prebuilt]="modern_linux_tools.sh starship_local_install.sh patchelf_local_install.sh zellij_local_install.sh pandoc_local_install.sh verible_local_install.sh nvim_local_install.sh"
   [rpm]="xclip_local_install.sh w3m_local_install.sh x11apps_local_install.sh"
   [app]="kitty_local_install.sh ollama_local_install.sh magick_local_install.sh clang_local_install.sh"
   [source]="git_local_install.sh gettext_local_install.sh tmux_local_install.sh verilator_local_install.sh riscvgcc_local_install.sh"
   [pip]="pip_local_install.sh"
)
GROUP_ORDER=(prebuilt rpm app source pip)

sm_usage() { sed -n '2,30p' "$here/install_all.sh" | sed 's/^# \{0,1\}//'; }

sm_list_tools() {
   for g in "${GROUP_ORDER[@]}"; do
      printf '\n[%s]\n' "$g"
      for s in ${TOOL_GROUPS[$g]}; do printf '  %s\n' "$s"; done
   done
}

# Expand the requested selection into an ordered, de-duplicated script list.
sm_select_scripts() {
   local -a want=("$@") out=()
   if (( ${#want[@]} == 0 )); then
      for g in "${GROUP_ORDER[@]}"; do out+=(${TOOL_GROUPS[$g]}); done
   else
      local token matched s
      for g in "${GROUP_ORDER[@]}"; do
         for s in ${TOOL_GROUPS[$g]}; do
            for token in "${want[@]}"; do
               # match if token appears in the script name (rg -> modern? no):
               # match against script filename OR its tool stem.
               if [[ "$s" == *"$token"* ]]; then out+=("$s"); fi
            done
         done
      done
   fi
   # de-dup, preserve order
   local seen=() r; declare -A d=()
   for r in "${out[@]}"; do [[ -n "${d[$r]:-}" ]] || { seen+=("$r"); d[$r]=1; }; done
   printf '%s\n' "${seen[@]}"
}

sm_main() {
   local -a args=() groups=()
   while (( $# )); do
      case "$1" in
         -h|--help) sm_usage; exit 0 ;;
         --list) sm_list_tools; exit 0 ;;
         --group) IFS=',' read -ra groups <<< "$2"; shift 2 ;;
         *) args+=("$1"); shift ;;
      esac
   done

   local -a scripts=()
   if (( ${#groups[@]} )); then
      local g; for g in "${groups[@]}"; do scripts+=(${TOOL_GROUPS[$g]:-}); done
   else
      mapfile -t scripts < <(sm_select_scripts "${args[@]}")
   fi
   if (( ${#scripts[@]} == 0 )); then error "no matching installers"; exit 1; fi

   local logdir="$WORKROOT/logs"; mkdir -p "$logdir"
   local -a passed=() failed=()
   info "running ${#scripts[@]} installer(s); logs in $logdir"
   local s log
   for s in "${scripts[@]}"; do
      log="$logdir/${s%.sh}.log"
      info ">>> $s"
      if bash "$here/$s" > "$log" 2>&1; then
         completed "$s"; passed+=("$s")
      else
         error "$s FAILED (see $log)"; failed+=("$s")
      fi
   done

   echo
   info "==== summary: ${#passed[@]} passed, ${#failed[@]} failed ===="
   local p; for p in "${passed[@]}"; do completed "  $p"; done
   local f; for f in "${failed[@]}"; do error "  $f"; done
   (( ${#failed[@]} == 0 ))
}
sm_main "$@"
# vim: ts=3 sts=3 sw=3 et
