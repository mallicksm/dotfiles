return {
   {
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
            vim.g.vsnip_snippet_dir = '$HOME/dotfiles/snippets/vsnip_snippets'
            vim.g.vsnip_filetypes = {
               systemverilog = { 'verilog_ixcom' },
               sh = { 'sh_expansion' },
               tcl = { 'tcl_expansion' },
               qel = { 'tcl' },
            }
            vim.cmd [[
               imap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'
               imap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
            ]]
         end,
      },
   },
   {
      'hrsh7th/nvim-cmp',
      event = 'InsertEnter',
      config = function()
         local cmp = require('cmp')
         cmp.setup({
            snippet = {
               expand = function(args)
                  vim.fn["vsnip#anonymous"](args.body)
               end,
            },
            window = {
               completion = cmp.config.window.bordered(),
               documentation = cmp.config.window.bordered(),
            },
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
               { name = 'nvim_lsp' },
               { name = 'vsnip' },
               { name = 'path' },
               { name = 'buffer',  keyword_length = 5 },
            }, {}),
         })
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
