-- render-markdown.nvim with gruvbox-tuned highlights (re-applied on
-- ColorScheme so :Telescope colorscheme previews don't strip them).
require('render-markdown').setup({
   -- LaTeX math rendering needs the `latex` treesitter parser; without it
   -- render-markdown spams "parser: not installed" and "ABI: unknown" on
   -- every checkhealth. We don't write LaTeX in markdown -- turn it off.
   -- Re-enable + run `:TSInstall latex` if you ever start writing math.
   latex = { enabled = false },
   html = {
      tag = {
         a   = {},
         br  = { icon = '↵', highlight = 'RenderMarkdownDash' },
         sub = {},
         sup = {},
         kbd = { scope_highlight = 'RenderMarkdownCodeInline' },
      },
   },
   heading = {
      icons     = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
      position  = 'inline',
      width     = 'block',
      left_pad  = 1,
      right_pad = 4,
      min_width = 40,
      border    = { true, true, false, false, false, false },
      border_virtual = false,
      sign      = false,
   },
   quote = {
      icon             = '▊',
      repeat_linebreak = true,
   },
   code = {
      sign               = false,
      width              = 'block',
      min_width          = 60,
      left_pad           = 1,
      right_pad          = 4,
      border             = 'thick',
      position           = 'right',
      language_pad       = 2,
      language_name      = true,
      language_icon      = true,
      disable_background = { 'diff' },
   },
   bullet = {
      icons     = { '●', '◆', '▪', '▸' },
      right_pad = 1,
   },
   checkbox = {
      right_pad = 2,
      unchecked = { icon = '󰄱 ', highlight = 'RenderMarkdownUnchecked' },
      checked   = { icon = '󰱒 ', highlight = 'RenderMarkdownChecked'   },
      custom = {
         todo      = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo'  },
         important = { raw = '[!]', rendered = '󰀦 ', highlight = 'RenderMarkdownError' },
         question  = { raw = '[?]', rendered = '󰋗 ', highlight = 'RenderMarkdownWarn'  },
      },
   },
   pipe_table = {
      preset              = 'round',
      cell                = 'padded',
      alignment_indicator = '─',
   },
   dash = { icon = '─', width = 'full' },
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

local function apply_render_markdown_hls()
   vim.api.nvim_set_hl(0, 'RenderMarkdownH1Bg', { bg = '#cc241d', fg = '#fbf1c7', bold = true })
   vim.api.nvim_set_hl(0, 'RenderMarkdownH2Bg', { bg = '#d65d0e', fg = '#fbf1c7', bold = true })
   vim.api.nvim_set_hl(0, 'RenderMarkdownH3Bg', { bg = '#d79921', fg = '#282828', bold = true })
   vim.api.nvim_set_hl(0, 'RenderMarkdownH4Bg', { bg = '#98971a', fg = '#282828' })
   vim.api.nvim_set_hl(0, 'RenderMarkdownH5Bg', { bg = '#458588', fg = '#fbf1c7' })
   vim.api.nvim_set_hl(0, 'RenderMarkdownH6Bg', { bg = '#b16286', fg = '#fbf1c7' })

   vim.api.nvim_set_hl(0, 'RenderMarkdownInfo',    { fg = '#83a598', bold = true })
   vim.api.nvim_set_hl(0, 'RenderMarkdownSuccess', { fg = '#b8bb26', bold = true })
   vim.api.nvim_set_hl(0, 'RenderMarkdownHint',    { fg = '#8ec07c', bold = true })
   vim.api.nvim_set_hl(0, 'RenderMarkdownWarn',    { fg = '#fabd2f', bold = true })
   vim.api.nvim_set_hl(0, 'RenderMarkdownError',   { fg = '#fb4934', bold = true })
   vim.api.nvim_set_hl(0, 'RenderMarkdownQuote',   { fg = '#d3869b', italic = true })

   vim.api.nvim_set_hl(0, 'MarkdownTableCaption',  { fg = '#282828', bg = '#8ec07c', bold = true })
   vim.api.nvim_set_hl(0, 'MarkdownFigureCaption', { fg = '#282828', bg = '#fe8019', bold = true })
   vim.api.nvim_set_hl(0, 'MarkdownNotePrefix',    { fg = '#282828', bg = '#fabd2f', bold = true })

   vim.api.nvim_set_hl(0, 'RenderMarkdownCode',         { bg = '#1d2021' })
   vim.api.nvim_set_hl(0, 'RenderMarkdownCodeBorder',   { fg = '#665c54', bg = '#282828' })
   vim.api.nvim_set_hl(0, 'RenderMarkdownCodeInfo',     { fg = '#a89984', bg = '#1d2021' })
   vim.api.nvim_set_hl(0, 'RenderMarkdownCodeFallback', { fg = '#a89984', bg = '#1d2021' })
   vim.api.nvim_set_hl(0, 'RenderMarkdownCodeInline',   { fg = '#fe8019', bg = '#3c3836' })

   vim.api.nvim_set_hl(0, 'RenderMarkdownUnchecked', { fg = '#928374' })
   vim.api.nvim_set_hl(0, 'RenderMarkdownChecked',   { fg = '#b8bb26', bold = true })
   vim.api.nvim_set_hl(0, 'RenderMarkdownTodo',      { fg = '#83a598', bold = true })

   vim.api.nvim_set_hl(0, 'RenderMarkdownLink', { fg = '#83a598', underline = true })

   vim.api.nvim_set_hl(0, 'RenderMarkdownTableHead', { fg = '#fabd2f', bold = true })
   vim.api.nvim_set_hl(0, 'RenderMarkdownTableRow',  { fg = '#a89984' })
   vim.api.nvim_set_hl(0, 'RenderMarkdownTableFill', { fg = '#665c54' })

   vim.api.nvim_set_hl(0, 'RenderMarkdownDash',   { fg = '#fabd2f' })
   vim.api.nvim_set_hl(0, 'RenderMarkdownBullet', { fg = '#fabd2f', bold = true })
end

apply_render_markdown_hls()
vim.api.nvim_create_autocmd('ColorScheme', {
   group    = vim.api.nvim_create_augroup('user-render-markdown-hls', { clear = true }),
   callback = apply_render_markdown_hls,
})

-- vim: ts=3 sts=3 sw=3 et
