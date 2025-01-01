return {
   {
      -- nvim-cmp source
      "onsails/lspkind.nvim",
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
   },
   {
      -- luasnip Snippet Engine
      {
         'L3MON4D3/LuaSnip',
         lazy = true,
         opts = {
            delete_check_events = "TextChanged",
            update_events = { "TextChanged", "TextChangedI" },
         },
      },
      'saadparwaiz1/cmp_luasnip',
   },
   {
      'hrsh7th/nvim-cmp',
      lazy = false,
      priority = 100,
      event = { 'InsertEnter', 'CmdlineEnter' },
      config = function()
         local lspkind = require('lspkind')
         lspkind.init {}

         local cmp = require('cmp')
         local luasnip = require('luasnip')

         require("luasnip.loaders.from_lua").load({ paths = { lua_snippet_dir } })
         require("luasnip.loaders.from_vscode").load({ paths = { vscode_snippet_dir } })
         vim.opt.completeopt = { "menu", "menuone", "noselect" }

         -- Load custom source nvim_notes
         cmp.register_source('directory', require('user_plugins.nvim_notes'))

         cmp.setup({
            view = {
               entries = "custom"
            },
            formatting = {
               fields = {
                  "abbr",
                  "kind",
                  "menu"
               },
               expandable_indicator = true,
               format = lspkind.cmp_format({
                  mode = "symbol_text",
                  menu = {
                     luasnip = "[Luasnip]",
                     nvim_lsp = "[LSP]",
                     path = "[Path]",
                     buffer = "[Buffer]",
                     nvim_lua = "[Lua]",
                     directory = "[Dir]",
                  }
               })
            },
            snippet = {
               expand = function(args)
                  luasnip.lsp_expand(args.body) -- Expand with LuaSnip
               end,
            },
            window = {
               completion = cmp.config.window.bordered({
                  winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
               }),
               documentation = cmp.config.window.bordered({
                  winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
               }),
            },
            mapping = cmp.mapping.preset.insert({
               ['<C-n>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
               ['<C-p>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
               ['<C-b>'] = cmp.mapping.scroll_docs(-4),
               ['<C-f>'] = cmp.mapping.scroll_docs(4),
               -- Manually trigger a completion from nvim-cmp.
               --  Generally you don't need this, because nvim-cmp will display
               --  completions whenever it has completion options available.
               ['<C-Space>'] = cmp.mapping.complete(),
               ['<C-e>'] = cmp.mapping.abort(),
               ['<C-y>'] = cmp.mapping(
                  cmp.mapping.confirm {
                     behavior = cmp.ConfirmBehavior.Insert,
                     select = true
                  },
                  { "i", "c" }
               ),
               ['<C-l>'] = cmp.mapping(function(fallback)
                  if luasnip.expand_or_locally_jumpable() then
                     luasnip.expand_or_jump()
                  else
                     fallback()
                  end
               end, { "i", "s" }
               ),
               ['<C-h>'] = cmp.mapping(function(fallback)
                  if luasnip.locally_jumpable(-1) then
                     luasnip.jump(-1)
                  else
                     fallback()
                  end
               end, { "i", "s" }),
               ['<Tab>'] = cmp.mapping(function(fallback)
                  if luasnip.choice_active() then
                     luasnip.change_choice(1)
                  else
                     fallback()
                  end
               end, { "i", "s" }
               ),
            }),
            sources = cmp.config.sources({
               { name = 'luasnip' },
               { name = 'directory' },
               { name = 'nvim_lsp', max_item_count = 8 },
               { name = 'path' },
               { name = 'buffer',   max_item_count = 3 }
            }),
         })

         -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
         cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
               { name = 'buffer' }
            }
         })

         -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
         cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources(
               {
                  {
                     name = 'path',
                     max_item_count = 10,
                  }
               }, {
                  {
                     name = 'cmdline',
                     max_item_count = 20,
                     keyword_length = 3,
                  },
               }),
         })

      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
