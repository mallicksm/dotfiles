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
            -- usefull to jump between snippet anchors
            -- Expand
            vim.keymap.set({ "i", "s" }, "<c-j>", function()
               if vim.fn["vsnip#expandable"]() == 1 then
                  return '<Plug>(vsnip-expand)'
               else
                  return "<c-j>"
               end
            end, { expr = true, remap = true })
            -- Expand or jump
            vim.keymap.set({ "i", "s" }, "<c-k>", function()
               if vim.fn["vsnip#available"](1) == 1 then
                  return '<Plug>(vsnip-expand-or-jump)'
               else
                  return "<c-k>"
               end
            end, { expr = true, remap = true })
            -- Jump forward
            vim.keymap.set({ "i", "s" }, "<Tab>", function()
               if vim.fn["vsnip#jumpable"](1) == 1 then
                  return '<Plug>(vsnip-jump-next)'
               else
                  return "<Tab>"
               end
            end, { expr = true, remap = true })
            -- Jump backword
            vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
               if vim.fn["vsnip#jumpable"](-1) == 1 then
                  return '<Plug>(vsnip-jump-prev)'
               else
                  return "<S-Tab>"
               end
            end, { expr = true, remap = true })
         end,
      },
   },
   {
      'hrsh7th/nvim-cmp',
      event = 'InsertEnter',
      config = function()
         local cmp = require('cmp')
         local lspkind = require('lspkind')
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
                  vim.fn["vsnip#anonymous"](args.body)
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
               ['<C-Space>'] = cmp.mapping.complete(),
               ['<C-e>'] = cmp.mapping.abort(),
               ['<C-y>'] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
               { name = 'vsnip' },
               { name = 'nvim_lsp', max_item_count = 8 },
               { name = 'path' },
               { name = 'buffer',   max_item_count = 3 }
            }),
         })
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
