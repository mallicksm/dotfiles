export KITTY_CONFIG_DIRECTORY=~/dotfiles/initrc/kitty
# in mac exec this command to fix gui launch of kitty
# launchctl setenv KITTY_CONFIG_DIRECTORY /Users/smallick/dotfiles/initrc/kitty

#-------------------------------------------------------------------------------
# kktheme - quick kitty theme switcher
#
# `kitten themes --reload-in=all "<name>"` already persists the chosen theme
# (writes ~/.config/kitty/current-theme.conf) AND retheme every open window,
# so the catalog path is simple. This wrapper adds:
#   - one-word shortcuts for our committed local themes (original, dracula),
#     which aren't in the upstream kitten catalog,
#   - `kktheme list` -> kitten's interactive picker (LIVE palette preview as
#     you arrow through; type letters to filter the names),
#   - fuzzy matching on the catch-all so `kktheme catpucchin` (typo) and
#     `kktheme mocha` both work; uses fzf when present.
#
# Usage examples:
#   kktheme catppuccin                # fuzzy-picks among the 4 Catppuccins
#   kktheme mocha                     # one match -> applied directly
#   kktheme tokyo_night_storm         # exact name -> applied directly
#   kktheme original                  # restore your saved original-theme.conf
#   kktheme save                      # snapshot current-theme.conf -> original-theme.conf
#   kktheme list                      # interactive picker w/ live preview
#   kktheme -h                        # this help
#-------------------------------------------------------------------------------
function kktheme() {
   case "${1:-}" in
      ""|-h|--help|help)
         cat <<'EOF'
Usage: kktheme <theme-or-fuzzy-query>
  Switch kitty theme. Catalog themes (kitten themes) update current AND
  future windows. Local-file shortcuts (original/dracula) cp the file over
  current-theme.conf and live-retone every window via 'kitty @ set-colors'
  (auto-fallback to "press cs+f5" if remote control is off).

  kktheme original           Restore the saved snapshot in original-theme.conf
                            (auto-retones every kitty window if remote
                            control is on; otherwise press cs+f5 to reload).
  kktheme save               Snapshot the CURRENT theme into original-theme.conf
                            so 'kktheme original' rolls back to this state
                            next time you fuck up. Backs up the previous
                            snapshot as original-theme.conf.bak.
  kktheme dracula            Vanilla Dracula from the repo (auto-retone too).
  kktheme list               Interactive kitten picker with LIVE palette
                            preview. Inside the picker: type letters to
                            filter, arrows to move, Enter to apply, Esc to
                            cancel.
  kktheme <query>            Fuzzy-match the catalog by name (fzf-style:
                            search chars must appear IN ORDER in the theme
                            name; missing letters are fine, extra/wrong
                            letters break the match). Examples:
                              kktheme Catppuccin-Mocha   # exact name
                              kktheme mocha              # 1 match -> applied
                              kktheme catppuccin         # 4 matches -> picker
                              kktheme catppucin          # 1 missing 'c' OK
                              kktheme cppccn             # consonants OK
                              kktheme tknght             # tokyo_night_*
                              kktheme gruvbox dark soft  # multi-word query
EOF
         return 0
         ;;
   esac

   # Everything below this point talks to a running kitty (theme reload via
   # `kitten themes --reload-in=all`, or the live picker via `kitten themes`).
   # Outside kitty there's nothing to retheme, so bail with a clear message.
   if [[ -z ${KITTY_WINDOW_ID:-} ]]; then
      echo "kktheme: not in a kitty terminal (KITTY_WINDOW_ID is unset)." >&2
      echo "kktheme: this command retones the running kitty via 'kitten themes --reload-in=all'." >&2
      echo "kktheme: open a kitty window and try again, or run 'kktheme -h' for help." >&2
      return 1
   fi

   local kdir=~/.config/kitty
   case "${1:-}" in
      original)
         if [[ ! -f "$kdir/original-theme.conf" ]]; then
            echo "kktheme: $kdir/original-theme.conf not found -- nothing to restore." >&2
            echo "kktheme: run 'kktheme save' first to snapshot your current theme as the rollback target." >&2
            return 1
         fi
         cp "$kdir/original-theme.conf" "$kdir/current-theme.conf"
         if kitty @ set-colors --all --configured 2>/dev/null; then
            echo "kktheme: restored original-theme.conf and retoned all kitty windows."
         else
            echo "kktheme: copied original-theme.conf into current-theme.conf -- new windows will pick it up."
            echo "kktheme: live retone failed; ensure 'allow_remote_control yes' in kitty.conf, or press cs+f5 in each window." >&2
         fi
         ;;
      dracula)
         if [[ ! -f "$kdir/dracula.conf" ]]; then
            echo "kktheme: $kdir/dracula.conf not found" >&2
            return 1
         fi
         cp "$kdir/dracula.conf" "$kdir/current-theme.conf"
         if kitty @ set-colors --all --configured 2>/dev/null; then
            echo "kktheme: applied vanilla Dracula and retoned all kitty windows."
         else
            echo "kktheme: copied dracula.conf into current-theme.conf -- new windows will pick it up."
            echo "kktheme: live retone failed; ensure 'allow_remote_control yes' in kitty.conf, or press cs+f5 in each window." >&2
         fi
         ;;
      save|snapshot)
         # Lock in the current `current-theme.conf` as the new 'original' --
         # i.e. what `kktheme original` will restore. Backs up the previous
         # snapshot to original-theme.conf.bak in case you want to reach back.
         if [[ ! -f "$kdir/current-theme.conf" ]]; then
            echo "kktheme: $kdir/current-theme.conf not found -- nothing to snapshot." >&2
            return 1
         fi
         if [[ -f "$kdir/original-theme.conf" ]]; then
            cp -f "$kdir/original-theme.conf" "$kdir/original-theme.conf.bak"
         fi
         cp "$kdir/current-theme.conf" "$kdir/original-theme.conf"
         echo "kktheme: snapshotted current theme into $kdir/original-theme.conf"
         echo "kktheme: 'kktheme original' will now restore THIS exact state."
         [[ -f "$kdir/original-theme.conf.bak" ]] && \
            echo "kktheme: previous snapshot saved as original-theme.conf.bak"
         ;;
      list|ls|pick)
         # Hand off to kitten's own interactive picker — it's the only thing
         # that gives a live color preview of each theme as you scroll. Type
         # letters inside the picker to filter the name list.
         kitten themes
         ;;
      *)
         local query="$*"
         local zip=~/.cache/kitty/kitty-themes.zip
         # No cache yet -> just let the kitten handle it (it'll download and
         # error out cleanly if the name is unknown).
         if [[ ! -f "$zip" ]]; then
            kitten themes --reload-in=all "$query"
            return $?
         fi
         local names
         names=$(unzip -l "$zip" 2>/dev/null \
                  | grep -oE 'themes/[^/]+\.conf' \
                  | sed 's|themes/||; s|\.conf$||' | sort -u)
         # Exact match (case-sensitive) wins immediately — fast path.
         local exact
         exact=$(printf '%s\n' "$names" | grep -Fx -- "$query") || true
         if [[ -n "$exact" ]]; then
            kitten themes --reload-in=all "$exact"
            return $?
         fi
         # Fuzzy path. fzf's --query pre-filters; --select-1 auto-picks if the
         # query reduces to exactly one match; --exit-0 quits immediately if
         # there are zero matches (so we can show our own error).
         if command -v fzf >/dev/null 2>&1; then
            local pick
            pick=$(printf '%s\n' "$names" | fzf \
                     --height 40% \
                     --prompt="kktheme> " \
                     --query="$query" \
                     --select-1 --exit-0 \
                     --header "fuzzy match for '$query' — Enter to apply, Esc to cancel")
            if [[ -z "$pick" ]]; then
               echo "No theme matched '$query' (or cancelled)." >&2
               return 1
            fi
            kitten themes --reload-in=all "$pick"
            return $?
         fi
         # fzf-less fallback: case-insensitive substring.
         local matches
         matches=$(printf '%s\n' "$names" | grep -iF -- "$query") || true
         local n=0
         [[ -n "$matches" ]] && n=$(printf '%s\n' "$matches" | wc -l)
         case $n in
            0) echo "No theme matches '$query'. Try \`kktheme list\`." >&2
               return 1 ;;
            1) kitten themes --reload-in=all "$matches" ;;
            *) echo "Multiple matches for '$query' (be more specific):" >&2
               printf '  %s\n' "$matches" >&2
               return 1 ;;
         esac
         ;;
   esac
}

#-------------------------------------------------------------------------------
# kktabname - rename the current kitty tab from any window inside it
#
# Sets a manual override on the focused tab's title via kitty's remote
# control facility. The override stays until the active program writes
# its own title (vim, less, etc. typically do) -- if you want truly
# sticky, also bind a shell prompt that doesn't keep retitling.
#
# Requires `allow_remote_control yes` in kitty.conf (or socket-only with
# $KITTY_LISTEN_ON set up). The wrapper detects the missing permission
# and prints a clear error rather than failing silently.
#
# Usage:
#   kktabname work               # rename current tab to "work"
#   kktabname some long phrase   # joins all args with spaces
#   kktabname                    # interactive prompt for the title
#   kktabname -r                 # reset (kitty resumes inferring from program)
#   kktabname -h                 # show help
#-------------------------------------------------------------------------------
function kktabname() {
   # -h/--help must work outside kitty (principle of least surprise).
   case "${1:-}" in
      -h|--help)
         cat <<'EOF'
Usage: kktabname [title...]    set tab title from args (joined with spaces)
       kktabname               prompt for title
       kktabname -r            reset; kitty resumes inferring from active program
       kktabname -h            this help
EOF
         return 0
         ;;
   esac

   if [[ -z ${KITTY_WINDOW_ID:-} ]]; then
      echo "kktabname: not in a kitty terminal (KITTY_WINDOW_ID is unset)." >&2
      echo "kktabname: this command renames the focused tab via 'kitty @ set-tab-title'." >&2
      echo "kktabname: open a kitty window and try again, or run 'kktabname -h' for help." >&2
      return 1
   fi

   local title
   case "${1:-}" in
      -r|--reset)
         title=""
         ;;
      "")
         read -rp 'New tab title: ' title
         ;;
      *)
         title="$*"
         ;;
   esac

   # Pre-flight: count tabs in the current OS window so we can warn the user
   # if there's only one. With our `tab_bar_min_tabs 2`, the tab bar is hidden
   # for a single tab -- the rename works (kitty stores the title, OS-window
   # title may update) but there's no tab-bar entry to show it, which is
   # easy to mistake for failure. Done BEFORE the rename so the reminder is
   # printed regardless of whether the rename itself succeeds.
   local tabs_count=
   if command -v python3 >/dev/null 2>&1; then
      local ls_out
      ls_out=$(kitten @ ls --match-tab state:focused_os_window 2>/dev/null) && \
         tabs_count=$(printf '%s' "$ls_out" | python3 -c '
import json, sys
try:
   data = json.load(sys.stdin)
except Exception:
   print(0); sys.exit(0)
n = 0
for osw in (data if isinstance(data, list) else [data]):
   n += len(osw.get("tabs", []))
print(n)
' 2>/dev/null)
   fi

   # `--` guards against titles starting with `-` being parsed as flags by `kitty @`.
   if ! kitty @ set-tab-title -- "$title" 2>/dev/null; then
      echo "kktabname: failed -- enable 'allow_remote_control yes' in kitty.conf and reload (cs+f5 won't be enough; needs new kitty)" >&2
      return 1
   fi

   if [[ -n $tabs_count && $tabs_count -eq 1 ]]; then
      echo "kktabname: heads-up -- this OS window has only 1 tab, so the tab bar is hidden (tab_bar_min_tabs=2). Title is set, but you'll only see it once a second tab opens (cs+t)." >&2
   fi
}
export -f kktabname

#-------------------------------------------------------------------------------
# kkbroadcast - run the same command in every other kitty window
#
# Sends <cmd> + Enter to every kitty window EXCEPT the one you're typing in,
# scoped by default to the current tab. Useful for "run `git pull` in all 8
# ssh panes" style chores. For live keystroke broadcasting (every key you
# press mirrored to every pane), use the `kitty +kitten broadcast` overlay
# instead -- that's bound elsewhere in kitty.conf.
#
# We rely on `kitten @ send-text --exclude-active` to drop the broadcaster
# itself from the matched window set. (NB: a `--match 'not state:self'`
# filter does NOT compose with `--match-tab` -- send-text doesn't intersect
# the two flags, so the self-exclusion has to come from --exclude-active.)
#
# Requires `allow_remote_control yes` in kitty.conf.
#
# Usage:
#   kkbroadcast pwd                 # 'pwd\n' -> all other windows in this tab
#   kkbroadcast git pull --rebase   # args joined with spaces
#   kkbroadcast -a uptime           # all OTHER windows everywhere (all tabs)
#   kkbroadcast -t '^logs-' tail -F # title-regex match (any tab); also excludes self
#   kkbroadcast -h                  # this help
#-------------------------------------------------------------------------------
function kkbroadcast() {
   # -h/--help must work outside kitty too (principle of least surprise).
   case "${1:-}" in
      -h|--help)
         cat <<'EOF'
Usage: kkbroadcast [-a | -t REGEX] <command...>
  Send <command>+Enter to every kitty window except this one.
  Default scope: other windows in the CURRENT tab.

  -a            broadcast to all windows in all tabs (still excludes self)
  -t REGEX      broadcast to windows whose title matches REGEX (any tab)
  -h            this help

  Multi-word commands are joined with spaces. To send shell metachars
  literally, quote: kkbroadcast 'cd /tmp && ls'.
EOF
         return 0
         ;;
   esac

   if [[ -z ${KITTY_WINDOW_ID:-} ]]; then
      echo "kkbroadcast: not in a kitty terminal (KITTY_WINDOW_ID is unset)." >&2
      echo "kkbroadcast: this command sends text to other kitty windows via 'kitten @ send-text'." >&2
      echo "kkbroadcast: open a kitty window and try again, or run 'kkbroadcast -h' for help." >&2
      return 1
   fi

   local scope=(--match-tab state:focused)
   local scope_desc='this tab'
   while [[ $# -gt 0 ]]; do
      case "$1" in
         -a|--all)
            scope=(--match all)
            scope_desc='any tab or OS-window'
            shift
            ;;
         -t|--title)
            if [[ -z ${2:-} ]]; then
               echo "kkbroadcast: -t needs a regex argument" >&2
               return 2
            fi
            scope=(--match "title:$2")
            scope_desc="windows with title matching '$2'"
            shift 2
            ;;
         --) shift; break ;;
         -*)
            echo "kkbroadcast: unknown option '$1' (try -h)" >&2
            return 2
            ;;
         *) break ;;
      esac
   done

   if [[ $# -eq 0 ]]; then
      echo "kkbroadcast: nothing to send (try 'kkbroadcast -h')" >&2
      return 1
   fi

   # Pre-flight: count recipients in scope (matched windows minus self) so we
   # can say "no one to broadcast to" instead of silently no-op'ing. send-text
   # always exit-0s even when zero windows matched, so we have to ask
   # `kitten @ ls` ourselves. If `ls` errors (e.g. remote control disabled),
   # we skip the check and let send-text below produce the real error.
   local ls_out ls_rc=0
   ls_out=$(kitten @ ls "${scope[@]}" 2>/dev/null) || ls_rc=$?
   if [[ $ls_rc -eq 0 ]] && command -v python3 >/dev/null 2>&1; then
      local recipients
      recipients=$(printf '%s' "$ls_out" | python3 -c '
import json, os, sys
try:
   self_id = int(os.environ.get("KITTY_WINDOW_ID", ""))
except ValueError:
   self_id = -1
try:
   data = json.load(sys.stdin)
except Exception:
   print(0); sys.exit(0)
n = 0
for osw in (data if isinstance(data, list) else [data]):
   for tab in osw.get("tabs", []):
      for w in tab.get("windows", []):
         wid = w.get("id")
         if isinstance(wid, int) and wid != self_id:
            n += 1
print(n)
' 2>/dev/null) || recipients=
      if [[ -n $recipients && $recipients -eq 0 ]]; then
         echo "kkbroadcast: no other kitty windows in $scope_desc -- nothing to do." >&2
         return 0
      fi
   fi

   if ! kitten @ send-text --exclude-active "${scope[@]}" -- "$*"$'\n' 2>/dev/null; then
      echo "kkbroadcast: failed -- ensure 'allow_remote_control yes' in kitty.conf and that this kitty was started after the change" >&2
      return 1
   fi
}
export -f kkbroadcast
