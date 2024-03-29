return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },

    config = function()
      local harpoon = require('harpoon')
      harpoon:setup({
        settings = {
          -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
          save_on_toggle = false,
        }
      })
      harpoon:extend({
        UI_CREATE = function(cx)
          vim.keymap.set("n", "v", function()
            harpoon.ui:select_menu_item({ vsplit = true })
          end, { buffer = cx.bufnr })

          vim.keymap.set("n", "s", function()
            harpoon.ui:select_menu_item({ split = true })
          end, { buffer = cx.bufnr })

          vim.keymap.set("n", "t", function()
            harpoon.ui:select_menu_item({ tabedit = true })
          end, { buffer = cx.bufnr })
        end,
      })

      -- harpoon management edit(e) and add(a)
      vim.keymap.set("n", ",e", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
        { desc = "Harpoon: Open list edit" })
      vim.keymap.set("n", ",a", function() harpoon:list():append() end, { desc = "Harpoon: Append list" })

      -- remember by position 4 files, left right down and up
      vim.keymap.set("n", ",h", function() harpoon:list():select(1) end, { desc = "Harpoon: Select left" })
      vim.keymap.set("n", ",l", function() harpoon:list():select(2) end, { desc = "Harpoon: Select right" })
      vim.keymap.set("n", ",j", function() harpoon:list():select(3) end, { desc = "Harpoon: Select down" })
      vim.keymap.set("n", ",k", function() harpoon:list():select(4) end, { desc = "Harpoon: Select up" })

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set("n", ",p", function() harpoon:list():prev() end, { desc = "Harpoon: previous" })
      vim.keymap.set("n", ",n", function() harpoon:list():next() end, { desc = "Harpoon: next" })
    end
  }
}
