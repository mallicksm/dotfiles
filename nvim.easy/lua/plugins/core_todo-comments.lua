-- Highlight todo, notes, etc in comments
return {
   {
      'folke/todo-comments.nvim',
      event = 'VimEnter',
      dependencies = {
         'nvim-lua/plenary.nvim',
      },
      opts = {
         signs = true,
         keywords = {
            TODO = { icon = ' ', color = 'info' },
            HACK = { icon = ' ', color = 'warning' },
            WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
            PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
            Note = { icon = ' ', color = 'hint', alt = { 'INFO' } },
            TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
         },
      },
   },
}
-- vim: ts=2 sts=2 sw=2 et
