return {
   'nvim-lualine/lualine.nvim',
   config = function()
      require('lualine').setup({
         options = {
            theme = 'dracula',
            disabled_filetypes = {
               statusline = { "neo-tree" },
            },
         },
         sections = {
            lualine_x = { "fileformat", "filetype" }
         },
         inactive_sections = {
            lualine_c = { { "filename", path = 1 } },
         },
      })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
