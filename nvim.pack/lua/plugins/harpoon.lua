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

-- All harpoon bindings live under <leader>H* (group label in plugins/which-key.lua).
-- Bare <leader>H is intentionally NOT bound -- keeping it as a pure prefix
-- avoids the 300ms timeout that would otherwise hit every <leader>HX press.
vim.keymap.set('n', '<leader>Ha', function()
   harpoon:list():add()
   vim.notify('Harpoon: added ' .. vim.fn.expand('%:t'), vim.log.levels.INFO)
end, { desc = 'Harpoon: [a]dd current file' })

vim.keymap.set('n', '<leader>Hn', function() harpoon:list():next() end, { desc = 'Harpoon: [n]ext mark' })
vim.keymap.set('n', '<leader>Hp', function() harpoon:list():prev() end, { desc = 'Harpoon: [p]rev mark' })

vim.keymap.set('n', '<leader>Hm', function()
   harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = 'Harpoon: quick [m]enu (native UI)' })

vim.keymap.set('n', '<leader>Hl', harpoon_telescope_picker, { desc = 'Harpoon: telescope [l]ist' })

-- Slot jumps. Primeagen's convention is 4 slots; bump the upper bound below
-- if you start carrying more around. select(N) is no-op when slot N is empty
-- (logs to harpoon's internal log, not the UI).
for i = 1, 4 do
   vim.keymap.set('n', '<leader>H' .. i, function() harpoon:list():select(i) end,
      { desc = 'Harpoon: jump to slot [' .. i .. ']' })
end

-- vim: ts=3 sts=3 sw=3 et
