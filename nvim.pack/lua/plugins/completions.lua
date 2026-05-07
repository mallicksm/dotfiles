-- blink.cmp (semver pinned to ~1) -- completion engine; capabilities are
-- consumed by lspconfig (loaded right after this file).
require('blink.cmp').setup({
   keymap = {
      preset = 'none',
      ['<C-n>']     = { 'select_next', 'fallback' },
      ['<C-p>']     = { 'select_prev', 'fallback' },
      ['<C-b>']     = { 'scroll_documentation_up',   'fallback' },
      ['<C-f>']     = { 'scroll_documentation_down', 'fallback' },
      ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>']     = { 'cancel', 'fallback' },
      ['<C-y>']     = { 'select_and_accept', 'fallback' },
      ['<C-l>']     = { 'snippet_forward',  'fallback' },
      ['<C-h>']     = { 'snippet_backward', 'fallback' },
   },
   appearance = { nerd_font_variant = 'mono' },
   snippets = { preset = 'default' }, -- vim.snippet expansion engine

   sources = {
      default = { 'lsp', 'snippets', 'directory', 'path', 'buffer' },
      providers = {
         lsp = { score_offset = 100 },
         -- VS Code-format snippet collection at ~/dotfiles/snippets/vscode_snippets/
         -- (package.json declares the filetype -> file mapping). all.json is
         -- loaded for every filetype via global_snippets. Loader is built into
         -- blink.cmp (default/registry.lua); no separate plugin needed.
         snippets = {
            score_offset = 90,
            opts = {
               friendly_snippets = false,
               global_snippets   = { 'all' },
               search_paths      = { vim.fn.expand('~/dotfiles/snippets/vscode_snippets') },
            },
         },
         directory = {
            name         = 'Directory',
            module       = 'user_plugins.nvim_notes',
            score_offset = 80,
         },
         path   = { score_offset = 70 },
         buffer = { score_offset = 60, max_items = 3 },
      },
   },
   completion = {
      menu = {
         border = 'rounded',
         draw   = { columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 }, { 'source_name' } } },
      },
      documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = 'rounded' } },
      list          = { selection = { preselect = false, auto_insert = false } },
   },
   signature = { enabled = true, window = { border = 'rounded' } },
   cmdline = {
      enabled    = true,
      keymap     = { preset = 'cmdline' },
      completion = { menu = { auto_show = true } },
   },
   fuzzy = { implementation = 'prefer_rust_with_warning' },
})

-- vim: ts=3 sts=3 sw=3 et
