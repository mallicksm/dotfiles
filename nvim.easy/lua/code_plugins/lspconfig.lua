return {
   {
      'williamboman/mason.nvim',
      config = function()
         require('mason').setup()
      end,
   },
   {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'williamboman/mason-lspconfig.nvim',
   },
   {
      'neovim/nvim-lspconfig',
      dependencies = {
         { 'j-hui/fidget.nvim', opts = {} }, -- For LSP progress
         {
            'folke/lazydev.nvim',
            ft = "lua",
            opts = {
               library = {
                  { path = "${3rd}/luv/library", words = { "vim%.uv" } },
               },
            },
         },
      },
      config = function()
         -- Define common capabilities
         local capabilities = vim.lsp.protocol.make_client_capabilities()
         capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

         -- Define `on_attach` function for common keymaps and behavior
         local on_attach = function(client, bufnr)
            local map = function(keys, func, desc, mode)
               mode = mode or 'n'
               vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
            end

            -- Common LSP Keymaps
            map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
            map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
            map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
            map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
            map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
            map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
            map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
            map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
            map('K', vim.lsp.buf.hover, 'Documentation')

            -- Highlight references under cursor
            if client.server_capabilities.documentHighlightProvider then
               local hl_group = vim.api.nvim_create_augroup('LspHighlight', { clear = true })
               vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                  buffer = bufnr,
                  group = hl_group,
                  callback = vim.lsp.buf.document_highlight,
               })
               vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                  buffer = bufnr,
                  group = hl_group,
                  callback = vim.lsp.buf.clear_references,
               })
            end
         end

         -- Configure Mason-managed servers
         local mason_servers = {
            lua_ls = {},
            bashls = {},
         }

         require('mason-lspconfig').setup({
            ensure_installed = vim.tbl_keys(mason_servers),
            automatic_installation = false,
            handlers = {
               function(server_name)
                  require('lspconfig')[server_name].setup({
                     capabilities = capabilities,
                     on_attach = on_attach,
                     settings = mason_servers[server_name] or {},
                  })
               end,
            },
         })

         -- Configure standalone servers
         local standalone_servers = {
            clangd = {
               cmd = { 'clangd' },
               filetypes = { 'c', 'cpp' },
               root_dir = require('lspconfig').util.root_pattern('compile_commands.json'),
               single_file_support = true,
            },
            verible = {
               cmd = {
                  'verible-verilog-ls',
                  '--rules_config=' .. vim.fn.expand('~/dotfiles/formatters/verible-rules'),
               },
               filetypes = { "verilog_systemverilog" },
               root_dir = function(fname)
                  return vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true, path = fname })[1])
               end,
            },
            pyright = {
               cmd = { "pyright-langserver", "--stdio" },
               filetypes = { "python" },
               root_dir = function(fname)
                  return vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true, path = fname })[1])
               end,
               single_file_support = true,
            },
         }

         for server_name, config in pairs(standalone_servers) do
            require('lspconfig')[server_name].setup(vim.tbl_deep_extend('force', {
               capabilities = capabilities,
               on_attach = on_attach,
            }, config))
         end
      end,
   },
}
