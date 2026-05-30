# z settings
[[ -f ~/dotfiles/initrc/z.sh ]] && source ~/dotfiles/initrc/z.sh
# configure fzf with z. With no args, show ~/.z sorted by LAST VISIT time
# (newest first), not z.sh's frecency score. fzf is in --no-sort mode so
# fuzzy filtering preserves that recency order instead of re-ranking by match.
# ~/.z format: path|rank|epoch_seconds
unalias z 2> /dev/null

_z_recent_dirs() {
  local data="${_Z_DATA:-$HOME/.z}"
  [[ -f "$data" ]] || return 1
  awk -F'|' 'NF >= 3 { printf "%s\t%s\t%s\n", $3, $2, $1 }' "$data" \
    | sort -t $'\t' -k1,1nr
}

_z_pick_recent_dir() {
  local query="$1"
  # Extract the path column up front. The old version used
  #   fzf --delimiter=$'\t' --with-nth=3.. --nth=3..
  # which silently matched nothing for any query (looked like fuzzy was
  # dead). Pre-projecting to a single column avoids fzf's --nth quirk on
  # newline-terminated last fields and is easier to reason about.
  _z_recent_dirs \
    | awk -F'\t' '{ print $3 }' \
    | fzf +s --no-sort -q "$query"
}

z() {
  local dir
  if [[ -z "$*" ]]; then
    dir="$(_z_pick_recent_dir "")" || return
    [[ -n "$dir" ]] && cd "$dir"
  else
    _last_z_args="$@"
    _z "$@"
  fi
}

zz() {
  local dir
  dir="$(_z_pick_recent_dir "$_last_z_args")" || return
  [[ -n "$dir" ]] && cd "$dir"
}
