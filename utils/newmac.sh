#!/usr/bin/env bash
#===============================================================================
# newmac.sh -- disable macOS Option/Alt system shortcuts (idempotent)
#
# Disables AppleSymbolicHotKeys whose chord includes Option (Alt), plus a few
# fixed ids that commonly fight AltTab / input switching.
#
# Safe to re-run: already-disabled keys are left alone, non-Option shortcuts are
# untouched, and Dock/prefs are only bounced when something actually changes.
#
# Usage:
#   bash ~/dotfiles/newmac.sh
#===============================================================================
set -euo pipefail

OPT_BIT=524288   # NSEventModifierFlagOption
DOMAIN=com.apple.symbolichotkeys
PLIST="$HOME/Library/Preferences/${DOMAIN}.plist"
TMP_JSON="$(mktemp -t symhot.XXXXXX.json)"
TMP_OUT="$(mktemp -t symhot.XXXXXX.plist)"
CHANGED_FLAG="$(mktemp -t symhot.XXXXXX.changed)"

cleanup() { rm -f "$TMP_JSON" "$TMP_OUT" "$CHANGED_FLAG"; }
trap cleanup EXIT

echo "==> Reading current symbolic hotkeys"

if [[ -f "$PLIST" ]]; then
  plutil -convert json -o "$TMP_JSON" -- "$PLIST"
else
  printf '%s\n' '{"AppleSymbolicHotKeys":{}}' >"$TMP_JSON"
fi

echo "==> Applying Option/Alt disables (no-op if already done)"

python3 - "$TMP_JSON" "$TMP_OUT" "$CHANGED_FLAG" "$OPT_BIT" <<'PY'
import json
import plistlib
import sys

src, dst, changed_path, opt_bit = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])

with open(src) as f:
    data = json.load(f)

hot = data.setdefault("AppleSymbolicHotKeys", {})

# ids we always want off (AltTab / input-source conflicts).
# Only flip enabled -> false; never overwrite an existing value/parameters blob.
ALWAYS_DISABLE = {
    "60",   # Select previous input source (Ctrl+Space)
    "61",   # Select next input source     (Ctrl+Option+Space)
    "163",  # Turn Dock Hiding On/Off      (Cmd+Option+D)
}

# Fallback value blobs only used when the key is missing entirely.
DEFAULT_VALUE = {
    "60": {"type": "standard", "parameters": [32, 49, 262144]},
    "61": {"type": "standard", "parameters": [32, 49, 786432]},
    "163": {"type": "standard", "parameters": [100, 2, 1572864]},
}

changed = []


def ensure_disabled(hid: str, reason: str) -> None:
    entry = hot.get(hid)
    if entry is None:
        hot[hid] = {
            "enabled": False,
            "value": DEFAULT_VALUE.get(
                hid, {"type": "standard", "parameters": [65535, 65535, 0]}
            ),
        }
        changed.append(f"{hid} ({reason}, created disabled)")
        return

    if entry.get("enabled", True):
        entry["enabled"] = False
        hot[hid] = entry
        changed.append(f"{hid} ({reason})")


for hid in ALWAYS_DISABLE:
    ensure_disabled(hid, "known conflict")

for hid, entry in list(hot.items()):
    value = entry.get("value") or {}
    params = value.get("parameters") or []
    if len(params) < 3:
        continue
    try:
        mods = int(params[2])
    except (TypeError, ValueError):
        continue
    if mods & opt_bit:
        ensure_disabled(hid, "Option modifier")

with open(dst, "wb") as f:
    plistlib.dump(data, f, fmt=plistlib.FMT_XML)

with open(changed_path, "w") as f:
    f.write("\n".join(changed))

if changed:
    print("changed:")
    for line in changed:
        print(f"  - {line}")
else:
    print("already applied; nothing to change")
PY

if [[ ! -s "$CHANGED_FLAG" ]]; then
  echo
  echo "Done (no changes). Re-run is a no-op."
  exit 0
fi

echo "==> Writing preferences"
defaults import "$DOMAIN" "$TMP_OUT"

echo "==> Reloading shortcuts (only because prefs changed)"
# Prefer a light prefs flush; avoid killing Dock/SystemUIServer on every run.
if ! /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null; then
  killall cfprefsd 2>/dev/null || true
fi

echo
echo "Done. Option/Alt system shortcuts disabled."
echo "If a shortcut still fires, log out and back in."
echo "Review: System Settings → Keyboard → Keyboard Shortcuts"
