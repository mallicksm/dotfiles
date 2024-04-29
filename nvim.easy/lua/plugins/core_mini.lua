return {
   { -- Collection of various small independent plugins/modules
      'echasnovski/mini.nvim',
      config = function()
         -- Better Around/Inside textobjects
         --
         -- Examples:
         --  - va)  - [V]isually select [A]round [)]paren
         --  - yinq - [Y]ank [I]nside [N]ext [']quote
         --  - ci'  - [C]hange [I]nside [']quote
         require('mini.ai').setup({ n_lines = 500 })

         -- Add/delete/replace surroundings (brackets, quotes, etc.)
         --
         -- - ysiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
         -- - ds'   - [S]urround [D]elete [']quotes
         -- - cs)'  - [S]urround [R]eplace [)] [']
         require('mini.surround').setup({
            mappings = {
               add = 'ys',
               delete = 'ds',
               replace = 'cs',
               find = '',
               find_left = '',
               highlight = '',
               suffix_last = '',
               suffix_next = '',
            },
         })

         -- bring back my autopairs without complications
         require('mini.pairs').setup()

         -- ... and there is more!
         --  Check out: https://github.com/echasnovski/mini.nvim
      end,
   },
}
-- vim: ts=2 sts=2 sw=2 et
