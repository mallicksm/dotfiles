#!/usr/bin/env bash
#===============================================================================
# fonts_local_install.sh -- Nerd Fonts, non-root, into ~/.local/share/fonts.
#
# Each FAMILY is the basename of a ryanoasis/nerd-fonts release asset, e.g.
# FiraCode, Hack, JetBrainsMono, Meslo, Iosevka, CascadiaCode. With no FAMILY
# the default set (FiraCode Hack) is installed. Families already present are
# skipped unless -f. The fontconfig cache is refreshed at the end.
#
# Newest release by default; pin with $FONTS_VERSION or -r.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=fonts
TOOL_DESC="Nerd Fonts patched font families"
TOOL_REPO=ryanoasis/nerd-fonts
TOOL_PIN_VAR=FONTS_VERSION
TOOL_PIN_DEFAULT=v3.2.1
TOOL_BINS=()
TOOL_NEEDS=(curl unzip)
TOOL_JOBS=(check install verify)
TOOL_ALWAYS=1                 # per-family skipping is decided inside job_install
TOOL_ARGS_NAME=FAMILY
TOOL_ENV_EXTRA="  \$FONTDIR        install dir (default: ~/.local/share/fonts)"
TOOL_USAGE_EXTRA="Families: FiraCode Hack JetBrainsMono Meslo Iosevka CascadiaCode SourceCodePro
...and any other asset basename from the nerd-fonts releases page.

  $prog -e JetBrainsMono Meslo   # install two more families
  $prog -e -f FiraCode           # re-download one that is already present
  $prog -e -- check              # a family that collides with a job name"
RECIPE_JOB_DESC[check]="list which requested families are already present"
RECIPE_JOB_DESC[install]="download and unzip each family, then refresh the font cache"
RECIPE_JOB_DESC[verify]="count the installed font files per family"

FONTDIR="${FONTDIR:-$HOME/.local/share/fonts}"
DEFAULT_FAMILIES=(FiraCode Hack)

# The positionals, or the default set when none were given.
fonts_families() {
   if (( ${#ARGS[@]} )); then printf '%s\n' "${ARGS[@]}"; else printf '%s\n' "${DEFAULT_FAMILIES[@]}"; fi
}

fonts_have() { [[ -d "$FONTDIR/$1" && -n "$(ls -A "$FONTDIR/$1" 2>/dev/null)" ]]; }

job_check() {
   local fam present=0 missing=0
   echo "    fontdir  : $FONTDIR"
   echo "    release  : $VER"
   while read -r fam; do
      if fonts_have "$fam"; then
         printf '    %-16s present (%s files)\n' "$fam" "$(ls -1 "$FONTDIR/$fam" | wc -l)"
         ((present++))
      else
         printf '    %-16s not installed\n' "$fam"
         ((missing++))
      fi
   done < <(fonts_families)
   if (( missing == 0 )); then
      record check OK "all $present requested families present"
   else
      record check WARN "$missing of $((present + missing)) families missing"
   fi
}

job_install() {
   local fam target done=0 skipped=0
   while read -r fam; do
      target="$FONTDIR/$fam"
      if fonts_have "$fam" && (( FORCE == 0 )); then
         record "$fam" OK "already present (-f to re-download)"
         ((skipped++))
         continue
      fi
      echo "    --- $fam"
      rc_rmrf "$target"
      rc_mkdir "$target"
      rc_dir "$target"
      if rc_fetch "https://github.com/$TOOL_REPO/releases/download/$VER/$fam.zip" \
         && run unzip -oq "$fam.zip" \
         && run rm -f "$fam.zip"; then
         record "$fam" OK "$target"
         ((done++))
      else
         record "$fam" FAIL "download or unzip failed (see $LOG)"
      fi
   done < <(fonts_families)

   # Without this the new fonts are on disk but invisible to every GTK/Qt app
   # and to kitty's font picker until the next login.
   if has fc-cache; then
      rc_dir /
      run fc-cache -f "$FONTDIR"
   else
      record fc-cache WARN "fc-cache not on PATH; fonts may not appear until re-login"
   fi
   record install OK "$done installed, $skipped already present"
}

job_verify() {
   if ! rc_real; then
      record verify OK "would count font files under $FONTDIR"
      return 0
   fi
   local fam n total=0
   while read -r fam; do
      n="$(find "$FONTDIR/$fam" -maxdepth 1 -type f \( -name '*.ttf' -o -name '*.otf' \) 2>/dev/null | wc -l)"
      printf '    %-16s %s font files\n' "$fam" "$n"
      total=$((total + n))
   done < <(fonts_families)
   if (( total > 0 )); then
      record verify OK "$total font files under $FONTDIR"
   else
      record verify FAIL "no font files found under $FONTDIR"
      return 1
   fi
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
