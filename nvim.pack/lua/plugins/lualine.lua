-- lualine -- statusline.
local lualine = require('lualine')

local clients_lsp = function()
   local bufnr = vim.api.nvim_get_current_buf()
   local clients = vim.lsp.get_clients({ buffer = bufnr })
   local c = {}
   for _, client in pairs(clients) do
      if client.attached_buffers and client.attached_buffers[bufnr] then
         table.insert(c, client.name)
      end
   end
   if vim.tbl_isempty(c) then return 'No LSP' end
   return '\u{f085} ' .. table.concat(c, '\u{2016}')
end

local function inactive()
   local filename = vim.fn.expand('%:p') or '[no name]'
   return 'inactive:' .. filename
end

local default_config = {
   options = {
      theme              = 'dracula',
      component_separators = { left = '\u{2016}', right = '\u{2016}' },
      disabled_filetypes = {
         -- 'nvim-undotree' is the filetype set by nvim 0.12's built-in undotree
         -- (mbbill/undotree, now removed, used 'undotree').
         statusline = { 'neo-tree', 'nvim-undotree', 'diff', 'Outline' },
      },
   },
   sections = {
      lualine_b = { 'branch', 'diff' },
      lualine_c = { { 'filename', path = 0 } },
      lualine_x = {
         'fileformat',
         clients_lsp,
         function()
            local ft = vim.bo.filetype
            return ft == 'verilog_systemverilog' and 'sv' or ft
         end,
      },
   },
   inactive_sections = {
      lualine_c = { { inactive, color = { fg = '#ffff00', gui = 'italic' } } },
   },
   tabline = {
      lualine_a = { { 'tabs', tab_max_length = 60, max_length = 200, mode = 2 } },
      lualine_b = {}, lualine_c = {}, lualine_x = {}, lualine_y = {}, lualine_z = {},
   },
}

lualine.setup(default_config)

-- vim: ts=3 sts=3 sw=3 et
