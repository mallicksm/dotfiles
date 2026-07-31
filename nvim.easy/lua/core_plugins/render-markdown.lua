return {
   'MeanderingProgrammer/render-markdown.nvim',
   config = function()
      require('render-markdown').setup({
         -- LaTeX math rendering ($...$ / $$...$$) needs the `latex` treesitter
         -- parser; without it render-markdown spams "parser: not installed"
         -- and "ABI: unknown" warnings on every checkhealth. We don't write
         -- LaTeX in markdown (SV docs / Jira / READMEs), so just turn it off.
         -- Re-enable + run `:TSInstall latex` if you ever start writing math.
         latex = { enabled = false },
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
         ----------------------------------------------------------------
         -- Code blocks: solid card with language label on the right
         ----------------------------------------------------------------
         -- Pulls the same "block of background + thin top/bottom border"
         -- treatment as headings, so headings/quotes/code all read as
         -- visual cards with consistent left/right padding.
         code = {
            sign = false,            -- consistent with heading.sign = false
            width = 'block',         -- bg only spans the code, not full window
            min_width = 60,          -- short blocks still get a chunky bg
            left_pad = 1,
            right_pad = 4,
            border = 'thick',        -- ▄/▀ horizontal rules above + below
            position = 'right',      -- language label on the right side
            language_pad = 2,        -- breathing room around the language tag
            language_name = true,
            language_icon = true,    -- needs nerd font (you have it)
            disable_background = { 'diff' }, -- diff has its own +/- bg
         },
         ----------------------------------------------------------------
         -- Bullets: nested cycle, four levels deep
         ----------------------------------------------------------------
         bullet = {
            icons = { '●', '◆', '▪', '▸' },  -- L1 / L2 / L3 / L4 (cycles after)
            right_pad = 1,                   -- one cell between bullet and text
         },
         ----------------------------------------------------------------
         -- Checkboxes: classic [ ]/[x] + extras
         ----------------------------------------------------------------
         -- Custom states render only when the raw text matches exactly.
         -- - [-] is "in progress" (clock icon, info color)
         -- - [!] is "important"   (alert icon, error color)
         -- - [?] is "question"    (info icon, warn  color)
         checkbox = {
            right_pad = 2,
            unchecked = { icon = '󰄱 ', highlight = 'RenderMarkdownUnchecked' },
            checked   = { icon = '󰱒 ', highlight = 'RenderMarkdownChecked'   },
            custom = {
               todo      = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo'    },
               important = { raw = '[!]', rendered = '󰀦 ', highlight = 'RenderMarkdownError'   },
               question  = { raw = '[?]', rendered = '󰋗 ', highlight = 'RenderMarkdownWarn'    },
            },
         },
         ----------------------------------------------------------------
         -- Pipe tables: rounded unicode borders (╭┬╮ corners)
         ----------------------------------------------------------------
         -- 'round' preset gives the GitHub-table look. 'cell = padded'
         -- pads every cell to the column width so columns line up
         -- regardless of underlying markdown spacing.
         pipe_table = {
            preset = 'round',
            cell = 'padded',
            alignment_indicator = '─',
         },
         ----------------------------------------------------------------
         -- Thematic break (--- / ***): spans full width, gruvbox color
         ----------------------------------------------------------------
         dash = {
            icon = '─',
            width = 'full',
         },
         ----------------------------------------------------------------
         -- Link icons (rendered as inline prefix on `[text](url)` etc)
         ----------------------------------------------------------------
         -- The custom table matches the URL by lua-pattern; first-match wins.
         -- github / youtube get their own icon, otherwise plain web globe.
         link = {
            image     = '󰥶 ',
            email     = '󰀓 ',
            hyperlink = '󰌹 ',
            custom = {
               github  = { pattern = 'github%.com',  icon = '󰊤 ', highlight = 'RenderMarkdownLink' },
               youtube = { pattern = 'youtube%.com', icon = '󰗃 ', highlight = 'RenderMarkdownLink' },
               web     = { pattern = '^https?://',   icon = '󰖟 ', highlight = 'RenderMarkdownLink' },
            },
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

         -- Code blocks: bg0 darker than buffer (subtle card), border in muted yellow
         vim.api.nvim_set_hl(0, 'RenderMarkdownCode',         { bg = '#1d2021' })                  -- gruvbox bg0_h (slightly darker than default bg)
         vim.api.nvim_set_hl(0, 'RenderMarkdownCodeBorder',   { fg = '#665c54', bg = '#282828' })  -- bg2/bg0 (thin rule)
         vim.api.nvim_set_hl(0, 'RenderMarkdownCodeInfo',     { fg = '#a89984', bg = '#1d2021' })  -- language label fg (gruvbox fg4)
         vim.api.nvim_set_hl(0, 'RenderMarkdownCodeFallback', { fg = '#a89984', bg = '#1d2021' })  -- language fallback (no icon)
         vim.api.nvim_set_hl(0, 'RenderMarkdownCodeInline',   { fg = '#fe8019', bg = '#3c3836' })  -- `inline code`: orange on bg1

         -- Checkboxes
         vim.api.nvim_set_hl(0, 'RenderMarkdownUnchecked', { fg = '#928374' })                    -- gruvbox gray
         vim.api.nvim_set_hl(0, 'RenderMarkdownChecked',   { fg = '#b8bb26', bold = true })       -- gruvbox green, bold
         vim.api.nvim_set_hl(0, 'RenderMarkdownTodo',      { fg = '#83a598', bold = true })       -- gruvbox blue (in-progress)

         -- Links: cyan-ish blue, underlined for affordance
         vim.api.nvim_set_hl(0, 'RenderMarkdownLink', { fg = '#83a598', underline = true })       -- gruvbox blue

         -- Pipe table border (the ╭┬╮ characters)
         vim.api.nvim_set_hl(0, 'RenderMarkdownTableHead', { fg = '#fabd2f', bold = true })        -- header row in yellow
         vim.api.nvim_set_hl(0, 'RenderMarkdownTableRow',  { fg = '#a89984' })                     -- body rows in fg4
         vim.api.nvim_set_hl(0, 'RenderMarkdownTableFill', { fg = '#665c54' })                     -- border chars in bg3

         -- Dash (--- thematic break) in muted yellow
         vim.api.nvim_set_hl(0, 'RenderMarkdownDash', { fg = '#fabd2f' })

         -- Bullets: cycle blue/aqua/yellow/orange to mirror the depth visually
         vim.api.nvim_set_hl(0, 'RenderMarkdownBullet', { fg = '#fabd2f', bold = true })
      end
      apply_render_markdown_hls()
      vim.api.nvim_create_autocmd('ColorScheme', {
         group = vim.api.nvim_create_augroup('user-render-markdown-hls', { clear = true }),
         callback = apply_render_markdown_hls,
      })
   end,
}
-- vim: ts=3 sts=3 sw=3 et