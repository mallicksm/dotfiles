return {
   'MeanderingProgrammer/render-markdown.nvim',
   config = function()
      require('render-markdown').setup({
         -- Conceal common inline HTML tags. The renderer hides start AND end tag
         -- for any tag name listed here (see render/html/tag.lua); empty config
         -- = "just hide it, no icon". Add more as you encounter them in docs.
         html = {
            tag = {
               a   = {},                                                -- anchor targets: <a id="..."></a>
               br  = { icon = '↵', highlight = 'RenderMarkdownDash' },  -- forced line break
               sub = {},                                                -- subscript
               sup = {},                                                -- superscript
               kbd = { scope_highlight = 'RenderMarkdownCodeInline' },  -- keyboard keys
            },
         },
         heading = {
            -- Per-level icons (single cell each; bigger glyphs = more visual weight)
            icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
            position = 'inline', -- icon next to '#' instead of overlaying it

            -- Big colored bars give the strongest "this is a heading" feel
            width = 'block',     -- bar spans only the heading text + padding (vs 'full' = whole window)
            left_pad = 1,        -- one cell of background to the left of the icon
            right_pad = 4,       -- four cells of background after the text
            min_width = 40,      -- minimum bar length so short headings still look chunky

            -- Horizontal rules above/below H1 and H2 (a la GitHub markdown)
            border = { true, true, false, false, false, false },
            border_virtual = false, -- true = draw rules even on empty lines (uses extra height)

            sign = false, -- skip gutter sign; the bar is enough
         },
         -- Blockquote bar (also drives the left bar on `> [!NOTE]` / `> [!WARNING]`
         -- callouts since callouts inherit quote rendering). The "icon" is a single
         -- terminal cell whose FILL determines visual width:
         --   ▏ ▎ ▍ ▌  (12.5% / 25% / 37.5% / 50%) -- thinner
         --   ▋ (62.5%, render-markdown default)
         --   ▊ ▉ █    (75% / 87.5% / 100%)        -- thicker (current pick)
         -- repeat_linebreak = true draws the bar on every wrapped line too, so
         -- multi-line callouts render as a solid color block on the left margin.
         quote = {
            icon = '▊',
            repeat_linebreak = true,
         },
      })

      -- Tune highlights to match gruvbox. Re-apply on ColorScheme change so
      -- :Telescope colorscheme previews don't strip them.
      local function apply_render_markdown_hls()
         -- Heading bars (per-level)
         vim.api.nvim_set_hl(0, 'RenderMarkdownH1Bg', { bg = '#cc241d', fg = '#fbf1c7', bold = true })
         vim.api.nvim_set_hl(0, 'RenderMarkdownH2Bg', { bg = '#d65d0e', fg = '#fbf1c7', bold = true })
         vim.api.nvim_set_hl(0, 'RenderMarkdownH3Bg', { bg = '#d79921', fg = '#282828', bold = true })
         vim.api.nvim_set_hl(0, 'RenderMarkdownH4Bg', { bg = '#98971a', fg = '#282828' })
         vim.api.nvim_set_hl(0, 'RenderMarkdownH5Bg', { bg = '#458588', fg = '#fbf1c7' })
         vim.api.nvim_set_hl(0, 'RenderMarkdownH6Bg', { bg = '#b16286', fg = '#fbf1c7' })

         -- Callout palette (`> [!NOTE]`, `> [!TODO]`, `> [!WARNING]`, ...).
         -- 30+ callouts collapse onto these 6 groups; tune once, all inherit.
         vim.api.nvim_set_hl(0, 'RenderMarkdownInfo',    { fg = '#83a598', bold = true }) -- NOTE / TODO / INFO   (gruvbox blue)
         vim.api.nvim_set_hl(0, 'RenderMarkdownSuccess', { fg = '#b8bb26', bold = true }) -- TIP / SUCCESS / DONE (gruvbox green)
         vim.api.nvim_set_hl(0, 'RenderMarkdownHint',    { fg = '#8ec07c', bold = true }) -- IMPORTANT / EXAMPLE  (gruvbox aqua)
         vim.api.nvim_set_hl(0, 'RenderMarkdownWarn',    { fg = '#fabd2f', bold = true }) -- WARNING / QUESTION   (gruvbox yellow)
         vim.api.nvim_set_hl(0, 'RenderMarkdownError',   { fg = '#fb4934', bold = true }) -- CAUTION / ERROR / BUG (gruvbox red)
         vim.api.nvim_set_hl(0, 'RenderMarkdownQuote',   { fg = '#d3869b', italic = true }) -- QUOTE / CITE / plain '>' (gruvbox purple)

         -- Caption / note prefix badges (used by mini.hipatterns in after/ftplugin/markdown.lua).
         -- Pill-style: dark fg on a saturated gruvbox bg so the prefix reads as a label/tag.
         vim.api.nvim_set_hl(0, 'MarkdownTableCaption',  { fg = '#282828', bg = '#8ec07c', bold = true }) -- gruvbox aqua
         vim.api.nvim_set_hl(0, 'MarkdownFigureCaption', { fg = '#282828', bg = '#fe8019', bold = true }) -- gruvbox orange
         vim.api.nvim_set_hl(0, 'MarkdownNotePrefix',    { fg = '#282828', bg = '#fabd2f', bold = true }) -- gruvbox yellow
      end
      apply_render_markdown_hls()
      vim.api.nvim_create_autocmd('ColorScheme', {
         group = vim.api.nvim_create_augroup('user-render-markdown-hls', { clear = true }),
         callback = apply_render_markdown_hls,
      })
   end,
}
-- vim: ts=3 sts=3 sw=3 et