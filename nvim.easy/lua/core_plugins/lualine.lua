return {
   'nvim-lualine/lualine.nvim',
   config = function()
      local lualine = require('lualine')
      local active_config = nil
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

      local default_config = {
         options = {
            theme = 'dracula',
            component_separators = { left = '\u{2016}', right = '\u{2016}' },
            disabled_filetypes = {
               statusline = {
                  "neo-tree",
                  "undotree",
                  "diff",
                  "Outline",
               },
            },
         },
         sections = {
            lualine_b = { 'branch', 'diff' },
            lualine_c = { { 'filename', path = 0 } },
            lualine_x = { "fileformat", clients_lsp, "filetype" },
         },
         inactive_sections = {
            lualine_c = {
               {
                  inactive,
                  color = { fg = '#ffff00', gui = 'italic' }
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
      }
      local alternate_config = {
         sections = {
            lualine_b = { 'branch' },
            lualine_c = { { 'filename', path = 3 } },
            lualine_x = {},
         },
      }
      -- Function to toggle between configurations
      local function toggle_lualine()
         active_config = active_config == default_config and alternate_config or default_config
         lualine.setup(active_config)
      end

      lualine.setup(default_config)

      vim.keymap.set("n", "<localleader>l", toggle_lualine, { desc = "Toggle lualine" })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
