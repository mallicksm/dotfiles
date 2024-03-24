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

      -- set some keymaps within tree
      local function my_on_attach(bufnr)
        local api = require "nvim-tree.api"

        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        -- default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- custom mappings
        vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open: Horizontal Split'))
        vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
        vim.keymap.set('n', 'u', api.tree.change_root_to_parent, opts('Up'))
        vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
      end

      local opt = {
        on_attach = my_on_attach,
        sync_root_with_cwd = true,
        hijack_cursor = true,
        reload_on_bufenter = true,
        sort = {
          sorter = "filetype",
        },
        view = {
          width = function()
            return math.floor(vim.api.nvim_win_get_width(0) / 2.5)
          end,
          signcolumn = "auto",
        },
        filters = {
          dotfiles = true,
        },
        git = {
          timeout = 500,
        },
        update_focused_file = {
          enable = true,
          update_root = true,
          ignore_list = { "help" },
        },
        help = {
          sort_by = "desc"
        },
        renderer = {
          root_folder_label = function(path)
            return "tree: " .. vim.fn.fnamemodify(path, ":~")
          end,
          indent_width = 4,
          highlight_opened_files = "name",
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
      vim.cmd([[nnoremap <leader>e :NvimTreeToggle<cr>]])
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
