return {
   {
      'saghen/blink.cmp',
      version = '1.*',
      event = { 'InsertEnter', 'CmdlineEnter' },
      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
         keymap = {
            preset = 'none',
            ['<C-n>'] = { 'select_next', 'fallback' },
            ['<C-p>'] = { 'select_prev', 'fallback' },
            ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
            ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
            ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
            ['<C-e>'] = { 'cancel', 'fallback' },
            ['<C-y>'] = { 'select_and_accept', 'fallback' },
            ['<C-l>'] = { 'snippet_forward', 'fallback' },
            ['<C-h>'] = { 'snippet_backward', 'fallback' },
         },
         appearance = { nerd_font_variant = 'mono' },
         snippets = { preset = 'default' }, -- vim.snippet; the engine that *expands* snippets (LSP-provided + ours)
         sources = {
            default = { 'lsp', 'snippets', 'directory', 'path', 'buffer' },
            providers = {
               lsp = { score_offset = 100 },
               -- blink.cmp's built-in snippets source. Reads VS Code-format
               -- JSON snippet collections; honors package.json's
               -- contributes.snippets array (filetype -> file mapping).
               --
               -- Source of truth: ~/dotfiles/snippets/vscode_snippets/
               --   * Add a new filetype: drop <ft>.json next to the others
               --     AND register it in package.json's contributes.snippets.
               --   * `all.json` is loaded for every filetype via global_snippets.
               --
               -- See blink.cmp/lua/blink/cmp/sources/snippets/default/ for the
               -- loader; the credit comment in registry.lua is to nvim-snippets,
               -- which has the same loading semantics. Keeping the loader
               -- in-tree means we don't need a separate plugin (and avoids
               -- nvim-snippets's hard dependency on nvim-cmp via its
               -- create_cmp_source = true default).
               snippets = {
                  score_offset = 90,
                  opts = {
                     friendly_snippets = false, -- skip the giant friendly-snippets corpus
                     global_snippets   = { 'all' },
                     search_paths      = { vim.fn.expand('~/dotfiles/snippets/vscode_snippets') },
                  },
               },
               directory = {
                  name = 'Directory',
                  module = 'user_plugins.nvim_notes',
                  score_offset = 80,
               },
               path = { score_offset = 70 },
               buffer = { score_offset = 60, max_items = 3 },
            },
         },
         completion = {
            menu = {
               border = 'rounded',
               draw = {
                  columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 }, { 'source_name' } },
               },
            },
            documentation = {
               auto_show = true,
               auto_show_delay_ms = 200,
               window = { border = 'rounded' },
            },
            list = { selection = { preselect = false, auto_insert = false } },
         },
         signature = { enabled = true, window = { border = 'rounded' } },
         cmdline = {
            enabled = true,
            keymap = { preset = 'cmdline' },
            completion = { menu = { auto_show = true } },
         },
         fuzzy = { implementation = 'prefer_rust_with_warning' },
      },
      opts_extend = { 'sources.default' },
   },
}
