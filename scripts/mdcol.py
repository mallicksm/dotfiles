#!/usr/bin/env python3.11
"""mdcol — fit markdown tables to a column budget.

Walks a markdown source file, finds GitHub-style pipe tables, and
re-renders any table that overflows the configured width budget. The
widest column is shrunk repeatedly (longest unbreakable token in the
column is the lower bound) and over-long cells word-wrap into
continuation rows whose other cells are blank-padded — same strategy
as `pdf2md.py:_fit_widths` / `_wrap_cell`.

Non-table content (prose, code fences, lists, etc.) is passed through
verbatim. Code fences and indented code blocks are honored so tables
embedded in them are not touched.

Usage:
    mdcol.py [-w 150] [-i] [FILE]
        FILE        markdown file (or '-' / omitted -> stdin)
        -w / --width   total source-column budget per row (default 150)
        -i / --in-place   rewrite FILE in place
        --check     exit 1 if any table would change; useful for CI

Idempotent: running on already-fit tables produces identical output.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


# ---------- table detection ---------------------------------------------

# Row: starts and ends with a pipe (after optional leading whitespace).
# Allow inner cells to contain anything; pipes inside cells must be
# escaped as \|.
_ROW_RE = re.compile(r"^[ \t]*\|.*\|[ \t]*$")
# Separator row: pipes + dashes + colons + whitespace only, must contain
# at least one `-` and at least one `|`.
_SEP_RE = re.compile(r"^[ \t]*\|[ \t\-:|]+\|[ \t]*$")
# Code-fence detector: ```... or ~~~... (any length >= 3).
_FENCE_RE = re.compile(r"^([ \t]*)(`{3,}|~{3,})")
# Cell splitter: split on un-escaped `|`.
_CELL_SPLIT_RE = re.compile(r"(?<!\\)\|")


def _is_separator(line: str) -> bool:
    if not _SEP_RE.match(line):
        return False
    return "-" in line


def _parse_cells(line: str) -> list[str]:
    """Strip leading/trailing pipe(s) and split into cells."""
    body = line.strip()
    if body.startswith("|"):
        body = body[1:]
    if body.endswith("|"):
        body = body[:-1]
    cells = _CELL_SPLIT_RE.split(body)
    return [c.strip() for c in cells]


def _parse_alignments(sep_cells: list[str]) -> list[str]:
    """Return one of 'l' | 'r' | 'c' | 'n' (none) per column."""
    out: list[str] = []
    for c in sep_cells:
        s = c.strip()
        left = s.startswith(":")
        right = s.endswith(":")
        if left and right:
            out.append("c")
        elif right:
            out.append("r")
        elif left:
            out.append("l")
        else:
            out.append("n")
    return out


# ---------- fit + wrap (from pdf2md.py) ---------------------------------

MIN_COL_FLOOR = 3       # smallest sensible column ("---" fits)
MAX_TOKEN_LOWER = 40    # cap per-column min so a single long token can't
                         # forbid all shrinkage on its column


def _wrap_cell(text: str, width: int) -> list[str]:
    """Word-wrap to `width` chars per line. Tokens longer than width
    overflow rather than being chopped (preserves signal names, code
    spans, urls)."""
    if width <= 0:
        width = 1
    out: list[str] = []
    line = ""
    for word in text.split():
        if not line:
            line = word
        elif len(line) + 1 + len(word) <= width:
            line += " " + word
        else:
            out.append(line)
            line = word
    if line:
        out.append(line)
    return out or [""]


def _fit_widths(natural: list[int], budget: int, mins: list[int]) -> list[int]:
    """Shrink the widest (most-slack) column repeatedly until rendered
    width fits the budget. Rendered width = 1 + 3*N + sum(widths)."""
    n = len(natural)
    overhead = 1 + 3 * n
    avail = budget - overhead
    widths = list(natural)
    if sum(widths) <= avail:
        return widths
    while sum(widths) > avail:
        idx = max(
            range(n),
            key=lambda i: (widths[i] - mins[i], widths[i]),
        )
        if widths[idx] <= mins[idx]:
            break
        widths[idx] -= 1
    return widths


def _column_minimums(rows: list[list[str]], cols: int) -> list[int]:
    longest = [MIN_COL_FLOOR] * cols
    for row in rows:
        for i, c in enumerate(row[:cols]):
            for w in c.split():
                if len(w) > longest[i]:
                    longest[i] = len(w)
    return [min(MAX_TOKEN_LOWER, max(MIN_COL_FLOOR, lw)) for lw in longest]


def _natural_widths(rows: list[list[str]], cols: int) -> list[int]:
    nat = [MIN_COL_FLOOR] * cols
    for row in rows:
        for i, c in enumerate(row[:cols]):
            if len(c) > nat[i]:
                nat[i] = len(c)
    return nat


def _pad_cell(text: str, width: int, align: str) -> str:
    if align == "r":
        return text.rjust(width)
    if align == "c":
        pad = max(0, width - len(text))
        l = pad // 2
        r = pad - l
        return " " * l + text + " " * r
    return text.ljust(width)


def _render_separator(widths: list[int], aligns: list[str]) -> str:
    parts: list[str] = []
    for w, a in zip(widths, aligns):
        if a == "c":
            inner = ":" + "-" * max(1, w - 2) + ":"
        elif a == "r":
            inner = "-" * max(2, w - 1) + ":"
        elif a == "l":
            inner = ":" + "-" * max(2, w - 1)
        else:
            inner = "-" * max(3, w)
        # Pad/truncate to exactly w
        if len(inner) < w:
            inner = inner + "-" * (w - len(inner))
        elif len(inner) > w:
            inner = inner[:w]
        parts.append(inner)
    return "| " + " | ".join(parts) + " |"


def _render_data_row(cells: list[str], widths: list[int], aligns: list[str]) -> list[str]:
    wrapped = [_wrap_cell(cells[i] if i < len(cells) else "", widths[i]) for i in range(len(widths))]
    height = max(len(w) for w in wrapped)
    out: list[str] = []
    for h in range(height):
        rendered_cells: list[str] = []
        for i, w in enumerate(wrapped):
            seg = w[h] if h < len(w) else ""
            rendered_cells.append(_pad_cell(seg, widths[i], aligns[i]))
        out.append("| " + " | ".join(rendered_cells) + " |")
    return out


# ---------- table block reformatting ------------------------------------

def _reflow_table(header: str, sep: str, body: list[str], budget: int) -> list[str]:
    """Return the new lines for one table block. Number of columns is
    locked to the header's cell count."""
    header_cells = _parse_cells(header)
    cols = len(header_cells)
    sep_cells = _parse_cells(sep)
    # Pad / truncate sep to header width
    while len(sep_cells) < cols:
        sep_cells.append("---")
    sep_cells = sep_cells[:cols]
    aligns = _parse_alignments(sep_cells)
    body_rows = []
    for line in body:
        cells = _parse_cells(line)
        while len(cells) < cols:
            cells.append("")
        body_rows.append(cells[:cols])
    all_data_rows = [header_cells] + body_rows
    natural = _natural_widths(all_data_rows, cols)
    mins = _column_minimums(all_data_rows, cols)
    widths = _fit_widths(natural, budget, mins)

    out: list[str] = []
    out.extend(_render_data_row(header_cells, widths, aligns))
    out.append(_render_separator(widths, aligns))
    for row in body_rows:
        out.extend(_render_data_row(row, widths, aligns))
    return out


# ---------- main walker -------------------------------------------------

def process(lines: list[str], budget: int) -> tuple[list[str], int]:
    """Return (new_lines, n_tables_changed)."""
    out: list[str] = []
    i = 0
    n = len(lines)
    in_fence: str | None = None
    changed = 0

    while i < n:
        line = lines[i]

        # Code-fence tracking
        m = _FENCE_RE.match(line)
        if m:
            tok = m.group(2)
            if in_fence is None:
                in_fence = tok[0] * 3
                out.append(line)
                i += 1
                continue
            if line.lstrip().startswith(in_fence):
                in_fence = None
                out.append(line)
                i += 1
                continue
        if in_fence is not None:
            out.append(line)
            i += 1
            continue

        # Table detection: header row + separator on next line
        if (
            i + 1 < n
            and _ROW_RE.match(line)
            and _is_separator(lines[i + 1])
        ):
            header = line
            sep = lines[i + 1]
            body: list[str] = []
            j = i + 2
            while j < n and _ROW_RE.match(lines[j]):
                body.append(lines[j])
                j += 1
            new_block = _reflow_table(header, sep, body, budget)
            old_block = [header, sep] + body
            if new_block != old_block:
                changed += 1
            out.extend(new_block)
            i = j
            continue

        out.append(line)
        i += 1

    return out, changed


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Fit markdown tables to a column-width budget by shrinking the widest column.",
        epilog=(
            "examples:\n"
            "  mdcol.py -i -w 150 MAC100G_REGS.md       rewrite in place at 150-col budget\n"
            "  mdcol.py -w 120 some.md                  custom budget, write to stdout\n"
            "  mdcol.py --check -w 150 *.md             CI guard: exit 1 on any overflow\n"
            "  cat foo.md | mdcol.py -w 100             stdin -> stdout\n"
            "\n"
            "behavior:\n"
            "  - Only GFM pipe tables (rows that start AND end with '|') are touched;\n"
            "    prose, code fences, and lists pass through verbatim.\n"
            "  - The widest column is shrunk first (per-column floor = longest unbreakable\n"
            "    token, capped at 40 chars) until 1 + 3*N + sum(widths) <= budget.\n"
            "  - Over-long cells word-wrap onto continuation rows with the other cells\n"
            "    blank-padded; signal names / inline code spans are never chopped.\n"
            "  - Separator alignment markers (:---, ---:, :---:) are preserved.\n"
            "  - Idempotent: running twice is a no-op.\n"
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument("file", nargs="?", default="-",
                    help="markdown file (default '-' = stdin)")
    ap.add_argument("-w", "--width", type=int, default=150,
                    help="total source-column budget per row (default 150)")
    ap.add_argument("-i", "--in-place", action="store_true",
                    help="rewrite FILE in place")
    ap.add_argument("--check", action="store_true",
                    help="exit 1 if any table would change; do not write output")
    args = ap.parse_args()

    if args.file == "-" or args.file == "":
        if args.in_place:
            print("mdcol: --in-place requires a file argument", file=sys.stderr)
            return 2
        src = sys.stdin.read()
        path = None
    else:
        path = Path(args.file)
        if not path.exists():
            print(f"mdcol: {path}: no such file", file=sys.stderr)
            return 2
        src = path.read_text()

    # Preserve original trailing newline state
    had_final_newline = src.endswith("\n")
    lines = src.splitlines()
    new_lines, changed = process(lines, args.width)
    out = "\n".join(new_lines)
    if had_final_newline:
        out += "\n"

    if args.check:
        if changed:
            print(f"mdcol: {changed} table(s) would change", file=sys.stderr)
            return 1
        return 0

    if args.in_place:
        assert path is not None
        path.write_text(out)
        print(f"mdcol: {path} ({changed} table(s) reflowed, budget={args.width})",
              file=sys.stderr)
    else:
        sys.stdout.write(out)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
