#!/usr/bin/env bash
set -euo pipefail

### ============================================================================
### xfce.sh -- XFCE desktop provisioning + teardown (was setup_xfce / kill_xfce).
###
###   xfce.sh -s   Set up / polish THIS XFCE session via xfconf-query: disable
###                screensaver+lock, add a workspace-switcher (pager) to a panel,
###                and apply cursor/panel/font cosmetics from the CONFIG block.
###   xfce.sh -k   Kill this XFCE/VNC session and wipe its config+cache so the
###                next login starts from a clean slate.
###   xfce.sh -h   This help (also shown when no option is given).
###
### One action per invocation. Not auto-sourced (name isn't bash_*.sh); run it
### by hand -- ~/dotfiles/utils is on PATH, so `xfce.sh -s` / `xfce.sh -k`.
### ============================================================================

### =======================
### CONFIG (tweak here)
### =======================
CURSOR_SIZE=12                 # Mouse pointer size (e.g., 12, 16, 24)
PANEL_TOP_ID=1                 # Usually 1 on a fresh XFCE
PANEL_BOTTOM_ID=2              # Usually 2 on a fresh XFCE
PANEL_TOP_SIZE=40              # Height in px
PANEL_BOTTOM_SIZE=50           # Height in px
GTK_FONT="DejaVu Sans 11"      # Panel text follows this global GTK font
SET_MINIMIZED_ICON_TYPE=1      # 1 = Minimized application icons (0=None, 2=File/launcher icons)

### =======================
### Helpers
### =======================
have() { command -v "$1" >/dev/null 2>&1; }
xfget() { xfconf-query -c "$1" -p "$2" >/dev/null 2>&1; }

# Generic setter (create if missing)
qset() {
   local ch="$1" p="$2" t="$3" v="$4"
   if xfget "$ch" "$p"; then
      xfconf-query -c "$ch" -p "$p" -s "$v"
   else
      xfconf-query -c "$ch" -p "$p" --create -t "$t" -s "$v"
   fi
}

### =======================
### Screensaver
### =======================
ss_ch="xfce4-screensaver"

qset_bool() {
   local key="$1" val="$2"
   if xfget "$ss_ch" "$key"; then
      xfconf-query -c "$ss_ch" -p "$key" -s "$val"
   else
      xfconf-query -c "$ss_ch" -p "$key" --create -t bool -s "$val"
   fi
}

disable_screensaver() {
   echo "[*] Disabling XFCE screensaver..."
   qset_bool "/saver/enabled" false
   qset_bool "/saver/idle-activation/enabled" false
   qset_bool "/lock/enabled" false
}

verify_screensaver() {
   echo "[*] Current xfce4-screensaver settings:"
   xfconf-query -c "$ss_ch" -lv | sed 's/^/   /'
}

### =======================
### Pager to a panel
### =======================
panel_ch="xfce4-panel"

pick_panel_id() {
   # Prefer 2 if present, else first listed id
   local list ids
   list="$(xfconf-query -c "$panel_ch" -p /panels 2>/dev/null || true)"
   ids=$(printf "%s\n" "$list" | grep -oE '[0-9]+' || true)
   if printf "%s\n" "$ids" | grep -qx 2; then
      echo 2
   else
      echo "${ids%%$'\n'*}"
   fi
}

next_free_plugin_id() {
   local n=1
   while xfget "$panel_ch" "/plugins/plugin-${n}"; do
      n=$((n+1))
   done
   echo "$n"
}

append_or_create_plugin_ids() {
   local panel_path="$1" pid="$2"
   if xfget "$panel_ch" "${panel_path}/plugin-ids"; then
      xfconf-query -c "$panel_ch" -p "${panel_path}/plugin-ids" -a -t int -s "$pid"
   else
      xfconf-query -c "$panel_ch" -p "${panel_path}/plugin-ids" --create -a -t int -s "$pid"
   fi
}

add_workspace_switcher() {
   local target_id panel_path pid
   target_id="$(pick_panel_id)"
   panel_path="/panels/panel-${target_id}"
   echo "[*] Targeting ${panel_path} (available panels: $(xfconf-query -c "$panel_ch" -p /panels 2>/dev/null || echo '?'))"
   pid="$(next_free_plugin_id)"
   xfconf-query -c "$panel_ch" -p "/plugins/plugin-${pid}" --create -t string -s "pager"
   append_or_create_plugin_ids "$panel_path" "$pid"
   echo "   Added pager as /plugins/plugin-${pid} to ${panel_path}/plugin-ids."
   echo "[*] Restarting panel..."
   xfce4-panel -r
}

### =======================
### Cosmetics
### =======================
set_icon_type() {
   # 0=None, 1=Minimized application icons, 2=File/launcher icons
   if [[ "${SET_MINIMIZED_ICON_TYPE}" -eq 1 ]]; then
      echo "[*] Setting desktop icon type to 'Minimized application icons'..."
      qset xfce4-desktop /desktop-icons/style int 1
   fi
}

set_cursor_size() {
   local size="${1:-$CURSOR_SIZE}"
   echo "[*] Setting mouse cursor size to ${size}px..."
   qset xsettings /Gtk/CursorThemeSize int "$size"
}

set_panel_size() {
   local panel_id="$1" size="$2" prop="/panels/panel-${panel_id}/size"
   echo "[*] Setting panel ${panel_id} height to ${size}px..."
   qset xfce4-panel "$prop" int "$size"
   xfce4-panel -r
}

set_panel_font() {
   local font="${1:-$GTK_FONT}"
   echo "[*] Setting GTK/panel font to '${font}'..."
   qset xsettings /Gtk/FontName string "$font"
}

### =======================
### Actions
### =======================
xfce_setup() {
   have xfconf-query || { echo "xfconf-query not found"; exit 1; }

   # Proven bits
   disable_screensaver
   verify_screensaver
   add_workspace_switcher

   # Polishing (config-driven)
   set_icon_type
   set_cursor_size "$CURSOR_SIZE"
   set_panel_size "$PANEL_TOP_ID" "$PANEL_TOP_SIZE"
   set_panel_size "$PANEL_BOTTOM_ID" "$PANEL_BOTTOM_SIZE"
   set_panel_font "$GTK_FONT"

   echo "[*] Done."
}

xfce_kill() {
   echo "[*] Wiping XFCE config + cache..."
   rm -rf ~/.config/xfce4
   rm -rf ~/.cache/xfce4
   rm -rf ~/.cache/sessions
   echo "[*] Killing XFCE processes..."
   pkill xfconfd       || true
   pkill xfce4-panel   || true
   pkill xfce4-session || true
   if [[ -n ${DISPLAY:-} ]]; then
      echo "[*] Killing VNC server on ${DISPLAY}..."
      vncserver -kill "$DISPLAY" || true
   fi
   echo "[*] Done."
}

usage() {
   cat <<'EOF'
xfce.sh -- XFCE desktop provisioning + teardown (was setup_xfce / kill_xfce)

Usage: xfce.sh [-s | -k | -h]
  -s   Set up / polish THIS XFCE session via xfconf-query: disable
       screensaver+lock, add a workspace-switcher (pager) to a panel, and
       apply the cursor/panel/font cosmetics from the CONFIG block.
  -k   Kill this XFCE/VNC session and wipe its config+cache (~/.config/xfce4,
       ~/.cache/xfce4, ~/.cache/sessions) so the next login starts clean.
  -h   This help (also shown when no option is given).

One action per invocation. Run by hand -- ~/dotfiles/utils is on PATH.
EOF
}

### =======================
### Dispatch (one action per run; no option -> help)
### =======================
main() {
   local opt
   OPTIND=1
   while getopts ":skh" opt; do
      case "$opt" in
         s) xfce_setup; return $? ;;
         k) xfce_kill;  return $? ;;
         h) usage;      return 0  ;;
         \?) echo "xfce.sh: unknown option -$OPTARG" >&2; usage; return 2 ;;
      esac
   done
   # No option given -> help.
   usage
}

main "$@"
