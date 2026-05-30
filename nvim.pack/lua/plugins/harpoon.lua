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

-- snacks.picker-backed picker for the harpoon list (alternative to the native
-- UI). Rewritten from a telescope picker on the telescope -> snacks.picker
-- migration. Custom items with `file = <path>` so snacks's default file
-- previewer Just Works.
local function harpoon_snacks_picker()
   local items = {}
   for idx, item in ipairs(harpoon:list().items) do
      items[#items + 1] = {
         idx  = idx,
         file = item.value,
         text = item.value,
      }
   end
   require('snacks').picker.pick({
      source  = 'harpoon',
      title   = 'Harpoon (<esc> to quit)',
      items   = items,
      format  = 'file',
      preview = 'file',
      confirm = function(picker, item)
         picker:close()
         if item then vim.cmd.edit(vim.fn.fnameescape(item.file)) end
      end,
   })
end

-- Harpoon under <leader>eh* (nested in the +[e]xplorer family). No bare
-- <leader>eh binding -- prefix only, same timeout rationale as old <leader>H*.
vim.keymap.set('n', '<leader>eha', function()
   harpoon:list():add()
   vim.notify('Harpoon: added ' .. vim.fn.expand('%:t'), vim.log.levels.INFO)
end, { desc = '[e]xplorer: harpoon [a]dd current file' })

vim.keymap.set('n', '<leader>ehn', function() harpoon:list():next() end, { desc = '[e]xplorer: harpoon [n]ext mark' })
vim.keymap.set('n', '<leader>ehp', function() harpoon:list():prev() end, { desc = '[e]xplorer: harpoon [p]rev mark' })

vim.keymap.set('n', '<leader>ehm', function()
   harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = '[e]xplorer: harpoon quick [m]enu (native UI)' })

vim.keymap.set('n', '<leader>ehl', harpoon_snacks_picker, { desc = '[e]xplorer: harpoon snacks-picker [l]ist' })

-- Slot jumps. Primeagen's convention is 4 slots; bump the upper bound below
-- if you start carrying more around. select(N) is no-op when slot N is empty
-- (logs to harpoon's internal log, not the UI).
for i = 1, 4 do
   vim.keymap.set('n', '<leader>eh' .. i, function() harpoon:list():select(i) end,
      { desc = '[e]xplorer: harpoon slot [' .. i .. ']' })
end

-- vim: ts=3 sts=3 sw=3 et
