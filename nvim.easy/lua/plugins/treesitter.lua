vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevelstart = 99

local ensure_installed = { 'lua', 'c', 'cpp', 'python', 'bash', 'json', 'markdown', 'markdown_inline', 'verilog' }

return {
   'nvim-treesitter/nvim-treesitter',
   branch = 'main',
   dependencies = { 'nvim-lua/plenary.nvim' },
   lazy = false,
   build = ':TSUpdate',
   config = function()
      local ts = require('nvim-treesitter')
      ts.install(ensure_installed)

      vim.api.nvim_create_autocmd('FileType', {
         group = vim.api.nvim_create_augroup('user-treesitter', { clear = true }),
         callback = function(args)
            local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
            if not lang then return end
            local ok = pcall(vim.treesitter.start, args.buf, lang)
            if ok then
               vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
         end,
      })
   end,
}
