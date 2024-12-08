return {
   'nvim-lualine/lualine.nvim',
   config = function()
      -- LSP clients attached to buffer
      local clients_lsp = function()
         local bufnr = vim.api.nvim_get_current_buf()
         local clients = vim.lsp.get_clients({ buffer = bufnr })
         local c = {}

         for _, client in pairs(clients) do
            if client.attached_buffers and client.attached_buffers[bufnr] then
               table.insert(c, client.name)
            end
         end

         if vim.tbl_isempty(c) then
            return 'No LSP'
         end

         return '\u{f085} ' .. table.concat(c, '\u{2016}')
      end
      local function inactive()
         local filename = vim.fn.expand('%:p') or '[no name]'
         return 'inactive:' .. filename
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
            lualine_c = {
               {
                  inactive,
               },
            },
         },
         tabline = {
            lualine_a = {
               {
                  'tabs',
                  tab_max_length = 60,
                  max_length = 200,
                  mode = 2,
               }
            },
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {},
         },
      })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
