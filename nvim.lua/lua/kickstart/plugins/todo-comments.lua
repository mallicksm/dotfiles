-- Highlight todo, notes, etc in comments
return {
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    opts = {
      signs = true,
      keywords = {
        Note = {
          color = "info",
          icon = "📌",
        },
      }
    }
  },
}
-- vim: ts=2 sts=2 sw=2 et
