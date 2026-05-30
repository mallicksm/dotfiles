vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevelstart = 99

local ensure_installed = {
   'lua',
   'c',
   'cpp',
   'python',
   'bash',
   'json',
   'markdown',
   'markdown_inline',
   'systemverilog',
   'vimdoc', -- highlights `:help` pages
   'tcl',    -- .qel / .fs map to ft=tcl (paired with tclint / tclfmt)
   'diff',   -- diff buffers, neogit views, gitcommit
   'make',   -- Makefiles (paired with after/ftplugin/make.lua)
}

return {
   'nvim-treesitter/nvim-treesitter',
   branch = 'main',
   dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter-textobjects' },
   lazy = false,
   build = ':TSUpdate',
   config = function()
      local ts = require('nvim-treesitter')
      -- nvim-treesitter main keeps some queries under runtime/queries; put
      -- that directory on rtp so languages missing builtin queries (asm/vmasm)
      -- get highlights.
      vim.opt.runtimepath:prepend(vim.fn.stdpath('data') .. '/lazy/nvim-treesitter/runtime')
      ts.install(ensure_installed)

      -- Map filetypes to their tree-sitter parser when the names differ.
      -- after/ftdetect/filetype.lua only ever sets ft=verilog_systemverilog (never
      -- 'verilog' or 'systemverilog'), so we only need that one alias.
      vim.treesitter.language.register('systemverilog', { 'verilog_systemverilog' })
      vim.treesitter.language.register('bash', { 'sh' })
      vim.treesitter.language.register('asm', { 'vmasm' })

      vim.api.nvim_create_autocmd('FileType', {
         group = vim.api.nvim_create_augroup('user-treesitter', { clear = true }),
         callback = function(args)
            local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
            if not lang then return end
            local ok = pcall(vim.treesitter.start, args.buf, lang)
            if ok and vim.bo[args.buf].filetype ~= 'verilog_systemverilog' then
               -- SV: no treesitter indents.scm; TS indentexpr returns 0 and
               -- fights vhda indent (indentkeys includes ';'). Keep GetVerilogSystemVerilogIndent().
               vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
         end,
      })
   end,
}
