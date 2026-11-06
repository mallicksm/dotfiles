-- LSP stack. lazy.nvim spec wrapping the same body as the nvim.pack twin
-- (nvim.pack/lua/plugins/lspconfig.lua); keep the two in sync.

return {
   {
      'mason-org/mason.nvim',
      cmd  = { 'Mason', 'MasonInstall', 'MasonUninstall', 'MasonUninstallAll', 'MasonLog', 'MasonUpdate' },
      opts = {},
   },
   {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      dependencies = { 'mason-org/mason.nvim' },
      event        = 'VeryLazy', -- defer ensure_installed walk past first paint
      opts = {
         ensure_installed = {
            'tree-sitter-cli', -- needed by nvim-treesitter (main) to compile parsers
            'shfmt',           -- bash / sh formatter
            'shellcheck',      -- bash / sh linter
            'tclint',          -- Tcl linter; also installs tclfmt
            'black',           -- Python formatter (used via conform)
         },
         run_on_start = true,
      },
   },
   {
      'mason-org/mason-lspconfig.nvim',
      dependencies = { 'mason-org/mason.nvim', 'neovim/nvim-lspconfig' },
      event        = { 'BufReadPre', 'BufNewFile' },
   },
   {
      'neovim/nvim-lspconfig',
      event = { 'BufReadPre', 'BufNewFile' },
      dependencies = {
         {
            'folke/lazydev.nvim',
            ft   = 'lua',
            opts = { library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } } },
         },
         'saghen/blink.cmp',
      },
      config = function()
         -- nvim 0.11+ defaults virtual_text=off; opt back in.
         vim.diagnostic.config({
            virtual_text     = { prefix = '●', spacing = 2 },
            signs            = true,
            underline        = true,
            update_in_insert = false,
            severity_sort    = true,
            float            = { border = 'rounded', source = 'if_many' },
         })

         -- Per-buffer keymaps, attached when any LSP attaches. The goto/list actions go
         -- through snacks.picker; wrapping in function() defers require() to keypress.
         -- Reference highlighting lives in snacks.words (core_plugins/snacks.lua).
         vim.api.nvim_create_autocmd('LspAttach', {
            group    = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
            callback = function(event)
               local map = function(keys, func, desc, mode)
                  vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
               end

               map('gd',         function() require('snacks').picker.lsp_definitions() end,       '[G]oto [D]efinition')
               map('gr',         function() require('snacks').picker.lsp_references() end,        '[G]oto [R]eferences')
               map('<leader>cc', function() require('snacks').picker.lsp_type_definitions() end,  '[c]ode: type definition ([c][c])')
               map('<leader>cs', function() require('snacks').picker.lsp_workspace_symbols() end, '[c]ode: workspace [S]ymbols')
               map('<leader>cr', vim.lsp.buf.rename,                                              '[c]ode: [r]ename')
               map('<leader>ca', vim.lsp.buf.code_action,                                         '[c]ode: code [a]ction', { 'n', 'x' })
               map('gD',         vim.lsp.buf.declaration,                                         '[G]oto [D]eclaration')
               map('K',          function() vim.lsp.buf.hover({ border = 'rounded' }) end,        'Documentation')
            end,
         })

         -- Capabilities for every server, from blink.cmp.
         vim.lsp.config('*', {
            capabilities = require('blink.cmp').get_lsp_capabilities(),
         })

         -- Mason-managed servers inherit '*' and are auto-enabled.
         require('mason-lspconfig').setup({
            ensure_installed = { 'lua_ls', 'bashls' },
            automatic_enable = true,
         })

         -- Standalone servers (not Mason-installed).
         vim.lsp.config('clangd', {
            cmd          = { 'clangd' },
            filetypes    = { 'c', 'cpp' },
            root_markers = { 'compile_commands.json', '.git' },
         })

         vim.lsp.config('verible', {
            -- cmd is a function so we can inject the project's filelist.f and pin cwd.
            -- Inspect via :LspInfo / :checkhealth lsp -- no notify, since nvim-notify
            -- (via noice) toasts even DEBUG messages on every project open.
            cmd = function(dispatchers)
               local cmd_args = {
                  'verible-verilog-ls',
                  '--rules_config=' .. vim.fn.expand('~/dotfiles/formatters/verible-rules'),
               }
               local root = vim.fs.root(0, { '.git' })
               if root and vim.uv.fs_stat(root .. '/filelist.f') then
                  table.insert(cmd_args, '--file_list_path=' .. root .. '/filelist.f')
               end
               -- cwd MUST be the repo root: verible resolves `include against its own
               -- working directory, so starting inside mac/.../md80 resolves that dir's
               -- all_includes.vh, which pulls five whole .sv packages into every file
               -- and SIGSEGVs SymbolTable::Builder.
               return vim.lsp.rpc.start(cmd_args, dispatchers, { cwd = root })
            end,
            filetypes    = { 'sv' },
            root_markers = { '.git' },
         })

         vim.lsp.config('pyright', {
            cmd          = { 'pyright-langserver', '--stdio' },
            filetypes    = { 'python' },
            root_markers = { '.git' },
         })

         vim.lsp.enable({ 'clangd', 'verible', 'pyright' })
      end,
   },
}

-- vim: ts=3 sts=3 sw=3 et
