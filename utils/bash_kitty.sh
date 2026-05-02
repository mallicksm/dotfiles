export KITTY_CONFIG_DIRECTORY=~/dotfiles/initrc/kitty
# in mac exec this command to fix gui launch of kitty
# launchctl setenv KITTY_CONFIG_DIRECTORY /Users/smallick/dotfiles/initrc/kitty

#-------------------------------------------------------------------------------
# ktheme - quick kitty theme switcher
#
# `kitten themes --reload-in=all "<name>"` already persists the chosen theme
# (writes ~/.config/kitty/current-theme.conf) AND retheme every open window,
# so the catalog path is simple. This wrapper adds:
#   - one-word shortcuts for our committed local themes (original, dracula),
#     which aren't in the upstream kitten catalog,
#   - `ktheme list` -> kitten's interactive picker (LIVE palette preview as
#     you arrow through; type letters to filter the names),
#   - fuzzy matching on the catch-all so `ktheme catpucchin` (typo) and
#     `ktheme mocha` both work; uses fzf when present.
#
# Usage examples:
#   ktheme catppuccin                # fuzzy-picks among the 4 Catppuccins
#   ktheme mocha                     # one match -> applied directly
#   ktheme tokyo_night_storm         # exact name -> applied directly
#   ktheme original                  # restore committed dracula-pro.conf
#   ktheme list                      # interactive picker w/ live preview
#   ktheme -h                        # this help
#-------------------------------------------------------------------------------
function ktheme() {
   local kdir=~/.config/kitty
   case "${1:-}" in
      ""|-h|--help|help)
         cat <<'EOF'
Usage: ktheme <theme-or-fuzzy-query>
  Switch kitty theme. Catalog themes update the current AND future windows.
  Local-file shortcuts (original/dracula) update future windows only — press
  cs+f5 (kitty default = load_config_file) to reload the current window.

  ktheme original           Restore your saved Dracula Pro from the repo
                            (current window: press cs+f5 to reload)
  ktheme dracula            Vanilla Dracula from the repo
                            (current window: press cs+f5 to reload)
  ktheme list               Interactive kitten picker with LIVE palette
                            preview. Inside the picker: type letters to
                            filter, arrows to move, Enter to apply, Esc to
                            cancel.
  ktheme <query>            Fuzzy-match the catalog by name (fzf-style:
                            search chars must appear IN ORDER in the theme
                            name; missing letters are fine, extra/wrong
                            letters break the match). Examples:
                              ktheme Catppuccin-Mocha   # exact name
                              ktheme mocha              # 1 match -> applied
                              ktheme catppuccin         # 4 matches -> picker
                              ktheme catppucin          # 1 missing 'c' OK
                              ktheme cppccn             # consonants OK
                              ktheme tknght             # tokyo_night_*
                              ktheme gruvbox dark soft  # multi-word query
EOF
         return 0
         ;;
      original|dracula-pro)
         if [[ ! -f "$kdir/dracula-pro.conf" ]]; then
            echo "Error: $kdir/dracula-pro.conf not found" >&2
            return 1
         fi
         cp "$kdir/dracula-pro.conf" "$kdir/current-theme.conf"
         echo "Set: Dracula Pro (your original).  New windows pick this up."
         echo "Press cs+f5 to reload the current window."
         ;;
      dracula)
         if [[ ! -f "$kdir/dracula.conf" ]]; then
            echo "Error: $kdir/dracula.conf not found" >&2
            return 1
         fi
         cp "$kdir/dracula.conf" "$kdir/current-theme.conf"
         echo "Set: Dracula (vanilla).  New windows pick this up."
         echo "Press cs+f5 to reload the current window."
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
                     --prompt="ktheme> " \
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
            0) echo "No theme matches '$query'. Try \`ktheme list\`." >&2
               return 1 ;;
            1) kitten themes --reload-in=all "$matches" ;;
            *) echo "Multiple matches for '$query' (be more specific):" >&2
               printf '  %s\n' "$matches" >&2
               return 1 ;;
         esac
         ;;
   esac
}
