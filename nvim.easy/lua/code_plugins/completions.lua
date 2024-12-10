return {
   {
      "onsails/lspkind.nvim",
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
   },
   {
      'hrsh7th/cmp-vsnip',
      dependencies = {
         --[[ vimscript based simplistic snippet engine ]]
         'hrsh7th/vim-vsnip',
         config = function()
            vim.g.vsnip_snippet_dir = vim.fn.expand("$HOME") .. '/dotfiles/snippets/vsnip_snippets'
            vim.g.vsnip_filetypes = {
               verilogsystemverilog = { 'verilog_ixcom' },
               sh = { 'sh_expansion' },
               tcl = { 'tcl_expansion' },
               qel = { 'tcl' },
            }
         end,
      },
   },
   {
      'hrsh7th/nvim-cmp',
      event = { 'InsertEnter', 'CmdlineEnter' },
      dependencies = {
         -- Snippet Engine & its associated nvim-cmp source
         {
            'L3MON4D3/LuaSnip',
            dependencies = {
               -- `friendly-snippets` contains a variety of premade snippets.
               --    See the README about individual language/framework/plugin snippets:
               --    https://github.com/rafamadriz/friendly-snippets
               {
                  'rafamadriz/friendly-snippets',
                  config = function()
                     require('luasnip.loaders.from_vscode').lazy_load()
                     require("luasnip.loaders.from_lua").load({ paths = { "~/dotfiles/snippets/lua_snippets/*.lua" } })
                  end,
               },
            },

         },
         'saadparwaiz1/cmp_luasnip',
      },

      config = function()
         local feedkey = function(key, mode)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
         end

         local cmp = require('cmp')
         local luasnip = require('luasnip')
         local lspkind = require('lspkind')

         luasnip.config.setup {}

         cmp.setup({
            view = {
               entries = "custom"
            },
            formatting = {
               fields = { "kind", "abbr", "menu" },
               expandable_indicator = true,
               format = lspkind.cmp_format({
                  with_text = true,
                  mode = "symbol_text",
                  menu = ({
                     vsnip = "[Vsnip]",
                     luasnip = "[Luasnip]",
                     nvim_lsp = "[LSP]",
                     path = "[Path]",
                     buffer = "[Buffer]",
                     nvim_lua = "[Lua]",
                     latex_symbols = "[Latex]",
                  })
               })
            },
            snippet = {
               expand = function(args)
                  if vim.fn.exists('*vsnip#anonymous') == 1 then
                     vim.fn["vsnip#anonymous"](args.body) -- Expand with Vsnip
                     -- elseif luasnip.expandable() then
                  else
                     luasnip.lsp_expand(args.body) -- Expand with LuaSnip
                     -- print("No snippet engine available!")
                  end
               end,
            },
            window = {
               completion = cmp.config.window.bordered({
                  winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
               }),
               documentation = cmp.config.window.bordered(),
            },
            completion = { completeopt = 'menu,menuone,preview,noinsert' },
            mapping = cmp.mapping.preset.insert({
               ['<C-n>'] = cmp.mapping.select_next_item(),
               ['<C-p>'] = cmp.mapping.select_prev_item(),
               ['<C-b>'] = cmp.mapping.scroll_docs(-4),
               ['<C-f>'] = cmp.mapping.scroll_docs(4),
               -- Manually trigger a completion from nvim-cmp.
               --  Generally you don't need this, because nvim-cmp will display
               --  completions whenever it has completion options available.
               ['<C-Space>'] = cmp.mapping.complete(),
               ['<C-e>'] = cmp.mapping.abort(),
               ['<C-y>'] = cmp.mapping.confirm({ select = true }),
               ['<C-l>'] = cmp.mapping(function(fallback)
                  if vim.fn["vsnip#jumpable"](1) == 1 then
                     feedkey('<Plug>(vsnip-jump-next)', "")
                  else
                     fallback()
                  end
               end, { "i", "s" }),
               ['<C-h>'] = cmp.mapping(function(fallback)
                  if vim.fn["vsnip#jumpable"](-1) == 1 then
                     feedkey('<Plug>(vsnip-jump-prev)', "")
                  else
                     fallback()
                  end
               end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
               { name = 'vsnip' },
               { name = 'luasnip' },
               { name = 'nvim_lsp', max_item_count = 8 },
               { name = 'path' },
               { name = 'buffer',   max_item_count = 3 }
            }),
         })
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
