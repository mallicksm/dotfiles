return {
   { -- Collection of various small independent plugins/modules
      'echasnovski/mini.nvim',
      config = function()
         -- Better Around/Inside textobjects
         -- Examples:
         --  - vab  - b({[ [v]isually [a]round [b]lock
         --  - vaq  - q'"` [v]isually [a]round [q]uote
         --  - va?  - ?    [v]isually [a]round [?]user determined
         --  - vaf  - f    [v]isually [a]round [f]unction
         --  - vaa  - a    [v]isually [a]round [a]rgument
         require('mini.ai').setup({ n_lines = 500 })

         -- Add/delete/replace surroundings (brackets, quotes, etc.)
         -- Examples:
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
         require('mini.pairs').setup({
            mappings = {
            ["`"] = false,
            }
         })

         -- ... and there is more!
         --  Check out: https://github.com/echasnovski/mini.nvim
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
