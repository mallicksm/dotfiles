return {
   {
      -- nvim-cmp source
      "onsails/lspkind.nvim",
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
   },
   {
      -- luasnip Snippet Engine
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
   },
   {
      -- vsnip Snippet Engine
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
      config = function()
         local feedkey = function(key, mode)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
         end

         local cmp = require('cmp')
         local luasnip = require('luasnip')
         local lspkind = require('lspkind')

         luasnip.config.setup {}

         require("luasnip.loaders.from_lua").load({ paths = { "~/dotfiles/snippets/lua_snippets/" } })

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
                  mode          = "symbol_text",
                  maxwidth      = 50,
                  ellipsis_char = "...",
                  menu          = {
                     vsnip = "[Vsnip]",
                     luasnip = "[Luasnip]",
                     nvim_lsp = "[LSP]",
                     path = "[Path]",
                     buffer = "[Buffer]",
                     nvim_lua = "[Lua]",
                     latex_symbols = "[Latex]",
                  }
               })
            },
            snippet = {
               expand = function(args)
                  if vim.fn.exists('*vsnip#anonymous') == 1 then
                     vim.fn["vsnip#anonymous"](args.body) -- Expand with Vsnip
                  elseif luasnip.expandable() then
                     luasnip.lsp_expand(args.body)        -- Expand with LuaSnip
                  else
                     print("No snippet engine available!")
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
                  elseif luasnip.expand_or_locally_jumpable() then
                     luasnip.expand_or_jump()
                  else
                     fallback()
                  end
               end, { "i", "s" }),
               ['<C-h>'] = cmp.mapping(function(fallback)
                  if vim.fn["vsnip#jumpable"](-1) == 1 then
                     feedkey('<Plug>(vsnip-jump-prev)', "")
                  elseif luasnip.locally_jumpable() then
                     luasnip.jump(-1)
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
