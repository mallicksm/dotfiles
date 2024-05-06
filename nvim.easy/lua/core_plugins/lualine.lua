return {
   'nvim-lualine/lualine.nvim',
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
      })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
