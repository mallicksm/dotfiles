-- mason + mason-lspconfig + mason-tool-installer + nvim-lspconfig + fidget +
-- lazydev. Order: mason -> mason-tool-installer (binaries) -> mason-lspconfig
-- (LSPs) -> nvim-lspconfig (per-server config + LspAttach keymaps).

require('mason').setup({})

require('mason-tool-installer').setup({
   ensure_installed = {
      'tree-sitter-cli', -- needed by nvim-treesitter (main) to compile parsers
      'shfmt',           -- bash / sh formatter (Go static binary, no glibc dep)
      'shellcheck',      -- bash / sh linter (Haskell static binary)
      'tclint',          -- Tcl linter; also installs the `tclfmt` binary
      'black',           -- Python formatter (used via conform)
   },
   run_on_start = true,
})

-- fidget removed: noice.nvim already renders LSP progress (lsp.progress is on
-- by default in noice). The plugin is also dropped from plugins.lua's vim.pack
-- spec list; remove the on-disk pack/ entry with :lua vim.pack.del{'fidget.nvim'}.
require('lazydev').setup({
   library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } },
})

-- Diagnostic display: nvim 0.11+ defaults virtual_text=off; opt back in
-- with a small bullet prefix and severity-sorted ordering.
vim.diagnostic.config({
   virtual_text     = { prefix = '●', spacing = 2 },
   signs            = true,
   underline        = true,
   update_in_insert = false,
   severity_sort    = true,
   float            = { border = 'rounded', source = 'if_many' },
})

-- Per-buffer LSP keymaps -- attached when ANY LSP attaches to a buffer.
vim.api.nvim_create_autocmd('LspAttach', {
   group    = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
   callback = function(event)
      local map = function(keys, func, desc, mode)
         mode = mode or 'n'
         vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- LSP picker actions go through snacks.picker (telescope removed).
      map('gd',         function() require('snacks').picker.lsp_definitions() end,        '[G]oto [D]efinition')
      map('gr',         function() require('snacks').picker.lsp_references() end,         '[G]oto [R]eferences')
      map('<leader>pd', function() require('snacks').picker.lsp_type_definitions() end,   'ls[p]: type [D]efinition')
      map('<leader>ps', function() require('snacks').picker.lsp_workspace_symbols() end,  'ls[p]: workspace [S]ymbols')
      map('<leader>pr', vim.lsp.buf.rename, 'ls[p]: [r]ename')
      map('<leader>pa', vim.lsp.buf.code_action, 'ls[p]: code [a]ction', { 'n', 'x' })
      map('gD',         vim.lsp.buf.declaration,                                          '[G]oto [D]eclaration')
      map('K',          function() vim.lsp.buf.hover({ border = 'rounded' }) end,         'Documentation')

      -- The hand-rolled CursorHold/CursorMoved document_highlight pair moved
      -- into snacks.words (configured in plugins/snacks.lua). snacks.words
      -- attaches per-buf on LspAttach, debounces the highlight call, and gives
      -- us ]] / [[ jumps between references for free.
   end,
})

-- Default capabilities for every server (enriched by blink.cmp).
vim.lsp.config('*', {
   capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- Mason-managed servers (lua_ls, bashls) inherit '*' and are auto-enabled.
require('mason-lspconfig').setup({
   ensure_installed = { 'lua_ls', 'bashls' },
   automatic_enable = true,
})

-- Standalone servers (NOT installed via Mason: clangd / verible / pyright).
vim.lsp.config('clangd', {
   cmd          = { 'clangd' },
   filetypes    = { 'c', 'cpp' },
   root_markers = { 'compile_commands.json', '.git' },
})

vim.lsp.config('verible', {
   -- cmd as a function so we can opportunistically inject --file_list_path
   -- from the project's filelist.f. No notify -- nvim-notify (via noice)
   -- shows DEBUG-level messages too, so even DEBUG popped a toast on every
   -- project open. Inspect via :LspInfo / :checkhealth lsp instead.
   cmd = function(dispatchers)
      local cmd_args = {
         'verible-verilog-ls',
         '--rules_config=' .. vim.fn.expand('~/dotfiles/formatters/verible-rules'),
      }
      local root = vim.fs.root(0, { '.git' })
      if root then
         local fl = root .. '/filelist.f'
         if vim.uv.fs_stat(fl) then
            table.insert(cmd_args, '--file_list_path=' .. fl)
         end
      end
      return vim.lsp.rpc.start(cmd_args, dispatchers)
   end,
   filetypes    = { 'verilog_systemverilog' },
   root_markers = { '.git' },
})

vim.lsp.config('pyright', {
   cmd          = { 'pyright-langserver', '--stdio' },
   filetypes    = { 'python' },
   root_markers = { '.git' },
})

vim.lsp.enable({ 'clangd', 'verible', 'pyright' })

-- vim: ts=3 sts=3 sw=3 et
