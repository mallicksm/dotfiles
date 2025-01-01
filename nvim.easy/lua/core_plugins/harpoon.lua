return {
   {
      'ThePrimeagen/harpoon',
      branch = 'harpoon2',
      dependencies = { 'nvim-lua/plenary.nvim' },

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

         -- harpoon management edit(e) and add(a)
         vim.keymap.set('n', '<leader>a', function()
            harpoon:list():append()
            print('Harpoon: appended ' .. vim.fn.expand('%:t'))
         end, { desc = 'Harpoon: Mark add' })

         -- Toggle previous & next buffers stored within Harpoon list
         vim.keymap.set('n', '<C-p>', function()
            harpoon:list():prev()
         end, { desc = 'Harpoon: previous' })
         vim.keymap.set('n', '<C-n>', function()
            harpoon:list():next()
         end, { desc = 'Harpoon: next' })

         -- harpoon list
         vim.keymap.set('n', '<C-h>', function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
         end, { desc = 'Harpoon: Marks list' })

         -- basic telescope configuration
         local conf = require("telescope.config").values
         local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
               table.insert(file_paths, item.value)
            end

            require("telescope.pickers").new({}, {
               prompt_title = "Harpoon (<esc> to quit)",
               finder = require("telescope.finders").new_table({
                  results = file_paths,
               }),
               previewer = conf.file_previewer({}),
               sorter = conf.generic_sorter({}),
            }):find()
         end

         vim.keymap.set("n", "<leader>H", function() toggle_telescope(harpoon:list()) end,
            { desc = "Telescope: [H]arpoon list" })
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
