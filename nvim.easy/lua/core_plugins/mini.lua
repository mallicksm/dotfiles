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
         require('mini.ai').setup(
            {
               n_lines = 500,
               custom_textobjects = {
                  l = function()
                     local line_start = vim.fn.line('.')
                     local line_end = line_start
                     local col_start = 1
                     local col_end = #vim.fn.getline(line_start) + 1
                     return {
                        from = { line = line_start, col = col_start },
                        to = { line = line_end, col = col_end },
                     }
                  end,
               },
            }
         )

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
         require('mini.pairs').setup({
            mappings = {
               ["`"] = false,
            },
            disable_filetypes = {
               'TelescopePrompt',
               'NvimTree',
               'neo-tree'
            },
         })

         -- ... and there is more!
         --  Check out: https://github.com/echasnovski/mini.nvim
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
