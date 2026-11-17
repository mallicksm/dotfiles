#!/usr/bin/env bash
#===============================================================================
# pip_local_install.sh -- the Python CLI tools from requirements.txt, non-root.
#
# `pip install --user` with $PYTHONUSERBASE pointed at $PREFIX, so every
# entry-point script lands in ~/.local/bin alongside the other tools.
#
# Latest of everything by default -- edit install/requirements.txt to pin.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=pip
TOOL_DESC="the Python CLI tools listed in install/requirements.txt"
TOOL_REPO=""
TOOL_PIN_VAR=""
TOOL_BINS=()
TOOL_NEEDS=()                 # the pip probe below is the real prerequisite check
TOOL_JOBS=(check install verify)
TOOL_ALWAYS=1                 # --upgrade every time; that is the whole point
TOOL_ENV_EXTRA="  \$PIP_REQUIREMENTS  requirements file (default: install/requirements.txt)"
TOOL_USAGE_EXTRA="Pinning is done in requirements.txt, not here, so -r has no effect for pip."
RECIPE_JOB_DESC[check]="show which interpreter and requirements file would be used"
RECIPE_JOB_DESC[install]="pip install --user --upgrade -r \$PIP_REQUIREMENTS"
RECIPE_JOB_DESC[verify]="confirm the requirements resolve against what is installed"

HERE="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PIP_REQUIREMENTS="${PIP_REQUIREMENTS:-$HERE/requirements.txt}"

# Prefer python3 -m pip; fall back to pip3 / pip.
PIP=()
if has python3 && python3 -m pip --version >/dev/null 2>&1; then
   PIP=(python3 -m pip)
elif has pip3; then PIP=(pip3)
elif has pip;  then PIP=(pip)
fi

rc_resolve_version() { VER=requirements.txt; VER_SOURCE=pin; }

job_check() {
   echo "    pip      : ${PIP[*]:-<none found>}"
   echo "    requires : $PIP_REQUIREMENTS"
   echo "    user base: $PREFIX  (scripts land in $BIN)"
   if (( ${#PIP[@]} == 0 )); then
      record check FAIL "no pip found (need python3 -m pip, pip3 or pip)"
      return 1
   fi
   if [[ ! -r "$PIP_REQUIREMENTS" ]]; then
      record check FAIL "cannot read $PIP_REQUIREMENTS"
      return 1
   fi
   local n; n="$(grep -cvE '^\s*(#|$)' "$PIP_REQUIREMENTS")"
   record check OK "$n requirement lines, via ${PIP[*]}"
}

job_install() {
   rc_dir "$HERE"
   # PYTHONUSERBASE is what makes --user honour $LOCAL_PREFIX instead of
   # hardcoding ~/.local, so a redirected prefix actually works.
   run env "PYTHONUSERBASE=$PREFIX" "${PIP[@]}" install --user --upgrade -r "$PIP_REQUIREMENTS"
}

job_verify() {
   if ! rc_real; then
      record verify OK "would run pip check against $PIP_REQUIREMENTS"
      return 0
   fi
   rc_dir "$HERE"
   if run env "PYTHONUSERBASE=$PREFIX" "${PIP[@]}" check; then
      record verify OK "dependencies are consistent"
   else
      # pip check flags pre-existing conflicts elsewhere in --user site too,
      # so this must not fail the run.
      record verify WARN "pip check reported conflicts (see $LOG)"
   fi
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
