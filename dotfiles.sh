#!/usr/bin/env bash
#===============================================================================
# dotfiles.sh -- set up this Unix environment: link the dotfiles, install the tools.
#
# Two halves:
#   * LINKING  -- symlink ~/dotfiles/initrc/* into place. Owned by this file.
#   * INSTALLING -- delegated, one tool per recipe, to
#                 ~/dotfiles/install/<tool>_local_install.sh.
#
# Every installer is its own script with its own -h, version pinning and
# dry-run preview; this file only decides which ones to run. To work on a
# single tool, call its installer directly:
#     ~/dotfiles/install/starship_local_install.sh -h
#
# Created: Feb-14-2023  Author: soummya
# Spec: ~/dotfiles/install/recipe.md  (the installer engine)
#===============================================================================
# shellcheck source=utils/bash_first.sh
# bash_first.sh provides everything dotfiles.sh needs at link time: colors,
# info/warn/error/completed/print/printne, has, Pushd/Popd, download.
# Domain-specific helpers (build_from_recipe, ifont, ...) remain in
# bash_snippets.sh and are NOT needed here.
source ~/dotfiles/utils/bash_first.sh 2> /dev/null
cdir=$(dirname "$(realpath "$0")")
prog="${0##*/}"
INSTALL_DIR="$cdir/install"

#-------------------------------------------------------------------------------
# Actions
#-------------------------------------------------------------------------------
# Tools installed by `all`, in order. Each name maps to
# install/<name>_local_install.sh. Everything else in install/ is deliberately
# opt-in -- run it by name, or use install/install_all.sh for the full set.
CORE_TOOLS=(clang_format z starship zellij fzf)

# action -> one-line description, for --help. Order matters here.
ACTION_ORDER=(all linkrc install check tools)
declare -A ACTION_DESC=(
   [all]="linkrc, then install the core tools (${CORE_TOOLS[*]}) and zvim"
   [linkrc]="symlink initrc/* into \$HOME (and pick the per-OS kitty.conf)"
   [install]="install the named tools, or the core set with no names"
   [check]="report installed vs upstream version for every known tool"
   [tools]="list every installer in install/ and exit"
)

# Legacy action names kept because they are in muscle memory and in corp
# scripts: old name -> what it now does.
declare -A LEGACY_ACTIONS=(
   [getstarship]="install starship"
   [getz]="install z"
   [getfzf]="install fzf"
   [getfonts]="install fonts"
   [getnpm]="install node"
   [zellij]="install zellij"
   [clang-format]="install clang_format"
   [install_zvim]="link ~/dotfiles/utils/zvim into ~/.local/bin"
)

#-------------------------------------------------------------------------------
# usage
#-------------------------------------------------------------------------------
usage() {
   cat <<EOF
Usage: $prog [-n] [ACTION] [ARGS...]

Set up this environment: link the dotfiles, install the tools.

Actions (default: all):
$(for a in "${ACTION_ORDER[@]}"; do printf '  %-9s %s\n' "$a" "${ACTION_DESC[$a]}"; done)

Options:
  -n, --dry-run   show every change without making it (also previews installs)
  -h, --help      show this help and exit

Installing:
  Each tool is a standalone recipe in install/, with its own help, version
  pinning (-r / a \$<TOOL>_VERSION env var), job selection and dry run:

    $prog install starship zellij        # these two
    $prog install                        # the core set: ${CORE_TOOLS[*]}
    $prog -n install nvim                # preview without touching anything
    install/nvim_local_install.sh -h     # everything that one tool can do

  '$prog tools' lists them all. install/install_all.sh runs the whole set,
  including the groups too slow for a default run (from-source builds).

  Tools that take their own positional arguments (fonts) keep their legacy
  action, since '$prog install' reads every word after it as a tool name:

    $prog getfonts JetBrainsMono Meslo

Checking what is stale:
    $prog check                          # installed vs upstream, every tool

Legacy action names, still accepted:
$(for a in $(printf '%s\n' "${!LEGACY_ACTIONS[@]}" | sort); do
     printf '  %-14s -> %s\n' "$a" "${LEGACY_ACTIONS[$a]}"
  done)

Examples:
  $prog                     # the usual: link everything, install the core tools
  $prog -n                  # ...but show it first
  $prog linkrc              # re-link dotfiles only, install nothing
  $prog install nvim verible lazygit
EOF
}

die() { echo "$prog: error: $*" >&2; echo >&2; usage >&2; exit 2; }

#-------------------------------------------------------------------------------
# Option parsing
#-------------------------------------------------------------------------------
# --dry-run / -n : show every filesystem change without performing it.
# Recognized in any position; stripped before the action dispatch below.
# -h / --help is handled here too, so it works before the $corp check.
DRY_RUN=0
__df_args=()
for __df_a in "$@"; do
   case "$__df_a" in
      --dry-run|-n) DRY_RUN=1 ;;
      -h|--help)    usage; exit 0 ;;
      *) __df_args+=("$__df_a") ;;
   esac
done
set -- "${__df_args[@]+"${__df_args[@]}"}"
unset __df_args __df_a
if [[ "$DRY_RUN" == "1" ]]; then
   warn "DRY-RUN mode: no filesystem changes will be made"
fi

#-------------------------------------------------------------------------------
# Installer dispatch
#-------------------------------------------------------------------------------
# recipe <tool> [extra args...] : run install/<tool>_local_install.sh.
# The installers are dry-run by DEFAULT, so -e is what makes them act; not
# passing it is exactly this script's --dry-run. One switch, two scripts, no
# second notion of "pretend".
function recipe() {
   local tool="$1"; shift
   local script="$INSTALL_DIR/${tool}_local_install.sh"
   if [[ ! -x "$script" ]]; then
      error "no installer for '$tool' ($script)"
      return 1
   fi
   local args=()
   [[ "$DRY_RUN" == "1" ]] || args+=(-e)
   info "$tool"
   "$script" "${args[@]+"${args[@]}"}" "$@"
}

# install_tools [tool...] : the named tools, or the core set.
# Deliberately NOT named `install` -- that would shadow /usr/bin/install for
# everything sourced after it, including ~/corp/dotfiles.sh.
function install_tools() {
   local tools=("$@")
   (( ${#tools[@]} )) || tools=("${CORE_TOOLS[@]}")
   local t rc=0
   for t in "${tools[@]}"; do
      recipe "$t" || rc=1
   done
   return "$rc"
}

# check_tools : read-only version report across everything install/ knows about.
function check_tools() {
   "$INSTALL_DIR/install_all.sh" -a -j check
}

# list_tools : what can be installed.
function list_tools() {
   "$INSTALL_DIR/install_all.sh" --list
}

#-------------------------------------------------------------------------------
# linkrc -link dotfiles
function linkrc() {
   linkup ~/corp/corp_settings.sh ~/corp_settings.sh

   declare -A link_map=(
      ["alacritty.toml"]="$HOME/.config/alacritty/alacritty.toml"
      ["atuin.toml"]="$HOME/.config/atuin/config.toml"
      ["bash_atuin.sh"]="$HOME/.bash_atuin.sh"
      ["kitty"]="$HOME/.config/kitty"
      ["git"]="$HOME/.config/git"
      ["config.ssh"]="$HOME/.ssh/config"
      ["cc"]="$HOME/.local/bin/c99/cc"
      ["z.sh"]="/dev/null"
      ["zellij"]="/dev/null"
   )

   for path in "$cdir"/initrc/*; do
      dotfile=${path##*/}
      dest="${link_map[$dotfile]:-$HOME/.$dotfile}"
      info "Linking $dotfile → $dest"
      linkup "$path" "$dest"
   done

   link_kitty_os
}

#-------------------------------------------------------------------------------
# link_kitty_os - per-OS kitty.conf overrides ("ifdef mac vs linux")
# Picks kitty.<darwin|linux>.conf based on `uname` and exposes it as
# kitty.os.conf inside the kitty config dir, where kitty.conf
# globincludes it. The symlink is per-machine and gitignored, so the
# repo stays OS-agnostic.
function link_kitty_os() {
   local kitty_dir="$cdir/initrc/kitty"
   local os src target curr
   case "$(uname -s)" in
      Darwin) os="darwin" ;;
      Linux)  os="linux"  ;;
      *)      warn "unknown OS $(uname -s); skipping kitty.os.conf"; return ;;
   esac
   src="kitty.${os}.conf"
   target="$kitty_dir/kitty.os.conf"
   if [[ ! -f "$kitty_dir/$src" ]]; then
      warn "$kitty_dir/$src not found; skipping kitty.os.conf"
      return
   fi
   if [[ -L "$target" ]]; then curr="$(readlink "$target")"; else curr="(absent)"; fi
   if [[ "$curr" == "$src" ]]; then
      [[ "$DRY_RUN" == "1" ]] && completed "  [dry-run] keep   $target  →  $src"
      return
   fi
   if [[ "$DRY_RUN" == "1" ]]; then
      warn "  [dry-run] link   $target  →  $src    [was: $curr]    ($(uname -s))"
      return
   fi
   info "Linking kitty.os.conf → $src ($(uname -s))"
   ln -sf "$src" "$target"
}

function linkup() {
   local s=$1 # Source
   local d=$2 # Destination

   if [[ "$d" == "/dev/null" ]]; then
      echo "Info: Skipping link for $s → $d"
      return
   fi

   # Trailing slash makes ln treat dest as a directory and nest the link
   # (e.g. ~/.config/kitty/kitty). Same rule for files and dirs.
   d="${d%/}"
   s="${s%/}"

   if [[ ! -e "$s" && ! -L "$s" ]]; then
      warn "linkup: source missing: $s  (skipping $d)"
      return 1
   fi

   local curr
   if [[ -L "$d" ]]; then
      curr="symlink → $(readlink "$d")"
   elif [[ -d "$d" ]]; then
      curr="directory"
   elif [[ -e "$d" ]]; then
      curr="regular file"
   else
      curr="(absent)"
   fi

   # Already correct (match literal target, or same resolved path).
   if [[ -L "$d" ]]; then
      local cur_target resolved_d resolved_s
      cur_target="$(readlink "$d")"
      resolved_d="$(realpath "$d" 2>/dev/null || true)"
      resolved_s="$(realpath "$s" 2>/dev/null || true)"
      if [[ "$cur_target" == "$s" || ( -n "$resolved_d" && "$resolved_d" == "$resolved_s" ) ]]; then
         [[ "$DRY_RUN" == "1" ]] && completed "  [dry-run] keep   $d  →  $s"
         return
      fi
   fi

   # Anything already at $d (file, real dir, or wrong symlink) is moved aside.
   # Never `rm -f` a directory and never `ln` into an existing directory —
   # that creates the nested ~/.config/{kitty/kitty,git/git} bug.
   # Also never let ln follow an existing dest symlink (use -n below).
   local backup=
   if [[ -e "$d" || -L "$d" ]]; then
      backup="${d}.$(date +%Y%m%d.%H%M%S)"
   fi

   if [[ "$DRY_RUN" == "1" ]]; then
      if [[ -n "$backup" ]]; then
         warn "  [dry-run] backup $d  →  $backup    [was: $curr]"
      fi
      warn "  [dry-run] link   $d  →  $s"
      return
   fi

   if [[ -n "$backup" ]]; then
      info "Backing up $d → $backup    [was: $curr]"
      mv "$d" "$backup"
   fi

   local parent_dir
   parent_dir=$(dirname "$d")
   mkdir -p "$parent_dir"
   # -n/--no-target-directory: if $d is somehow still a symlink-to-dir,
   # replace that symlink instead of creating $d/$(basename $s) inside it.
   ln -sfn "$s" "$d"
}

#-------------------------------------------------------------------------------
# zvim is a two-line wrapper that lives in the repo, so this is a link, not an
# install -- there is nothing to download and no version to track.
function install_zvim() {
   linkup ~/dotfiles/utils/zvim ~/.local/bin/zvim
}

#-------------------------------------------------------------------------------
function all() {
   linkrc
   install_tools "${CORE_TOOLS[@]}"
   install_zvim
}

#-------------------------------------------------------------------------------
# Dispatch
#-------------------------------------------------------------------------------
# action -> the function to call, with any arguments it is always given.
# An explicit table rather than `declare -F "$1"`, so that internal helpers
# (linkup, recipe, die, ...) are not silently runnable as actions and a typo
# gets a real error instead of a confusing partial run.
declare -A DISPATCH=(
   [all]="all"
   [linkrc]="linkrc"
   [install]="install_tools"
   [check]="check_tools"
   [tools]="list_tools"

   # Legacy names, kept because they are in muscle memory and corp scripts.
   [getstarship]="install_tools starship"
   [getz]="install_tools z"
   [getfzf]="install_tools fzf"
   [getnpm]="install_tools node"
   [getfonts]="recipe fonts"
   [zellij]="recipe zellij"
   [clang-format]="install_tools clang_format"
   [install_zvim]="install_zvim"
)

echo "Executing ~/corp/dotfiles.sh if any.."
# shellcheck source=/dev/null   # corp file may not exist on every host
[[ -f ~/corp/dotfiles.sh ]] && source ~/corp/dotfiles.sh

if [[ -z "${corp:-}" ]]; then
   echo "Please export corp=xxx"
   exit 1
fi

action="${1:-all}"
[[ -n "${DISPATCH[$action]:-}" ]] || die "unknown action: $action  (try '$prog -h')"
shift 2> /dev/null   # the rest are the action's own arguments

# Word-split is intentional: the table values are "function arg..." strings
# built in this file, not user input.
# shellcheck disable=SC2086
${DISPATCH[$action]} "$@"
