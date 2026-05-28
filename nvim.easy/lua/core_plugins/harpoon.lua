-- snacks.picker-backed picker for the harpoon list. Bound below as <leader>Hl.
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
      -- All harpoon bindings live under <leader>H* (group label in mini.clue setup, core_plugins/mini.lua).
      -- Bare <leader>H is intentionally NOT bound -- keeping it as a pure prefix
      -- avoids the 300ms timeout that would otherwise hit every <leader>HX press.
      keys = {
         {
            '<leader>Ha',
            function()
               require('harpoon'):list():add()
               vim.notify('Harpoon: added ' .. vim.fn.expand('%:t'), vim.log.levels.INFO)
            end,
            desc = 'Harpoon: [a]dd current file',
         },
         { '<leader>Hn', function() require('harpoon'):list():next() end, desc = 'Harpoon: [n]ext mark' },
         { '<leader>Hp', function() require('harpoon'):list():prev() end, desc = 'Harpoon: [p]rev mark' },
         {
            '<leader>Hm',
            function()
               local harpoon = require('harpoon')
               harpoon.ui:toggle_quick_menu(harpoon:list())
            end,
            desc = 'Harpoon: quick [m]enu (native UI)',
         },
         { '<leader>Hl', harpoon_snacks_picker, desc = 'Harpoon: snacks-picker [l]ist' },
         -- Slot jumps. Primeagen's convention is 4 slots; bump the upper bound
         -- below if you start carrying more around. select(N) is no-op when
         -- slot N is empty (logs to harpoon's internal log, not the UI).
         { '<leader>H1', function() require('harpoon'):list():select(1) end, desc = 'Harpoon: jump to slot [1]' },
         { '<leader>H2', function() require('harpoon'):list():select(2) end, desc = 'Harpoon: jump to slot [2]' },
         { '<leader>H3', function() require('harpoon'):list():select(3) end, desc = 'Harpoon: jump to slot [3]' },
         { '<leader>H4', function() require('harpoon'):list():select(4) end, desc = 'Harpoon: jump to slot [4]' },
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
