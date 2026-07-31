#!/usr/bin/env python3.11
# pdf2md.py -- standalone PDF -> Markdown converter (PyMuPDF / fitz based).
#
# Headings come from the PDF outline (or are synthesized from font sizes),
# tables are extracted with find_tables() and rendered as fenced markdown
# (Synopsys signal-name repair, column-budget fitting, continuation merging),
# and full-width figures are cropped to PNGs under images/<stem>/.
#
# This is the conversion core lifted verbatim from ~/.local/bin/snps_pdf2md.py
# (class Pdf2MdConverter); the Synopsys doc-discovery / setup.sh-staging shell
# around it has been dropped. Just: one PDF in, one .md (+ figure PNGs) out.
#
# Usage:
#   pdf2md.py INPUT.pdf                 # -> INPUT.md + images/INPUT/ beside it
#   pdf2md.py INPUT.pdf -o OUT.md       # -> OUT.md, images under OUT dir
#   pdf2md.py INPUT.pdf --images-dir D  # -> figure PNGs into D
#
# Requirements (single external dep -- everything else is stdlib):
#   - python >= 3.11               # interpreter (see shebang)
#   - pymupdf                      # `import fitz`, required. pip install --user pymupdf
#   - pymupdf-layout               # OPTIONAL: better table detection; falls back if absent.
#                                    pip install --user pymupdf-layout

from __future__ import annotations

import argparse
import collections  # noqa: F401  (used as collections.Counter in table_to_md)
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import List, Optional, Tuple

import fitz

# Activate pymupdf_layout (ONNX-based) so find_tables() / layout analysis use the
# improved analyzer. Importing the submodule wires pymupdf._get_layout. The
# fallback (just silencing the advisory) is used if the package isn't installed.
try:
   import pymupdf.layout  # noqa: F401  (import has the side effect of activating)
except ImportError:
   if hasattr(fitz, 'no_recommend_layout'):
      fitz.no_recommend_layout()


_NUMBERED_HEADING_RE = re.compile(r'^(\d+(?:\.\d+){0,5})$')
_HEADING_INLINE_RE = re.compile(r'^(\d+(?:\.\d+){0,5})\s+(.+)$')
_FIGURE_CAPTION_RE = re.compile(r'^Figure\s+(\d+(?:[-.]\d+)?)\s*[:\-—–]?\s*(.{2,200}?)\s*$')
_TABLE_CAPTION_RE = re.compile(r'^Table\s+(\d+(?:[-.]\d+)?)\s*[:\-—–]?\s*(.{2,200}?)\s*$')
_PAGE_FOOTER_PATTERNS = [
   re.compile(r'^Synopsys,?\s+Inc\.?$'),
   re.compile(r'^Version\s+\S+$'),
   re.compile(r'^(January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{4}$'),
   re.compile(r'^\d{1,3}$'),
]
_DOC_TITLE_LINE_RE = re.compile(r'^\d+-Port\s+\d+G\b.+$')

_TABLE_BUDGET = 150
_MIN_COL_WIDTH = 6

# Repairs Synopsys-style signal names: `ff tx valid i _ _ _` -> `ff_tx_valid_i`.
# A token may optionally carry a `[X:Y]` subscript or a `()` call suffix.
_WORD_RE = r'[A-Za-z0-9][A-Za-z0-9<>#/]*(?:\[[^\]]+\]|\([^)]*\))?'
_SIGNAL_TRAILING_UNDERSCORES = re.compile(
   rf'((?:\b{_WORD_RE})(?:\s+{_WORD_RE}){{1,15}})((?:\s+_){{1,15}})(?!\w)'
)

# Match signal-subscript brackets `[3:0]`, `[N-1:0]`, `[i+1]`, etc. (no spaces).
# Lookbehind/ahead for `` ` `` and `\` keeps the regex idempotent over the file.
# Spaces in real markdown link text (`[Chapter 1](#…)`) disqualify the match.
_BRACKETED_SUBSCRIPT_RE = re.compile(r'(?<![`\\])\[([\w+\-:/*]+)\](?!`)')

# Cells whose entire content is only whitespace + `- , .` are extractor noise
# (stray dot leaders, isolated hyphens, alignment artifacts). Cleared to '' so
# the column-pruning step in table_to_md can drop the column if all cells go.
_TABLE_CELL_NOISE_RE = re.compile(r'^[\s\-,.]+$')

# Runs of 2+ consecutive punctuation chars (.,-) separated only by spaces.
# Catches dot leaders (`.. `, `. . . `), dash separators (`--`, `- - -`), and
# trailing junk (`PCS Status (10 100G) ..`). Single periods / hyphens / commas
# stay (so legit text like `1.0 GHz`, `foo-bar`, `i,j,k` is untouched).
_PUNCT_LEADER_RUN_RE = re.compile(r'(?:\s*[.,\-]){2,}\s*')


@dataclass
class HeadingHit:
   level: int
   section: str  # "1.1.1" or "" for non-numbered
   title: str
   page: int  # 1-indexed


@dataclass
class PageItem:
   y: float
   kind: str  # "heading" | "text" | "table" | "figure" | "note"
   payload: str


@dataclass
class CaptionedItem:
   kind: str  # "figure" | "table"
   number: str  # e.g. "2-1" (or "auto-001")
   caption: str
   page: int  # 1-indexed
   anchor: str


@dataclass
class DocState:
   out_dir: Path
   images_dir: Path
   headings: List[HeadingHit] = field(default_factory=list)
   figures: List[CaptionedItem] = field(default_factory=list)
   tables: List[CaptionedItem] = field(default_factory=list)
   fig_index: int = 0


_FOOTER_BAND_PT = 80  # blocks whose top edge sits within this many pt of the page top, or bottom edge within this many pt of the page bottom, are candidate header/footer text


class Pdf2MdConverter:

   # Set per-convert(): exact-match strings that appear in the page top/bottom
   # margin on 2+ pages (running header / footer / page number leftovers).
   _footers: frozenset = frozenset()

   # ---------- small helpers ----------

   def slugify(self, s: str) -> str:
      s = s.strip().lower()
      s = re.sub(r'[^\w\s-]', '', s)
      s = re.sub(r'[\s_-]+', '-', s).strip('-')
      return s or 'section'

   def is_footer_line(self, line: str) -> bool:
      s = line.strip()
      if not s:
         return False
      if s in self._footers:
         return True
      for pat in _PAGE_FOOTER_PATTERNS:
         if pat.match(s):
            return True
      if _DOC_TITLE_LINE_RE.match(s):
         return True
      return False

   # Walk every page; collect short text lines that sit in the top or bottom
   # _FOOTER_BAND_PT band on at least 2 pages. These are running headers/footers
   # the body shouldn't include.
   def collect_repeating_footers(self, doc) -> frozenset:
      from collections import Counter
      counts: 'Counter[str]' = Counter()
      for page in doc:
         y_top = page.rect.y0
         y_bot = page.rect.y1
         seen_on_page = set()
         for b in page.get_text('dict').get('blocks', []):
            if b.get('type') != 0:
               continue
            bx0, by0, bx1, by1 = b['bbox']
            # Block top-edge in top band, or block bottom-edge in bottom band.
            # Loose enough to catch multi-line headers/footers that extend past
            # the strict band, e.g. a "Functional Specification\nVersion x.y" block.
            in_top = by0 < y_top + _FOOTER_BAND_PT
            in_bot = by1 > y_bot - _FOOTER_BAND_PT
            if not (in_top or in_bot):
               continue
            for line in b.get('lines', []):
               text = ''.join(s.get('text', '') for s in line.get('spans', []))
               text = text.strip()
               if 0 < len(text) <= 200:
                  seen_on_page.add(text)
         for t in seen_on_page:
            counts[t] += 1
      return frozenset(t for t, n in counts.items() if n >= 2)

   def md_escape_cell(self, s: str) -> str:
      # Cells: escape pipes (table syntax) and newlines. Signal subscripts like
      # `[3:0]` are wrapped in backticks so the brackets render literally inside
      # the table (markdown code spans pass content through verbatim).
      s = s.replace('|', '\\|').replace('\n', ' ').strip()
      # Drop punctuation-only cells (e.g. `-`, `,`, `.`, `. . .` dot leaders).
      if _TABLE_CELL_NOISE_RE.match(s):
         return ''
      # Repair `foo bar baz [3:0] _ _ _` -> `foo_bar_baz[3:0]` BEFORE we wrap
      # subscripts in backticks — `_SIGNAL_TRAILING_UNDERSCORES` doesn't match
      # patterns that already contain backticks around the [X:Y] part.
      s = self.repair_signal_names(s)
      # Scrub runs of consecutive punctuation (dot leaders, dash separators,
      # trailing `..` junk). Replace each run with a single space and re-strip.
      s = _PUNCT_LEADER_RUN_RE.sub(' ', s).strip()
      if not s:
         return ''
      # Collapse PDF text-extraction artifact: a stray space before a single
      # punctuation mark (`SNo .` -> `SNo.`, `1 , 2` -> `1, 2` -> wait this
      # only kills the leading space, so `1 , 2` becomes `1, 2`).
      s = re.sub(r'\s+([.,;:])', r'\1', s)
      return _BRACKETED_SUBSCRIPT_RE.sub(r'`[\1]`', s)

   def _signal_repl(self, m: re.Match) -> str:
      words = re.findall(r'\S+', m.group(1))
      underscores = m.group(2).count('_')
      if underscores < 1:
         return m.group(0)
      n = underscores + 1
      if n > len(words):
         return '_'.join(words)
      head = words[:-n]
      tail = words[-n:]
      if len(tail) < 2:
         return m.group(0)
      joined = '_'.join(tail)
      if head:
         return ' '.join(head) + ' ' + joined
      return joined

   # `foo bar baz _ _` -> `foo_bar_baz`. Iterative.
   def repair_signal_names(self, text: str) -> str:
      prev = None
      cur = text
      for _ in range(4):
         if cur == prev:
            break
         prev = cur
         cur = _SIGNAL_TRAILING_UNDERSCORES.sub(self._signal_repl, cur)
      return cur

   # ---------- table extraction ----------

   # Word-wrap a cell to `width` chars per line.
   def _wrap_cell(self, text: str, width: int) -> List[str]:
      if width <= 0:
         width = 1
      out: List[str] = []
      line = ''
      for word in text.split():
         if not line:
            line = word
         elif len(line) + 1 + len(word) <= width:
            line += ' ' + word
         else:
            out.append(line)
            line = word
      if line:
         out.append(line)
      return out or ['']

   # Shrink widest column until rendered width fits the budget.
   def _fit_widths(self, natural: List[int], budget: int, mins: List[int]) -> List[int]:
      n = len(natural)
      overhead = 1 + 3 * n
      avail = budget - overhead
      widths = list(natural)
      if sum(widths) <= avail:
         return widths
      while sum(widths) > avail:
         idx = max(range(n), key=lambda i: (widths[i] - mins[i], widths[i]))
         if widths[idx] <= mins[idx]:
            break
         widths[idx] -= 1
      return widths

   def table_to_md(self, tab) -> str:
      # Build cell text via clip-extract (`page.get_text('text', clip=bbox)`).
      # pymupdf's `tab.extract()` drops inter-word spaces in many cells (worse
      # with pymupdf_layout active), turning `IP name` into `IPname` etc. The
      # clip approach honors the PDF's own glyph spacing and gives clean text.
      data: List[List[str]] = []
      try:
         page = tab.page
         rows = tab.rows
      except Exception:
         rows = []
      for row in rows:
         row_cells: List[str] = []
         for cell_bbox in (row.cells or []):
            if cell_bbox is None:
               row_cells.append('')
               continue
            try:
               txt = page.get_text('text', clip=fitz.Rect(*cell_bbox)).strip()
            except Exception:
               txt = ''
            row_cells.append(txt)
         if row_cells:
            data.append(row_cells)
      if not data or not data[0]:
         return ''
      cols = max(len(r) for r in data)
      norm: List[List[str]] = []
      for row in data:
         cells = [self.md_escape_cell(c or '') for c in row]
         while len(cells) < cols:
            cells.append('')
         norm.append(cells)
      keep = [any(row[ci] for row in norm) for ci in range(cols)]
      norm = [[c for c, k in zip(row, keep) if k] for row in norm]
      # Drop fully-empty rows (extractor occasionally injects blanks, especially
      # under pymupdf_layout); they otherwise render as `|   |   |` separators
      # that break some markdown viewers.
      norm = [row for row in norm if any(c for c in row)]
      # Collapse "orphan continuation" rows (only last column populated) into
      # the FOLLOWING data row's last column. pymupdf often splits a multi-line
      # cell into separate rows where only the last column carries text; merging
      # them keeps the row that owns the leading "S.No / IP name / etc." cells
      # together with its full description.
      norm = self._merge_orphan_continuation_rows(norm)
      # Merge multi-line headers ([Name|Width|||] + [||Depth|Type|...] -> one).
      norm = self._merge_multiline_header(norm)
      cols = len(norm[0]) if norm and norm[0] else 0
      if cols == 0 or not norm:
         return ''

      def can_merge(c1: int, c2: int) -> bool:
         return all(not (row[c1] and row[c2]) for row in norm)

      changed = True
      while changed and cols > 1:
         changed = False
         for i in range(cols - 1):
            if can_merge(i, i + 1):
               for row in norm:
                  merged = ' '.join(s for s in (row[i], row[i + 1]) if s)
                  row[i] = merged
                  del row[i + 1]
               cols -= 1
               changed = True
               break

      norm = [[self.repair_signal_names(c) for c in row] for row in norm]

      natural = [0] * cols
      longest_word = [_MIN_COL_WIDTH] * cols
      for row in norm:
         for i, c in enumerate(row):
            natural[i] = max(natural[i], len(c))
            for w in c.split():
               if len(w) > longest_word[i]:
                  longest_word[i] = len(w)
      mins = [min(longest_word[i], 40) for i in range(cols)]
      widths = self._fit_widths(natural, _TABLE_BUDGET, mins)

      # Render a row as a SINGLE markdown source line. Wrap each cell to its
      # column width, then join wrapped lines with `<br>` so the rendered table
      # shows the multi-line cell content while keeping one source line per
      # logical row (no extra rows-with-empty-leading-cells artifacts).
      def render_row(row: List[str]) -> str:
         wrapped = [self._wrap_cell(row[i], widths[i]) for i in range(cols)]
         cells = []
         for i, w in enumerate(wrapped):
            joined = '<br>'.join(line.strip() for line in w if line is not None)
            if len(joined) < widths[i]:
               joined = joined + ' ' * (widths[i] - len(joined))
            cells.append(joined)
         return '| ' + ' | '.join(cells) + ' |'

      lines: List[str] = []
      lines.append(render_row(norm[0]))
      lines.append('|' + '|'.join('-' * (widths[i] + 2) for i in range(cols)) + '|')
      for row in norm[1:]:
         lines.append(render_row(row))
      return '\n'.join(lines)

   # True if two bboxes overlap by more than 50% of the smaller area.
   @staticmethod
   def _bbox_overlap_significant(a: Tuple[float, float, float, float], b: Tuple[float, float, float, float]) -> bool:
      ix0, iy0 = max(a[0], b[0]), max(a[1], b[1])
      ix1, iy1 = min(a[2], b[2]), min(a[3], b[3])
      if ix0 >= ix1 or iy0 >= iy1:
         return False
      inter = (ix1 - ix0) * (iy1 - iy0)
      a_area = max(1.0, (a[2] - a[0]) * (a[3] - a[1]))
      b_area = max(1.0, (b[2] - b[0]) * (b[3] - b[1]))
      return inter > 0.5 * min(a_area, b_area)

   # Find tables on a page robustly. The default 'lines' strategy occasionally
   # returns tables whose `.bbox` accessor raises ("min() arg is an empty
   # sequence"); we then supplement with 'lines_strict' results that don't
   # overlap what we already kept. Returns list of (table, bbox) tuples.
   def _find_tables_safe(self, page) -> List[Tuple[object, Tuple[float, float, float, float]]]:
      out: List[Tuple[object, Tuple[float, float, float, float]]] = []
      seen: List[Tuple[float, float, float, float]] = []
      try:
         raw = list(page.find_tables().tables)
      except Exception:
         raw = []
      had_broken = False
      for t in raw:
         try:
            bb = t.bbox
         except Exception:
            had_broken = True
            continue
         out.append((t, bb))
         seen.append(bb)
      if had_broken or not out:
         try:
            raw = list(page.find_tables(strategy='lines_strict').tables)
         except Exception:
            raw = []
         for t in raw:
            try:
               bb = t.bbox
            except Exception:
               continue
            if any(self._bbox_overlap_significant(bb, prev) for prev in seen):
               continue
            out.append((t, bb))
            seen.append(bb)
      return out

   # Count markdown table columns by splitting a `| a | b | c |` row on `|`.
   @staticmethod
   def _md_table_col_count(line: str) -> int:
      if not line.startswith('|'):
         return 0
      parts = line.split('|')
      if parts and parts[0] == '':
         parts = parts[1:]
      if parts and parts[-1] == '':
         parts = parts[:-1]
      return len(parts)

   @staticmethod
   def _is_md_alignment_row(line: str) -> bool:
      return bool(re.match(r'^\|(?:\s*:?-+:?\s*\|)+\s*$', line))

   # Merge consecutive markdown tables where the second has the same column count
   # AND no `_Table N — caption_` italic line between them. This stitches together
   # tables that span page breaks (pymupdf returns each page's slice separately;
   # only the first slice gets a caption). Continuation slices have no real
   # header row — pymupdf treats their first data row as a header — so every
   # non-separator row of a continuation is appended as data.
   def _merge_continuation_tables(self, md_text: str) -> str:
      lines = md_text.splitlines()
      out: List[str] = []
      i = 0
      while i < len(lines):
         ln = lines[i]
         if not ln.startswith('|'):
            out.append(ln)
            i += 1
            continue
         t_start = i
         while i < len(lines) and lines[i].startswith('|'):
            i += 1
         merged = list(lines[t_start:i])
         first_cols = self._md_table_col_count(merged[0]) if merged else 0
         # Look ahead for one or more continuation tables (multi-page).
         while True:
            j = i
            while j < len(lines) and lines[j].strip() == '':
               j += 1
            if j >= len(lines) or not lines[j].startswith('|'):
               break
            c_start = j
            while j < len(lines) and lines[j].startswith('|'):
               j += 1
            cont_block = lines[c_start:j]
            if not cont_block:
               break
            if self._md_table_col_count(cont_block[0]) != first_cols:
               break
            cont_data = [r for r in cont_block if not self._is_md_alignment_row(r)]
            if not cont_data:
               break
            merged.extend(cont_data)
            i = j
         out.extend(merged)
      return '\n'.join(out)

   # If the first few rows have complementary populated cells (each row only
   # fills cells the others leave empty, no collisions), merge them into a
   # single header row. Catches Synopsys multi-line headers where pymupdf
   # splits e.g. "Name | Width | Depth | Type" across two PDF text lines and
   # returns them as two separate rows with empty cells in the gaps.
   def _merge_multiline_header(self, norm: List[List[str]]) -> List[List[str]]:
      if not norm or len(norm) < 2:
         return norm
      n_cols = len(norm[0])
      header = list(norm[0])
      merged_rows = 1
      max_scan = min(len(norm), 4)  # cap to avoid eating real data rows
      for r in range(1, max_scan):
         row = norm[r]
         if len(row) != n_cols:
            break
         collision = any(header[i] and row[i] for i in range(n_cols))
         if collision:
            break
         new_header = [header[i] if header[i] else row[i] for i in range(n_cols)]
         if new_header == header:
            break
         header = new_header
         merged_rows += 1
         if all(header):
            break
      if merged_rows == 1:
         return norm
      return [header] + norm[merged_rows:]

   # Merge rows whose only populated cell is the last column into the FOLLOWING
   # data row's last column (with " " as join separator). Trailing orphan rows
   # with no following data row are kept as-is.
   def _merge_orphan_continuation_rows(self, norm: List[List[str]]) -> List[List[str]]:
      if not norm:
         return norm
      out: List[List[str]] = []
      pending: List[str] = []
      for row in norm:
         first_cells_have_data = any(row[:-1])
         last_only = (not first_cells_have_data) and bool(row[-1])
         if last_only:
            pending.append(row[-1])
            continue
         if pending and first_cells_have_data:
            merged = ' '.join(pending + ([row[-1]] if row[-1] else []))
            new_row = list(row)
            new_row[-1] = merged
            out.append(new_row)
            pending = []
         else:
            out.append(list(row))
      if pending:
         n_cols = len(out[0]) if out else 1
         out.append([''] * (n_cols - 1) + [' '.join(pending)])
      return out

   # ---------- outline / heading map ----------

   def parse_outline(self, toc: List[list]) -> List[HeadingHit]:
      out: List[HeadingHit] = []
      for level, raw_title, page in toc:
         title = raw_title.strip()
         m = re.match(r'^(\d+(?:\.\d+)*)\s+(.+)$', title)
         if m:
            section, rest = m.group(1), m.group(2).strip()
         else:
            section, rest = '', title
         out.append(HeadingHit(level=level, section=section, title=rest, page=page))
      return out

   # Fallback when PDF has no outline: derive headings from font sizes.
   def synthesize_headings_from_fonts(self, doc) -> List[HeadingHit]:
      size_chars: 'collections.Counter[float]' = collections.Counter()
      for page in doc:
         for b in page.get_text('dict')['blocks']:
            if b.get('type') != 0:
               continue
            for line in b.get('lines', []):
               for s in line.get('spans', []):
                  text = s.get('text', '').strip()
                  if text:
                     size_chars[round(s.get('size', 0), 1)] += len(text)
      if not size_chars:
         return []
      body_size = size_chars.most_common(1)[0][0]
      heading_sizes = sorted({sz for sz in size_chars if sz > body_size + 0.5}, reverse=True)
      if not heading_sizes:
         return []
      size_to_level = {sz: min(i + 1, 6) for i, sz in enumerate(heading_sizes)}

      out: List[HeadingHit] = []
      seen_titles: set = set()
      for pi, page in enumerate(doc):
         for b in page.get_text('dict')['blocks']:
            if b.get('type') != 0:
               continue
            lines = b.get('lines', [])
            if not lines:
               continue
            max_size = 0.0
            text_acc: List[str] = []
            for line in lines:
               for s in line.get('spans', []):
                  sz = round(s.get('size', 0), 1)
                  if sz > max_size:
                     max_size = sz
                  text_acc.append(s.get('text', ''))
            if max_size not in size_to_level:
               continue
            title = re.sub(r'\s+', ' ', ' '.join(text_acc)).strip()
            if not title or len(title) > 200:
               continue
            key = (size_to_level[max_size], title.lower())
            if key in seen_titles:
               continue
            seen_titles.add(key)
            m = re.match(r'^(\d+(?:\.\d+)*)\s+(.+)$', title)
            section, rest = (m.group(1), m.group(2).strip()) if m else ('', title)
            out.append(HeadingHit(level=size_to_level[max_size], section=section, title=rest, page=pi + 1))
      return out

   # Scan a block for every heading occurrence (not just the first line). Headings
   # are sometimes preceded by blank lines (-> first line is "") or sit mid-block
   # between text paragraphs; both forms used to be missed. Returns a list of
   # (start_idx_in_block, consumed_lines, hit), in document order, with each
   # outline entry matched at most once per call.
   def find_headings_in_block(
      self, block_lines: List[str], page_num: int, headings: List[HeadingHit],
   ) -> List[Tuple[int, int, HeadingHit]]:
      candidates: List[Optional[HeadingHit]] = [h for h in headings if h.page == page_num]
      if not candidates or not block_lines:
         return []
      found: List[Tuple[int, int, HeadingHit]] = []
      i = 0
      n = len(block_lines)
      while i < n:
         first = block_lines[i].strip()
         if not first:
            i += 1
            continue
         matched: Optional[Tuple[HeadingHit, int, int]] = None  # (hit, consumed_lines, candidate_idx)
         for ci, h in enumerate(candidates):
            if h is None:
               continue
            if h.section:
               if first == h.section:
                  # Section number alone -> look for the title on a later non-empty line.
                  j = i + 1
                  while j < n and not block_lines[j].strip():
                     j += 1
                  if j < n:
                     nxt = block_lines[j].strip()
                     if nxt.lower() == h.title.lower() or nxt.lower().startswith(h.title.lower()[:30]):
                        matched = (h, j - i + 1, ci)
                        break
                  matched = (h, 1, ci)
                  break
               inline = _HEADING_INLINE_RE.match(first)
               if inline and inline.group(1) == h.section:
                  matched = (h, 1, ci)
                  break
            else:
               if first.lower() == h.title.lower():
                  matched = (h, 1, ci)
                  break
         if matched:
            hit, consumed, ci = matched
            found.append((i, consumed, hit))
            candidates[ci] = None
            i += consumed
         else:
            i += 1
      return found

   # Reflow + bullet-merge + note-quote a slice of block lines into a single
   # paragraph-blob string (drops figure/table caption lines along the way).
   def _text_payload(self, lines: List[str]) -> str:
      filtered: List[str] = []
      for s in lines:
         ss = s.strip()
         if _FIGURE_CAPTION_RE.match(ss) or _TABLE_CAPTION_RE.match(ss):
            continue
         filtered.append(s)
      paragraphs = self.reflow_paragraphs(filtered)
      paragraphs = self.merge_pending_bullets(paragraphs)
      paragraphs = self.process_note_paragraphs(paragraphs)
      return '\n\n'.join(p for p in paragraphs if p)

   def block_text_lines(self, block: dict) -> List[str]:
      out = []
      for line in block.get('lines', []):
         s = ''.join(span.get('text', '') for span in line.get('spans', []))
         out.append(s.rstrip())
      return out

   # Join soft-wrapped lines, keeping bullets and "Note" headers separate.
   def reflow_paragraphs(self, lines: List[str]) -> List[str]:
      paragraphs: List[str] = []
      buf: List[str] = []

      def flush():
         if buf:
            paragraphs.append(' '.join(s.strip() for s in buf if s.strip()))
            buf.clear()

      for raw in lines:
         s = raw.strip()
         if not s:
            flush()
            continue
         if self.is_footer_line(s):
            continue
         if s.startswith('■'):
            flush()
            paragraphs.append('- ' + s[1:].strip())
            continue
         if s.startswith('●') or s.startswith('•'):
            flush()
            paragraphs.append('- ' + s[1:].strip())
            continue
         if s.lower() == 'note':
            flush()
            paragraphs.append('__NOTE_START__')
            continue
         buf.append(s)
      flush()
      return paragraphs

   # Merge "- header" with the next continuation paragraph when short.
   def merge_pending_bullets(self, paragraphs: List[str]) -> List[str]:
      out: List[str] = []
      i = 0
      while i < len(paragraphs):
         p = paragraphs[i]
         if p.startswith('- ') and i + 1 < len(paragraphs):
            nxt = paragraphs[i + 1]
            if not nxt.startswith('- ') and not nxt.startswith('__'):
               out.append(p + ' ' + nxt)
               i += 2
               continue
         out.append(p)
         i += 1
      return out

   # __NOTE_START__ -> blockquote prefix for the following short paragraphs.
   def process_note_paragraphs(self, paragraphs: List[str]) -> List[str]:
      out: List[str] = []
      in_note = False
      for p in paragraphs:
         if p == '__NOTE_START__':
            in_note = True
            out.append('> **Note**')
            continue
         if in_note:
            if p.startswith('- '):
               out.append('> ' + p)
               continue
            if p and len(p) < 400 and not re.match(r'^\d', p):
               out.append('> ' + p)
               continue
            in_note = False
         out.append(p)
      return out

   # Render the figure to PNG. Clip to the image bbox + small padding (avoids
   # the empty whitespace from the old full-page-width clip). Render at
   # `scale = 5.0` (≈360 DPI equivalent); modest upscale above native PDF image
   # resolution but produces a meaningfully-sized PNG in markdown viewers that
   # display images at native pixel dimensions.
   def extract_full_width_figure(
      self,
      page,
      bbox: Tuple[float, float, float, float],
      out_path: Path,
      pad_below: float = 16.0,
      pad_above: float = 6.0,
      pad_x: float = 10.0,
      scale: float = 5.0,
   ) -> None:
      x0, y0, x1, y1 = bbox
      page_rect = page.rect
      clip = fitz.Rect(
         max(page_rect.x0, x0 - pad_x),
         max(page_rect.y0, y0 - pad_above),
         min(page_rect.x1, x1 + pad_x),
         min(page_rect.y1, y1 + pad_below),
      )
      pix = page.get_pixmap(matrix=fitz.Matrix(scale, scale), clip=clip, alpha=False)
      pix.save(str(out_path))

   # Look for a "Figure X-Y caption" line near the image block.
   def find_figure_caption_for_image(
      self, page_text: str, img_y0: float, blocks: List[dict],
   ) -> Optional[Tuple[str, str]]:
      candidates_below = [b for b in blocks if b.get('type') == 0 and b['bbox'][1] - img_y0 > -5 and b['bbox'][1] - img_y0 < 80]
      candidates_above = [b for b in blocks if b.get('type') == 0 and img_y0 - b['bbox'][3] > -5 and img_y0 - b['bbox'][3] < 60]
      for batch in (candidates_below, candidates_above):
         batch.sort(key=lambda b: abs(b['bbox'][1] - img_y0))
         for b in batch:
            for line in self.block_text_lines(b):
               m = _FIGURE_CAPTION_RE.match(line.strip())
               if m:
                  return m.group(1), m.group(2)
      return None

   # Look for "Table N: caption" immediately above the table bbox (Synopsys docs
   # often render the caption ~50-60pt above the first table row, so use a 70pt
   # window). Accepts `:`, `-`, `—`, `–` or whitespace as the separator.
   def find_table_caption(
      self, page_text_blocks: List[dict], table_bbox: Tuple[float, float, float, float],
   ) -> Optional[Tuple[str, str]]:
      ty0 = table_bbox[1]
      candidates = [b for b in page_text_blocks if b.get('type') == 0 and 0 < ty0 - b['bbox'][3] < 70]
      candidates.sort(key=lambda b: ty0 - b['bbox'][3])
      for b in candidates:
         for line in self.block_text_lines(b):
            m = _TABLE_CAPTION_RE.match(line.strip())
            if m:
               return m.group(1), m.group(2)
      return None

   # Pull title + version from the cover page (scan large-font spans).
   # Cover page is treated as the source of truth for the title even if some of
   # its lines match the running header detected on later pages.
   def get_cover_metadata(self, doc) -> Tuple[str, str]:
      page = doc[0]
      big_lines: List[Tuple[float, str]] = []
      version_line = ''
      for b in page.get_text('dict')['blocks']:
         for line in b.get('lines', []):
            text = ''.join(s.get('text', '') for s in line.get('spans', []))
            text = text.strip()
            if not text:
               continue
            sizes = [s.get('size', 0) for s in line.get('spans', [])]
            max_size = max(sizes) if sizes else 0
            y = line.get('bbox', [0, 0])[1]
            if max_size >= 13.5:
               big_lines.append((y, text))
            if text.lower().startswith('version '):
               version_line = text
      big_lines.sort(key=lambda t: t[0])
      title = ' — '.join(t for _, t in big_lines)
      return title, version_line

   # ---------- main convert ----------

   # Write <md_path> with markdown derived from <pdf_path>; figure PNGs go into <images_dir>.
   # Image references in the .md are relative to md_path.parent (the staged-pdf directory).
   def convert(self, pdf_path: Path, md_path: Path, images_dir: Path, dpi_scale: float = 5.0) -> Path:
      doc = fitz.open(str(pdf_path))
      out_dir = md_path.parent
      out_dir.mkdir(parents=True, exist_ok=True)
      images_dir.mkdir(parents=True, exist_ok=True)

      # Identify running page header/footer lines; used by is_footer_line below.
      self._footers = self.collect_repeating_footers(doc)

      state = DocState(out_dir=out_dir, images_dir=images_dir)
      state.headings = self.parse_outline(doc.get_toc())
      fallback_used = False
      if not state.headings:
         state.headings = self.synthesize_headings_from_fonts(doc)
         fallback_used = True

      first_content_page = None
      for h in state.headings:
         if h.title.lower() == 'preface' or (h.section and h.section.startswith('1') and h.level == 1):
            first_content_page = h.page
            break
      if first_content_page is None:
         first_content_page = state.headings[0].page if state.headings else 1

      title, version = self.get_cover_metadata(doc)
      md_lines: List[str] = []
      if title:
         md_lines.append(f'# {title}')
      if version:
         md_lines.append('')
         md_lines.append(f'_{version}_')
      md_lines.append('')
      md_lines.append(f'_Source PDF: `{pdf_path}`_')
      if fallback_used:
         md_lines.append('')
         md_lines.append('_(Headings synthesized from font sizes — PDF has no outline.)_')
      md_lines.append('')

      contents_placeholder = '@@CONTENTS@@'
      figures_placeholder = '@@LIST_OF_FIGURES@@'
      tables_placeholder = '@@LIST_OF_TABLES@@'
      md_lines.append(contents_placeholder)
      md_lines.append('')
      md_lines.append(figures_placeholder)
      md_lines.append('')
      md_lines.append(tables_placeholder)
      md_lines.append('')

      for pi in range(first_content_page - 1, doc.page_count):
         page = doc[pi]
         page_num = pi + 1
         items: List[PageItem] = []

         # Use the robust finder: fallback to 'lines_strict' when default
         # strategy returns tables with broken bboxes (pymupdf bug).
         pairs = self._find_tables_safe(page)
         tables = [p[0] for p in pairs]
         table_bboxes = [p[1] for p in pairs]

         d = page.get_text('dict')
         blocks = d['blocks']

         figures_on_page: List[Tuple[float, str, str, Tuple[float, float, float, float]]] = []
         for b in blocks:
            if b.get('type') != 1:
               continue
            x0, y0, x1, y1 = b['bbox']
            w, h = x1 - x0, y1 - y0
            # Keep if area >= 10000pt² and both dimensions >= 60pt. Area filter
            # accepts tall-narrow flowcharts (e.g. 122x447) that the old strict
            # 200x100 minimums dropped; min-dim filter still rejects thin bars
            # (500x10) and tiny icons (50x50).
            if w * h < 10000 or w < 60 or h < 60:
               continue
            cap = self.find_figure_caption_for_image(page.get_text(), y0, blocks)
            if cap:
               fig_num, caption = cap
            else:
               state.fig_index += 1
               fig_num = f'auto-{state.fig_index:03d}'
               caption = ''
            # Pass the IMAGE bbox (not page-width). extract_full_width_figure
            # expands it horizontally by `pad_x` for any side labels.
            bbox = (x0, y0, x1, y1)
            figures_on_page.append((y0, fig_num, caption, bbox))

         for y0, fig_num, caption, bbox in figures_on_page:
            safe = re.sub(r'[^\w-]+', '-', fig_num).strip('-')
            out_path = images_dir / f'figure-{safe}.png'
            self.extract_full_width_figure(page, bbox, out_path, scale=dpi_scale)
            rel = out_path.relative_to(out_dir).as_posix()
            alt = f'Figure {fig_num}' + (f' — {caption}' if caption else '')
            anchor = f'figure-{safe.lower()}'
            md = f'<a id="{anchor}"></a>\n![{alt}]({rel})'
            if caption:
               md = f'<a id="{anchor}"></a>\n_{alt}_\n\n![{alt}]({rel})'
            items.append(PageItem(y=y0, kind='figure', payload=md))
            state.figures.append(
               CaptionedItem(kind='figure', number=fig_num, caption=caption, page=page_num, anchor=anchor)
            )

         for tab, tab_bbox in zip(tables, table_bboxes):
            try:
               md = self.table_to_md(tab)
            except Exception:
               continue
            if not md:
               continue
            cap = self.find_table_caption(blocks, tab_bbox)
            if cap:
               num, caption = cap
               safe = re.sub(r'[^\w-]+', '-', num).strip('-').lower()
               anchor = f'table-{safe}'
               items.append(PageItem(
                  y=tab_bbox[1],
                  kind='table',
                  payload=f'<a id="{anchor}"></a>\n_Table {num} — {caption}_\n\n{md}',
               ))
               state.tables.append(
                  CaptionedItem(kind='table', number=num, caption=caption, page=page_num, anchor=anchor)
               )
            else:
               items.append(PageItem(y=tab_bbox[1], kind='table', payload=md))

         for b in blocks:
            if b.get('type') != 0:
               continue
            bx0, by0, bx1, by1 = b['bbox']
            inside_table = any(
               bx0 >= tb[0] - 2 and bx1 <= tb[2] + 2 and by0 >= tb[1] - 2 and by1 <= tb[3] + 2
               for tb in table_bboxes
            )
            lines = self.block_text_lines(b)
            if not lines:
               continue
            heading_hits = self.find_headings_in_block(lines, page_num, state.headings)
            # Always emit headings — even when the block sits inside a table bbox
            # (pymupdf_layout sometimes draws table bboxes large enough to swallow
            # surrounding headings; we want the `####` line either way).
            if heading_hits:
               last = 0
               for start, consumed, hit in heading_hits:
                  if not inside_table:
                     pre_text = self._text_payload(lines[last:start])
                     if pre_text.strip():
                        items.append(PageItem(y=by0, kind='text', payload=pre_text))
                  anchor_text = (hit.section + ' ' + hit.title).strip() if hit.section else hit.title
                  items.append(PageItem(
                     y=by0,
                     kind='heading',
                     payload=f"{'#' * hit.level} {anchor_text}",
                  ))
                  last = start + consumed
               if not inside_table:
                  tail_text = self._text_payload(lines[last:])
                  if tail_text.strip():
                     items.append(PageItem(y=by0, kind='text', payload=tail_text))
            elif not inside_table:
               text = self._text_payload(lines)
               if text.strip():
                  items.append(PageItem(y=by0, kind='text', payload=text))

         items.sort(key=lambda it: it.y)
         for it in items:
            md_lines.append(it.payload)
            md_lines.append('')

      contents_lines = ['## Contents', '']
      for h in state.headings:
         if h.page < first_content_page:
            continue
         if h.title.lower() == 'contents':
            continue
         anchor_text = (h.section + ' ' + h.title).strip() if h.section else h.title
         anchor = self.slugify(anchor_text)
         indent = '  ' * (h.level - 1)
         contents_lines.append(f'{indent}- [{anchor_text}](#{anchor})')
      if state.figures:
         contents_lines.append('- [List of Figures](#list-of-figures)')
      if state.tables:
         contents_lines.append('- [List of Tables](#list-of-tables)')

      figures_lines: List[str] = []
      if state.figures:
         figures_lines.append('## List of Figures')
         figures_lines.append('')
         for fi in state.figures:
            label = f'Figure {fi.number}' + (f' — {fi.caption}' if fi.caption else '')
            figures_lines.append(f'- [{label}](#{fi.anchor})  _(p. {fi.page})_')

      tables_lines: List[str] = []
      if state.tables:
         tables_lines.append('## List of Tables')
         tables_lines.append('')
         for ti in state.tables:
            label = f'Table {ti.number}' + (f' — {ti.caption}' if ti.caption else '')
            tables_lines.append(f'- [{label}](#{ti.anchor})  _(p. {ti.page})_')

      md_text = '\n'.join(md_lines)
      md_text = md_text.replace(contents_placeholder, '\n'.join(contents_lines))
      md_text = md_text.replace(figures_placeholder, '\n'.join(figures_lines))
      md_text = md_text.replace(tables_placeholder, '\n'.join(tables_lines))
      md_text = self.repair_signal_names(md_text)
      # Wrap `[3:0]`-style signal subscripts in inline code spans. The brackets
      # render literally everywhere (incl. table cells), and renderers don't try
      # to parse them as link / reference syntax. Selective regex preserves real
      # markdown links because their bracket text contains spaces.
      md_text = _BRACKETED_SUBSCRIPT_RE.sub(r'`[\1]`', md_text)
      # Stitch together tables that pymupdf split at page breaks: any markdown
      # table immediately following another (same column count, no caption
      # between them) is treated as a continuation.
      md_text = self._merge_continuation_tables(md_text)
      md_path.write_text(md_text, encoding='utf-8')
      return md_path


# Create images/<stem>/ and write <stem>.md next to the PDF using Pdf2MdConverter.
# Returns (md_path, n_images_extracted, n_tables_in_md).
def write_md_beside_pdf(pdf_path: Path) -> Tuple[Path, int, int]:
   p = pdf_path.expanduser().resolve()
   stem = p.stem
   parent = p.parent
   md_path = parent / f'{stem}.md'
   images_dir = parent / 'images' / stem
   Pdf2MdConverter().convert(p, md_path, images_dir)
   n_images = len(list(images_dir.glob('*.png'))) if images_dir.is_dir() else 0
   # Count markdown table blocks (runs of consecutive lines starting with `|`).
   n_tables = 0
   in_tbl = False
   for ln in md_path.read_text(encoding='utf-8').splitlines():
      if ln.startswith('|'):
         if not in_tbl:
            n_tables += 1
            in_tbl = True
      else:
         in_tbl = False
   return md_path, n_images, n_tables


def main(argv: Optional[List[str]] = None) -> int:
   ap = argparse.ArgumentParser(
      description='Convert a PDF to Markdown (PyMuPDF/fitz): headings from the '
                  'outline or font sizes, tables via find_tables(), figures '
                  'cropped to images/<stem>/.')
   ap.add_argument('pdf', type=Path, help='input PDF file')
   ap.add_argument('-o', '--output', type=Path, default=None, metavar='MD',
      help='output markdown path (default: <stem>.md beside the PDF)')
   ap.add_argument('--images-dir', type=Path, default=None, metavar='DIR',
      help='directory for figure PNGs (default: <md dir>/images/<stem>)')
   ap.add_argument('--dpi-scale', type=float, default=5.0, metavar='N',
      help='rasterization scale for figure crops (default: 5.0)')
   args = ap.parse_args(argv)

   pdf = args.pdf.expanduser().resolve()
   if not pdf.is_file():
      ap.error(f'not a file: {pdf}')

   stem = pdf.stem
   md_path = (args.output.expanduser().resolve()
              if args.output else pdf.parent / f'{stem}.md')
   images_dir = (args.images_dir.expanduser().resolve()
                 if args.images_dir else md_path.parent / 'images' / stem)

   Pdf2MdConverter().convert(pdf, md_path, images_dir, dpi_scale=args.dpi_scale)
   n_images = len(list(images_dir.glob('*.png'))) if images_dir.is_dir() else 0
   print(f'wrote {md_path}  ({n_images} figure image(s) -> {images_dir})',
         file=sys.stderr)
   return 0


if __name__ == '__main__':
   raise SystemExit(main())
