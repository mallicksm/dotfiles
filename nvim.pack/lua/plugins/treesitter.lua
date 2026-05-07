-- nvim-treesitter (main branch). Fold via treesitter, install required parsers,
-- enable highlight via FileType autocmd. ts.install() is async; first launch
-- on a fresh checkout downloads parsers.
vim.opt.foldmethod     = 'expr'
vim.opt.foldexpr       = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevelstart = 99

local ensure_installed = {
   'lua', 'c', 'cpp', 'python', 'bash', 'json',
   'markdown', 'markdown_inline',
   'systemverilog',
   'vimdoc',  -- :help pages
   'tcl',     -- .qel / .fs map to ft=tcl
   'diff',    -- diff buffers, neogit views, gitcommit
   'make',    -- Makefiles
}

local ts = require('nvim-treesitter')
ts.install(ensure_installed)

-- ftdetect/filetype.lua only emits ft=verilog_systemverilog (never 'verilog'
-- or 'systemverilog'), so we only need that one alias. Same for sh -> bash.
vim.treesitter.language.register('systemverilog', { 'verilog_systemverilog' })
vim.treesitter.language.register('bash', { 'sh' })

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

-- vim: ts=3 sts=3 sw=3 et
