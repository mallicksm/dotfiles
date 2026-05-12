return {
   {
      'mason-org/mason.nvim',
      opts = {},
   },
   {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      dependencies = { 'mason-org/mason.nvim' },
      opts = {
         ensure_installed = {
            'tree-sitter-cli', -- needed by nvim-treesitter (main branch) to compile parsers
            'shfmt',           -- bash / sh formatter (Go static binary, no glibc dep)
            'shellcheck',      -- bash / sh linter (Haskell static binary; pairs with shfmt)
            'tclint',          -- Tcl linter; also installs the `tclfmt` binary used by conform
            'black',           -- Python formatter (used via conform; reads ~/dotfiles/formatters/py-format.toml)
         },
         run_on_start = true,
      },
      config = function(_, opts)
         require('mason-tool-installer').setup(opts)
      end,
   },
   {
      'mason-org/mason-lspconfig.nvim',
      dependencies = {
         'mason-org/mason.nvim',
         'neovim/nvim-lspconfig',
      },
   },
   {
      'neovim/nvim-lspconfig',
      dependencies = {
         { 'j-hui/fidget.nvim', opts = {} },
         {
            'folke/lazydev.nvim',
            ft = 'lua',
            opts = {
               library = {
                  { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
               },
            },
         },
         'saghen/blink.cmp',
      },
      config = function()
         -- Diagnostic display: nvim 0.11+ defaults virtual_text=off; opt back in
         -- with a small bullet prefix and severity-sorted ordering.
         vim.diagnostic.config({
            virtual_text = { prefix = '●', spacing = 2 },
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = { border = 'rounded', source = 'if_many' },
         })

         vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
            callback = function(event)
               local map = function(keys, func, desc, mode)
                  mode = mode or 'n'
                  vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
               end

               -- Wrap telescope.builtin requires in function() so they're resolved
               -- at keypress time, not LspAttach time. Future-proofs against making
               -- telescope lazy-loaded later (today it's lazy=false so either works).
               map('gd',         function() require('telescope.builtin').lsp_definitions() end,                '[G]oto [D]efinition')
               map('gr',         function() require('telescope.builtin').lsp_references() end,                 '[G]oto [R]eferences')
               map('<leader>D',  function() require('telescope.builtin').lsp_type_definitions() end,           'Type [D]efinition')
               map('<leader>ds', function() require('telescope.builtin').lsp_document_symbols() end,           '[D]ocument [S]ymbols')
               map('<leader>ws', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end,  '[W]orkspace [S]ymbols')
               map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
               map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
               map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
               map('K', function() vim.lsp.buf.hover({ border = 'rounded' }) end, 'Documentation')

               local client = vim.lsp.get_client_by_id(event.data.client_id)
               if client and client:supports_method('textDocument/documentHighlight') then
                  local hl_group = vim.api.nvim_create_augroup('LspHighlight', { clear = false })
                  vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                     buffer = event.buf,
                     group = hl_group,
                     callback = vim.lsp.buf.document_highlight,
                  })
                  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                     buffer = event.buf,
                     group = hl_group,
                     callback = vim.lsp.buf.clear_references,
                  })
               end
            end,
         })

         -- Default config applied to every server (capabilities from blink.cmp).
         -- Mason-managed servers (lua_ls, bashls) inherit this and are auto-enabled
         -- by mason-lspconfig 2.0; declare per-server overrides via vim.lsp.config
         -- here only when actually needed.
         vim.lsp.config('*', {
            capabilities = require('blink.cmp').get_lsp_capabilities(),
         })

         require('mason-lspconfig').setup({
            ensure_installed = { 'lua_ls', 'bashls' },
            automatic_enable = true,
         })

         -- Standalone servers (not installed via Mason)
         vim.lsp.config('clangd', {
            cmd = { 'clangd' },
            filetypes = { 'c', 'cpp' },
            root_markers = { 'compile_commands.json', '.git' },
         })

         vim.lsp.config('verible', {
            -- cmd is a function so we can opportunistically inject --file_list_path
            -- from the project's filelist.f. No notify -- nvim-notify (via noice)
            -- shows DEBUG-level messages too, so even DEBUG popped a toast on
            -- every project open. Inspect via :LspInfo / :checkhealth lsp instead.
            cmd = function(dispatchers)
               local cmd_args = {
                  'verible-verilog-ls',
                  '--rules_config=' .. vim.fn.expand('~/dotfiles/formatters/verible-rules'),
               }
               local root = vim.fs.root(0, { '.git' })
               if root then
                  local fl = root .. '/filelist.f'
                  if (vim.uv or vim.loop).fs_stat(fl) then
                     table.insert(cmd_args, '--file_list_path=' .. fl)
                  end
               end
               return vim.lsp.rpc.start(cmd_args, dispatchers)
            end,
            filetypes = { 'verilog_systemverilog' },
            root_markers = { '.git' },
         })

         vim.lsp.config('pyright', {
            cmd = { 'pyright-langserver', '--stdio' },
            filetypes = { 'python' },
            root_markers = { '.git' },
         })

         vim.lsp.enable({ 'clangd', 'verible', 'pyright' })
      end,
   },
}
