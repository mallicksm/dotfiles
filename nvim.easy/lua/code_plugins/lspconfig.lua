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
      -- Main LSP Configuration
      'neovim/nvim-lspconfig',
      dependencies = {
         -- Useful status updates for LSP.
         -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
         { 'j-hui/fidget.nvim', opts = {} },

         -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
         -- used for completion, annotations and signatures of Neovim apis
         { 'folke/neodev.nvim', opts = {} },
      },
      config = function()
         --[[ setup capabilities for completions ]]
         -- LSP servers and clients are able to communicate to each other what features they support.
         --  By default, Neovim doesn't support everything that is in the LSP Specification.
         --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
         --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
         local capabilities = vim.lsp.protocol.make_client_capabilities()
         capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

         -- You can add other tools here that you want Mason to install
         -- for you, so that they care available from within Neovim
         local mason_servers = {
            lua_ls = {},
            bashls = {},
         }
         -- This is meant for outside Mason servers
         local servers = {
            clangd = {
               cmd = { 'clangd' },
               filetypes = { 'c', 'cpp' },
               capabilities = { capabilities },
               root_dir = require('lspconfig').util.root_pattern(
                  'compile_commands.json'
               ),
               single_file_support = true,
            },
            verible = {
               cmd = {
                  'verible-verilog-ls',
                  '--rules_config=~/dotfiles/formatters/verible-rules'
               },
               filetypes = { "verilog_systemverilog" },
               capabilities = { capabilities },
               root_dir = function()
                  return vim.loop.cwd()
               end,
            },
            pyright = {
               cmd = { "pyright-langserver", "--stdio" },
               filetypes = { "python" },
               root_dir = function()
                  return vim.loop.cwd()
               end,
               single_file_support = true,
            },
         }

         require('mason-lspconfig').setup({
            ensure_installed = vim.tbl_keys(mason_servers or {}),
            handlers = {
               function(server_name)
                  -- This handles overriding only valuse explicitly passed
                  -- by the server configuration above. Useful when disabling
                  -- certain features of an LSP (for example, turning off formatting for tsserver)
                  local mason_server = mason_servers[server_name] or {}
                  mason_server.capabilites = vim.tbl_deep_extend('force', {}, capabilities,
                     mason_server.capabilities or {})
                  require('lspconfig')[server_name].setup(mason_server)

                  -- Let's configure the external servers
                  -- This happens to work because this handler gets triggered by any filetype
                  require('lspconfig').clangd.setup(servers['clangd'])
                  require('lspconfig').verible.setup(servers['verible'])
                  require('lspconfig').pyright.setup(servers['pyright'])
               end,
            }
         })

         vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
            callback = function(event)
               local map = function(keys, func, desc)
                  vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
               end
               map('K', vim.lsp.buf.hover, 'Documentation')
               map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
               map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinitions')
               -- WARN: This is not Goto Definition, this is Goto Declaration.
               --  For example, in C this would take you to the header
               map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
               map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
               map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

               -- The following two autocommands are used to highlight references of the
               -- word under your cursor when your cursor rests there for a little while.
               --    See `:help CursorHold` for information about when this is executed
               --
               -- When you move your cursor, the highlights will be cleared (the second autocommand).
               local client = vim.lsp.get_client_by_id(event.data.client_id)
               if client and client.server_capabilities.documentHighlightProvider then
                  vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                     buffer = event.buf,
                     callback = vim.lsp.buf.document_highlight,
                  })

                  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                     buffer = event.buf,
                     callback = vim.lsp.buf.clear_references,
                  })
               end
            end,
         })
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
