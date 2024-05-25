return {
   'nvim-lualine/lualine.nvim',
   dependencies = {
      'kdheepak/tabline.nvim',
   },
   config = function()
      -- LSP clients attached to buffer
      local clients_lsp = function()
         local bufnr = vim.api.nvim_get_current_buf()
         local clients = vim.lsp.get_clients({ buffer = bufnr })
         if next(clients) == nil then
            return ''
         end
         local c = {}
         for _, client in pairs(clients) do
            table.insert(c, client.name)
         end
         return '\u{f085} ' .. table.concat(c, '\u{2016}')
      end

      require('lualine').setup({
         options = {
            theme = 'dracula',
            component_separators = { left = '\u{2016}', right = '\u{2016}' },
            disabled_filetypes = {
               statusline = {
                  "neo-tree",
                  "undotree",
                  "diff",
                  "aerial",
               },
            },
         },
         sections = {
            lualine_x = { "fileformat", clients_lsp, "filetype" },
         },
         inactive_sections = {
            lualine_c = { { "filename", path = 1 } },
         },
         tabline = {
            lualine_a = { require 'tabline'.tabline_buffers },
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {},
         },
      })
      require 'tabline'.setup({
         enable = true,
         options = {
            max_bufferline_percent = 100,
            show_filename_only = true,
            show_bufnr = true,
         },
      })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
