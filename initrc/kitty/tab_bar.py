"""Custom kitty tab bar.

Two responsibilities:

1. **Stable tab widths.** Each tab's rendered title (already formatted via
   `tab_title_template` in kitty.conf, including bell / activity symbols)
   is left-padded / truncated to a fixed character count before being
   handed to kitty's built-in powerline drawer. Result: tabs no longer
   shrink and grow as the active program's title changes. Powerline
   look is preserved (we still call `draw_tab_with_powerline`).

2. **Right-aligned status.** After the last tab, the remaining horizontal
   space on the tab bar row is filled with a muted-colored status block:

       <cwd-of-active-window>  |  <short-hostname>  |  <HH:MM>

   - cwd: foreground process's cwd of the focused window, with `~`
     shorthand for $HOME.
   - host: first dotted segment of `socket.gethostname()`.
   - time: HH:MM (no seconds -- the tab bar only redraws on activity, not
     on a timer, so a minute-precision clock is the most you can trust).

Activated by `tab_bar_style custom` in kitty.conf. Kitty looks for this
file at `<kitty-config-dir>/tab_bar.py`, which on this machine resolves to
`~/dotfiles/initrc/kitty/tab_bar.py` via the `~/.config/kitty` symlink.
"""
from datetime import datetime
import os
import socket

from kitty.boss import get_boss
from kitty.fast_data_types import Screen
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
    draw_tab_with_powerline,
)

# Visible width each tab is padded / truncated to. Includes the bell and
# activity symbols from `tab_title_template` -- if those flicker on/off the
# tab will still wiggle by 1-2 cells, but the title-length component is
# pinned. Tune to taste.
TAB_WIDTH = 20

# Visual close-button affordance drawn at the right edge of every tab.
# kitty has no per-character mouse mapping inside a tab, so this glyph
# would only ever be decorative -- the real close action is middle-click
# anywhere on the tab. Disabled (empty string) by default to keep tabs
# uncluttered. Set to e.g. ' ×' if you want the visual hint back; the
# title shrinks to (TAB_WIDTH - len(CLOSE_GLYPH)) cells to compensate.
CLOSE_GLYPH = ''

# Muted slate -- intentionally darker than the active-tab fg so the status
# block doesn't compete for attention with what you're actually doing.
STATUS_FG = 0x7e7e96

_HOME = os.path.expanduser('~')


def _active_cwd() -> str:
    """cwd of the foreground process in the currently focused window.

    Returns '?' if anything along the boss/tab/window/child chain is None
    (which happens during early kitty init, after the focused window has
    been closed mid-draw, etc.). Never raises -- a draw_tab that throws
    will leave a corrupted tab bar until the next config reload.
    """
    boss = get_boss()
    if boss is None:
        return '?'
    tab = boss.active_tab
    if tab is None:
        return '?'
    win = tab.active_window
    if win is None:
        return '?'
    cwd = getattr(win, 'cwd_of_child', None) or ''
    if not cwd:
        return '?'
    if cwd == _HOME:
        return '~'
    if cwd.startswith(_HOME + '/'):
        return '~' + cwd[len(_HOME):]
    return cwd


def _short_host() -> str:
    return socket.gethostname().split('.', 1)[0]


def _draw_status(screen: Screen) -> None:
    text = f'  {_active_cwd()}  |  {_short_host()}  |  {datetime.now():%H:%M}  '
    avail = screen.columns - screen.cursor.x
    if avail <= 0:
        return
    if len(text) > avail:
        # Truncate from the left of the cwd so host+time always survive.
        text = text[-avail:]
    pad = avail - len(text)
    if pad > 0:
        screen.draw(' ' * pad)
    screen.cursor.fg = as_rgb(STATUS_FG)
    screen.draw(text)


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    # Pin tab width by padding/truncating the rendered title. The title
    # gets (TAB_WIDTH - len(CLOSE_GLYPH)) cells; the trailing CLOSE_GLYPH
    # is appended to fill the rest as a visual close-button affordance.
    title_room = TAB_WIDTH - len(CLOSE_GLYPH)
    fixed = tab.title.ljust(title_room)[:title_room] + CLOSE_GLYPH
    tab = tab._replace(title=fixed)

    end = draw_tab_with_powerline(
        draw_data, screen, tab,
        before, max_title_length, index, is_last, extra_data,
    )
    if is_last:
        _draw_status(screen)
    return end
