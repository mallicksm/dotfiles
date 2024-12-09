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
         basic = true,     -- Enable basic mappings (e.g., `gcc` and `gbc`)
         extra = false,    -- Disable extra mappings (e.g., `gco`, `gcO`)
         extended = false, -- Enable extended mappings for operator-pending mode
      },
   },
   config = function(_, opts)
      require('Comment').setup(opts)
   end,

   lazy = false,
}
-- vim: ts=3 sts=3 sw=3 et
