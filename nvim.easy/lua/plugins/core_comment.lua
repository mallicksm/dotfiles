-- "gc" to comment visual regions/lines
-- :help comment.usage for help on this topic
return {
   'numToStr/Comment.nvim',
   opts = {
      toggler = {
         line = 'gcc',
         block = 'gbc',
      },
      opleader = {
         line = 'gc',
         block = 'gb',
      },
      mappings = {
         extra = false,
      },
   },
   lazy = false,
}
-- vim: ts=3 sts=3 sw=3 et
