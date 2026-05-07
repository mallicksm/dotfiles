"""kitty kitten: vim-style hjkl window navigation with edge-fallthrough.

When invoked as `kitten window_nav.py <direction>`:
  * Try to focus the neighboring window in <direction> ('left', 'right',
    'up', 'down'). This is the standard `neighboring_window` action.
  * If no window exists in that direction, AND the direction is horizontal
    ('left' or 'right'), fall through to the previous/next tab. Vertical
    directions ('up' / 'down') stay put on no-neighbor, matching nvim's
    `:wincmd j` / `:wincmd k` semantics (which don't wrap or escape).

Bindings (in kitty.conf):
    map kitty_mod+h kitten window_nav.py left
    map kitty_mod+j kitten window_nav.py down
    map kitty_mod+k kitten window_nav.py up
    map kitty_mod+l kitten window_nav.py right

Pure-tab navigation is still available via the kitty defaults
`cs+left` / `cs+right` (and `cs+,` / `cs+.` to move tabs).
"""
from kittens.tui.handler import result_handler


def main(args):
    """No interactive UI; required entry point. Real work in handle_result()."""
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    direction = args[1]

    # kitty's tab.neighboring_window() expects 'left' / 'right' / 'top' /
    # 'bottom'. Accept vim-style 'up' / 'down' as synonyms so the bindings
    # in kitty.conf can stay h/j/k/l-natural.
    canonical = {'up': 'top', 'down': 'bottom'}.get(direction, direction)

    tab = boss.active_tab
    if tab is None:
        return

    # tab.neighboring_window() is best-effort: it focuses a candidate if one
    # exists, otherwise it's a no-op. Detect "did focus move?" by snapshotting
    # active_window before/after rather than poking at private layout state.
    before = tab.active_window
    tab.neighboring_window(canonical)
    if tab.active_window is not before:
        return

    # No window neighbor in this direction. Only horizontal axes fall
    # through to adjacent tabs, deliberately mirroring nvim where j/k
    # never escape the current tabpage.
    if direction == 'left':
        boss.previous_tab()
    elif direction == 'right':
        boss.next_tab()
