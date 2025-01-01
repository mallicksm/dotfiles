-- Add custom key mapping for toggling background
return {
   { -- Collection of various small independent plugins/modules
      'echasnovski/mini.nvim',
      config = function()
         -----------------------------------------------------
         -- <leader>K for more info on cWORD MiniBasics.config
         -----------------------------------------------------
         require('mini.basics').setup({
            options = {
               -- Extra UI features ('winblend', 'cmdheight=0', ...)
               extra_ui = true,
            },
            mappings = {
               -- Window navigation with <C-hjkl>, resize with <C-arrow>
               -- windows = true,
            },
         })
         -------------------------------------------------------------
         -- <leader>K for more info on cWORD MiniExtra
         -------------------------------------------------------------
         require('mini.extra').setup()

         -------------------------------------------------------------
         -- <leader>K for more info on cWORD MiniAi-textobject-builtin
         -------------------------------------------------------------
         require('mini.ai').setup({
            custom_textobjects = {
               B = require('mini.extra').gen_ai_spec.buffer(),
               L = require('mini.extra').gen_ai_spec.line()
            }
         })

         -------------------------------------------------------
         -- <leader>K for more info on cWORD MiniSurround.config
         -------------------------------------------------------
         require('mini.surround').setup()

         ----------------------------------------------------
         -- <leader>K for more info on cWORD MiniPairs.config
         ----------------------------------------------------
         require('mini.pairs').setup({
            mappings = {
               ["`"] = false,
            },
            disable_filetypes = {
               'TelescopePrompt',
               'NvimTree',
               'neo-tree'
            },
         })

         ------------------------------------------------
         -- <leader>K for more info on cWORD mini.comment
         ------------------------------------------------
         require('mini.comment').setup()

         ------------------------------------------------
         -- <leader>K for more info on cWORD MiniStarter-example-config
         ------------------------------------------------
         local builtin = require("telescope.builtin")
         local harpoon = require('harpoon')
         require('mini.starter').setup({
            evaluate_single = true,
            -- https://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=LAZYVIM
            header = table.concat({
               "███╗   ██╗██╗   ██╗██╗███╗   ███╗   ███████╗ █████╗ ███████╗██╗   ██╗",
               "████╗  ██║██║   ██║██║████╗ ████║   ██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝",
               "██╔██╗ ██║██║   ██║██║██╔████╔██║   █████╗  ███████║███████╗ ╚████╔╝ ",
               "██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║   ██╔══╝  ██╔══██║╚════██║  ╚██╔╝  ",
               "██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║██╗███████╗██║  ██║███████║   ██║   ",
               "╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝╚═╝╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ",
            }, "\n"
            ),
            items = {
               {
                  name = 'recent Files',
                  action = function()
                     builtin.oldfiles({
                        prompt_title = "Recent Files (<esc> to quit)"
                     })
                  end,
                  section = 'Search'
               },
               {
                  name = 'find Files',
                  action = function()
                     builtin.find_files({
                        prompt_title = "Find Files (<esc> to quit)"
                     })
                  end,
                  section = 'Search'
               },
               {
                  name = 'live grep',
                  action = function()
                     builtin.live_grep({
                        prompt_title = "LiveGrep Files (<esc> to quit)"
                     })
                  end,
                  section = 'Search'
               },
               {
                  name = 'harpoon',
                  action = function()
                     harpoon.ui:toggle_quick_menu(harpoon:list())
                  end,
                  section = 'Search'
               },
               {
                  name = 'git Status',
                  action = 'Telescope git_status',
                  section = 'Git'
               },
               {
                  name = 'lazygit',
                  action = function() require("snacks").lazygit() end,
                  section = 'Git'
               },
               {
                  name = "nvim config Files",
                  action = function()
                     require("telescope.builtin").find_files({ cwd = "~/dotfiles/nvim.easy" })
                  end,
                  section = "Config",
               },
               { name = 'new File', action = 'enew', section = 'Actions' },
               { name = 'quit',     action = 'qa',   section = 'Actions' },
            },
            content_hooks = {
               require('mini.starter').gen_hook.adding_bullet('● '), -- Adds ● before each item
               require('mini.starter').gen_hook.aligning('center', 'center') -- Centers items on the screen
            },
         })
         ---------------------------------------------------
         -- <leader>K for more info on cWORD mini.hipatterns
         ---------------------------------------------------
         require('mini.hipatterns').setup({
            highlighters = {
               -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
               fixme     = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
               hack      = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
               todo      = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
               note      = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

               -- Highlight hex color strings (`#rrggbb`) using that color
               hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
            },

         })
         --  Check out: https://github.com/echasnovski/mini.nvim
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
