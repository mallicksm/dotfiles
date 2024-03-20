return {
  { -- Useful plugin to show you pending keybinds.
    'nvim-tree/nvim-tree.lua',
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      -- disable netrw at the very start of your init.lua
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- optionally enable 24-bit colour
      vim.opt.termguicolors = true
      local opt = {
        sort = {
          sorter = "filetype",
        },
        view = {
          width = function()
            return math.floor(vim.api.nvim_win_get_width(0) / 2.8)
          end,
          signcolumn = "auto",
        },
        filters = {
          dotfiles = true,
        },
        git = {
           timeout = 500,
        },
        renderer = {
          add_trailing = false,
          indent_width = 4,
          indent_markers = {
            enable = true,
            icons = {
              edge = "│",
              item = "│",
              corner = "│",
              bottom = " ",
            },
          },
        },
      }
      require("nvim-tree").setup(opt)
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
