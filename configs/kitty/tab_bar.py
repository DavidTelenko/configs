import subprocess
import datetime

from kitty.fast_data_types import Screen, add_timer
from kitty.boss import get_boss
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    Formatter,
    PowerlineStyle,
    TabBarData,
    as_rgb,
    draw_attributed_string,
    draw_title,
)

TIMER_ID = None


def _redraw_tab_bar(timer_id):
    for tm in get_boss().all_tab_managers:
        tm.mark_tab_bar_dirty()


powerline_symbols: dict[PowerlineStyle, str] = {
    "slanted": "",
    "round": "",
}


def draw_tab_with_powerline(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    tab_bg = screen.cursor.bg
    tab_fg = screen.cursor.fg
    default_bg = as_rgb(int(draw_data.default_bg))

    if extra_data.next_tab:
        next_tab_bg = as_rgb(draw_data.tab_bg(extra_data.next_tab))
        needs_soft_separator = next_tab_bg == tab_bg
    else:
        next_tab_bg = default_bg
        needs_soft_separator = False

    separator_symbol = powerline_symbols.get(draw_data.powerline_style, "")
    min_title_length = 1 + 2
    start_draw = 2

    if screen.cursor.x == 0:
        screen.cursor.bg = tab_bg
        screen.draw(" ")
        start_draw = 1

    screen.cursor.bg = tab_bg
    if min_title_length >= max_tab_length:
        screen.draw("…")
    else:
        draw_title(draw_data, screen, tab, index, max_tab_length)
        extra = screen.cursor.x + start_draw - before - max_tab_length
        if extra > 0 and extra + 1 < screen.cursor.x:
            screen.cursor.x -= extra + 1
            screen.draw("…")

    if not needs_soft_separator:
        screen.draw(" ")
        screen.cursor.fg = tab_bg
        screen.cursor.bg = next_tab_bg
        screen.draw(separator_symbol)
    else:
        prev_fg = screen.cursor.fg
        if tab_bg == tab_fg:
            screen.cursor.fg = default_bg
        elif tab_bg != default_bg:
            c1 = draw_data.inactive_bg.contrast(draw_data.default_bg)
            c2 = draw_data.inactive_bg.contrast(draw_data.inactive_fg)
            if c1 < c2:
                screen.cursor.fg = default_bg
        screen.draw(" ")
        screen.cursor.fg = prev_fg

    end = screen.cursor.x
    if end < screen.columns:
        screen.draw(" ")
    return end


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
    global TIMER_ID

    if TIMER_ID is None:
        TIMER_ID = add_timer(_redraw_tab_bar, 0.1, True)

    draw_tab_with_powerline(
        draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
    )
    if is_last:
        draw_right_status(draw_data, screen)
    return screen.cursor.x


def draw_right_status(draw_data: DrawData, screen: Screen) -> None:
    # The tabs may have left some formats enabled. Disable them now.
    draw_attributed_string(Formatter.reset, screen)

    cells = create_cells(draw_data)
    cells = [cell for cell in cells if len(cell["data"]) != 0]

    if not cells:
        return

    # Drop cells that wont fit
    while True:
        padding = (
            screen.columns
            - screen.cursor.x
            - sum(len(cell["data"]) + 3 for cell in cells)
        )
        if padding >= 0:
            break
        cells = cells[1:]

    if padding:
        screen.draw(" " * padding)

    for cell in cells:
        bg = as_rgb(int(cell["bg"]))
        fg = as_rgb(int(cell["fg"]))

        # Draw the separator
        screen.cursor.fg = bg
        screen.draw("")

        screen.cursor.bg = bg
        screen.cursor.fg = fg
        screen.draw(f" {cell["data"]} ")


def get_git_branch() -> str | None:
    tab_manager = get_boss().active_tab_manager
    if not tab_manager or not tab_manager.active_window:
        return None

    cwd = tab_manager.active_window.cwd_of_child
    if not cwd:
        return None

    try:
        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True,
            cwd=cwd,
            text=True,
            timeout=0.1,
            check=True,
        )
        if result.returncode == 0:
            branch = result.stdout.strip()
            return branch
    except:
        return None

    return None


def create_cells(draw_data: DrawData) -> list[dict[str, str]]:
    branch = get_git_branch()
    return [
        {
            "data": branch and f" {branch}" or "",
            "bg": draw_data.inactive_bg,
            "fg": draw_data.inactive_fg,
        },
        {
            "data": datetime.datetime.now().strftime(" %H:%M - %a %d"),
            "bg": draw_data.active_bg,
            "fg": draw_data.active_fg,
        },
    ]
