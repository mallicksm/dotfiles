-- Buffer-local extras for markdown.

-- nowrap by default (per request 2026-05-03): converted PDF .md files have wide
-- tables that look terrible if reflowed. The toggle below restores soft-wrap
-- on demand; linebreak/breakindent stay set so wrap mode looks right when flipped.
vim.opt_local.wrap = false
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true

----------------------------------------------------------------------------
-- Pretty-print caption / note prefixes via mini.hipatterns (markdown only).
--   Table 2-3: ...   -> aqua badge
--   Figure 4-5: ...  -> orange badge
--   Note: ...        -> yellow badge
-- Patterns are anchored to start-of-line so they don't fire mid-paragraph.
-- Highlight groups (MarkdownTableCaption / MarkdownFigureCaption / MarkdownNotePrefix)
-- are defined alongside the render-markdown overrides in
-- lua/core_plugins/render-markdown.lua so the ColorScheme autocmd re-applies them.
-- Buffer-local config is deep-merged with mini.hipatterns global config, so the
-- existing FIXME/HACK/TODO/NOTE highlighters keep working.
----------------------------------------------------------------------------
-- Lua-pattern legend:
--   ^          start of line
--   [_*]*      optional italic/bold markers (PDF→md often emits *Figure...* or _Figure..._)
--   %s+        one or more whitespace
--   [%w%-%.]+  alphanumeric / dash / dot — matches "4-5", "A.1", "2-3-1", etc.
--   :?         optional trailing colon
-- mini.hipatterns highlights the matched range; the leading _* are concealed
-- by render-markdown when it's active, so the badge looks clean either way.
vim.b.minihipatterns_config = {
   highlighters = {
      table_caption  = { pattern = '^[_*]*Table%s+[%w%-%.]+:?',  group = 'MarkdownTableCaption' },
      figure_caption = { pattern = '^[_*]*Figure%s+[%w%-%.]+:?', group = 'MarkdownFigureCaption' },
      note_prefix    = { pattern = '^[_*]*Note:',                group = 'MarkdownNotePrefix' },
   },
}

----------------------------------------------------------------------------
-- <CR> follows a markdown link under the cursor; <BS> jumps back via jumplist.
-- Implementation lives in lua/markdown/links.lua so other ftplugins can reuse it.
----------------------------------------------------------------------------
require('markdown.links').setup_keymaps()

-- vim: ts=3 sts=3 sw=3 et
