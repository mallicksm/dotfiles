#!/usr/bin/env bash
#===============================================================================
# claude.sh — restart (resume) a saved Cursor agent chat session
#
# Relaunches cursor-agent against a pinned chat id so the conversation picks up
# where it left off. Defaults to the session this script was generated from.
#
# Spec: ./claude.md
#===============================================================================
set -uo pipefail

#-------------------------------------------------------------------------------
# Config / defaults
#-------------------------------------------------------------------------------
prog="${0##*/}"
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# The chat id ("hash") of the session this script restarts.
SESSION="${CLAUDE_SESSION:-e40c8694-f9d4-46f0-a63e-44827d83a922}"

# NB: not CURSOR_AGENT — the IDE sets that to 1 in agent shells.
AGENT="${CLAUDE_AGENT_BIN:-cursor-agent}"
WORKSPACE="$here"
TRANSCRIPTS="$HOME/.cursor/projects/home-smallick-dotfiles/agent-transcripts"

DRY_RUN=0
LIST=0
MODEL=""
PASSTHRU=()

#-------------------------------------------------------------------------------
# Usage / errors
#-------------------------------------------------------------------------------
usage() {
   cat <<EOF
Usage: $prog [options] [prompt...]

Resume the pinned Cursor agent chat session (default: $SESSION).
Any trailing non-flag words are sent as the opening prompt.

Options:
  -s, --session <id>   Chat id to resume (default: \$CLAUDE_SESSION or pinned id)
  -w, --workspace <d>  Workspace directory (default: dir of this script)
  -m, --model <name>   Model override passed to $AGENT (e.g. sonnet-4-thinking)
  -c, --continue       Resume the most recent session instead of the pinned id
  -l, --list           List known sessions in the transcript dir and exit
  -n, --dry-run        Print the command that would run, then exit
  -h, --help           Show this help

Examples:
  $prog                          # back into the pinned session
  $prog -n                       # show the exact command first
  $prog "where did we leave off" # resume with an opening prompt
  $prog -l                       # pick a different id to pass to -s
  $prog -s <uuid> -m gpt-5       # resume another session on another model
EOF
}

die() { echo "$prog: error: $*" >&2; echo >&2; usage >&2; exit 2; }

#-------------------------------------------------------------------------------
# Helpers
#-------------------------------------------------------------------------------
# step — single choke point: dry-run prints the exact argv, else it executes it.
step() {
   local dir="$1"; shift
   local a out=""
   for a in "$@"; do out+="${out:+ }$(printf '%q' "$a")"; done
   if (( DRY_RUN )); then
      printf '    cd %q && %s\n' "$dir" "$out"
      return 0
   fi
   cd "$dir" || return 1
   exec "$@"
}

list_sessions() {
   [[ -d "$TRANSCRIPTS" ]] || { echo "$prog: no transcript dir: $TRANSCRIPTS" >&2; return 1; }
   local d id jsonl when first
   for d in "$TRANSCRIPTS"/*/; do
      [[ -d "$d" ]] || continue
      id="$(basename "$d")"
      jsonl="$d/$id.jsonl"
      when="$(date -r "$d" '+%Y-%m-%d %H:%M' 2>/dev/null || echo '?')"
      first=""
      if [[ -r "$jsonl" ]]; then
         first="$(head -c 4000 "$jsonl" \
            | sed -n 's/.*<user_query>\\n\(.\{0,60\}\).*/\1/p' | head -1)"
         first="${first%%\\n*}"
      fi
      printf '  %s  %s  %s%s\n' "$id" "$when" "$first" \
         "$([[ "$id" == "$SESSION" ]] && echo '   <= pinned')"
   done
}

#-------------------------------------------------------------------------------
# Arg parsing
#-------------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
   case "$1" in
      -s|--session)   [[ $# -ge 2 ]] || die "$1 needs a chat id"; SESSION="$2"; shift 2 ;;
      -w|--workspace) [[ $# -ge 2 ]] || die "$1 needs a directory"; WORKSPACE="$2"; shift 2 ;;
      -m|--model)     [[ $# -ge 2 ]] || die "$1 needs a model name"; MODEL="$2"; shift 2 ;;
      -c|--continue)  SESSION=""; shift ;;
      -l|--list)      LIST=1; shift ;;
      -n|--dry-run)   DRY_RUN=1; shift ;;
      -h|--help)      usage; exit 0 ;;
      --)             shift; PASSTHRU+=("$@"); break ;;
      -*)             die "unknown option: $1" ;;
      *)              PASSTHRU+=("$1"); shift ;;
   esac
done

#-------------------------------------------------------------------------------
# Validation
#-------------------------------------------------------------------------------
(( LIST )) && { echo "Sessions in $TRANSCRIPTS:"; list_sessions; exit 0; }

command -v "$AGENT" >/dev/null 2>&1 || die "$AGENT not found in PATH"
[[ -d "$WORKSPACE" ]] || die "workspace not a directory: $WORKSPACE"

#-------------------------------------------------------------------------------
# Run
#-------------------------------------------------------------------------------
cmd=("$AGENT")
if [[ -n "$SESSION" ]]; then
   cmd+=(--resume "$SESSION")
else
   cmd+=(--continue)
fi
[[ -n "$MODEL" ]] && cmd+=(--model "$MODEL")
cmd+=(--workspace "$WORKSPACE")
(( ${#PASSTHRU[@]} )) && cmd+=("${PASSTHRU[@]}")

(( DRY_RUN )) && echo "$prog: would run:"
step "$WORKSPACE" "${cmd[@]}"
