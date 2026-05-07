-- harpoon (branch: harpoon2) -- per-project file-mark list with quick nav.
local harpoon = require('harpoon')
harpoon:setup({
   settings = {
      save_on_toggle = false, -- save marks via :w on the menu, not toggle
   },
})
harpoon:extend({
   UI_CREATE = function(cx)
      vim.keymap.set('n', 'v', function() harpoon.ui:select_menu_item({ vsplit  = true }) end, { buffer = cx.bufnr })
      vim.keymap.set('n', 's', function() harpoon.ui:select_menu_item({ split   = true }) end, { buffer = cx.bufnr })
      vim.keymap.set('n', 't', function() harpoon.ui:select_menu_item({ tabedit = true }) end, { buffer = cx.bufnr })
   end,
})

-- Telescope-backed picker for the harpoon list (alternative to the native UI).
local function harpoon_telescope_picker()
   local picker_files = harpoon:list()
   local conf         = require('telescope.config').values
   local file_paths   = {}
   for _, item in ipairs(picker_files.items) do
      table.insert(file_paths, item.value)
   end
   require('telescope.pickers').new({}, {
      prompt_title = 'Harpoon (<esc> to quit)',
      finder       = require('telescope.finders').new_table({ results = file_paths }),
      previewer    = conf.file_previewer({}),
      sorter       = conf.generic_sorter({}),
   }):find()
end

vim.keymap.set('n', '<leader>a', function()
   harpoon:list():add()
   vim.notify('Harpoon: added ' .. vim.fn.expand('%:t'), vim.log.levels.INFO)
end, { desc = 'Harpoon: Mark add' })

vim.keymap.set('n', '<C-p>', function() harpoon:list():prev() end, { desc = 'Harpoon: previous' })
vim.keymap.set('n', '<C-n>', function() harpoon:list():next() end, { desc = 'Harpoon: next' })

vim.keymap.set('n', '<leader><C-h>', function()
   harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = 'Harpoon: Marks list' })

vim.keymap.set('n', '<leader>H', harpoon_telescope_picker, { desc = 'Telescope: [H]arpoon list' })

-- vim: ts=3 sts=3 sw=3 et
