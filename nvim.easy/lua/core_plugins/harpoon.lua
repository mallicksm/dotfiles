-- Telescope-backed picker for the harpoon list. Bound below as <leader>H.
local function harpoon_telescope_picker()
   local harpoon = require('harpoon')
   local picker_files = harpoon:list()
   local conf = require('telescope.config').values
   local file_paths = {}
   for _, item in ipairs(picker_files.items) do
      table.insert(file_paths, item.value)
   end
   require('telescope.pickers').new({}, {
      prompt_title = 'Harpoon (<esc> to quit)',
      finder = require('telescope.finders').new_table({ results = file_paths }),
      previewer = conf.file_previewer({}),
      sorter = conf.generic_sorter({}),
   }):find()
end

return {
   {
      'ThePrimeagen/harpoon',
      branch = 'harpoon2',
      dependencies = { 'nvim-lua/plenary.nvim' },
      keys = {
         {
            '<leader>a',
            function()
               require('harpoon'):list():add()
               vim.notify('Harpoon: added ' .. vim.fn.expand('%:t'), vim.log.levels.INFO)
            end,
            desc = 'Harpoon: Mark add',
         },
         { '<C-p>', function() require('harpoon'):list():prev() end, desc = 'Harpoon: previous' },
         { '<C-n>', function() require('harpoon'):list():next() end, desc = 'Harpoon: next' },
         {
            '<leader><C-h>',
            function()
               local harpoon = require('harpoon')
               harpoon.ui:toggle_quick_menu(harpoon:list())
            end,
            desc = 'Harpoon: Marks list',
         },
         { '<leader>H', harpoon_telescope_picker, desc = 'Telescope: [H]arpoon list' },
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
