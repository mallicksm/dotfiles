-- snacks.picker-backed picker for the harpoon list. Bound below as <leader>ehl.
-- (Used to be a telescope picker; rewritten on the telescope -> snacks.picker
-- migration. Builds custom items with `file = <path>` so snacks's default
-- file previewer Just Works.)
local function harpoon_snacks_picker()
   local harpoon = require('harpoon')
   local items   = {}
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

return {
   {
      'ThePrimeagen/harpoon',
      branch = 'harpoon2',
      dependencies = { 'nvim-lua/plenary.nvim' },
      -- Harpoon under <leader>eh* (nested in the +[e]xplorer family). No bare
      -- <leader>eh binding -- prefix only, same timeout rationale as old <leader>H*.
      keys = {
         {
            '<leader>eha',
            function()
               require('harpoon'):list():add()
               vim.notify('Harpoon: added ' .. vim.fn.expand('%:t'), vim.log.levels.INFO)
            end,
            desc = '[e]xplorer: harpoon [a]dd current file',
         },
         { '<leader>ehn', function() require('harpoon'):list():next() end, desc = '[e]xplorer: harpoon [n]ext mark' },
         { '<leader>ehp', function() require('harpoon'):list():prev() end, desc = '[e]xplorer: harpoon [p]rev mark' },
         {
            '<leader>ehm',
            function()
               local harpoon = require('harpoon')
               harpoon.ui:toggle_quick_menu(harpoon:list())
            end,
            desc = '[e]xplorer: harpoon quick [m]enu (native UI)',
         },
         { '<leader>ehl', harpoon_snacks_picker, desc = '[e]xplorer: harpoon snacks-picker [l]ist' },
         -- Slot jumps. Primeagen's convention is 4 slots; bump the upper bound
         -- below if you start carrying more around. select(N) is no-op when
         -- slot N is empty (logs to harpoon's internal log, not the UI).
         { '<leader>eh1', function() require('harpoon'):list():select(1) end, desc = '[e]xplorer: harpoon slot [1]' },
         { '<leader>eh2', function() require('harpoon'):list():select(2) end, desc = '[e]xplorer: harpoon slot [2]' },
         { '<leader>eh3', function() require('harpoon'):list():select(3) end, desc = '[e]xplorer: harpoon slot [3]' },
         { '<leader>eh4', function() require('harpoon'):list():select(4) end, desc = '[e]xplorer: harpoon slot [4]' },
      },

      config = function()
         local harpoon = require('harpoon')
         harpoon:setup({
            settings = {
               -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
               save_on_toggle = false,
            },
         })
         harpoon:extend({
            UI_CREATE = function(cx)
               vim.keymap.set('n', 'v', function()
                  harpoon.ui:select_menu_item({ vsplit = true })
               end, { buffer = cx.bufnr })

               vim.keymap.set('n', 's', function()
                  harpoon.ui:select_menu_item({ split = true })
               end, { buffer = cx.bufnr })

               vim.keymap.set('n', 't', function()
                  harpoon.ui:select_menu_item({ tabedit = true })
               end, { buffer = cx.bufnr })
            end,
         })

      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
