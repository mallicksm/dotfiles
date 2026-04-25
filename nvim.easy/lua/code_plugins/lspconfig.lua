return {
   {
      'mason-org/mason.nvim',
      opts = {},
   },
   {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
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
         vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
            callback = function(event)
               local map = function(keys, func, desc, mode)
                  mode = mode or 'n'
                  vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
               end

               map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
               map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
               map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
               map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
               map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
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

         -- Default config applied to every server (capabilities from blink.cmp)
         vim.lsp.config('*', {
            capabilities = require('blink.cmp').get_lsp_capabilities(),
         })

         -- Mason-managed servers: declare overrides via vim.lsp.config,
         -- mason-lspconfig 2.0 will auto-enable them.
         vim.lsp.config('lua_ls', {})
         vim.lsp.config('bashls', {})

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
                     vim.notify('[verible] using file_list_path: ' .. fl)
                  else
                     vim.notify('[verible] no filelist.f in ' .. root)
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
