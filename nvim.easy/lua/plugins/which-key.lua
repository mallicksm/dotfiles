return {
   'folke/which-key.nvim',
   event = 'VimEnter',
   opts = {
      icons = {
         mappings = true,
         keys = {}
      },
      spec = {
         { "<leader>d", group = "[D]ap", icon = { icon = "󰃤", color = "red" } },
         { "<leader>g", group = "[G]it", icon = { cat = "filetype", name = "git", color = "green" } },
         { "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "[G]it: toggle current line [b]lame", icon = { icon = "󰍡", color = "grey" } },
         { "<leader>p", group = "ls[p]", icon = { icon = "󰒋", color = "blue" } }, -- LSP: pd=type def, ps=workspace symbols, pr=rename, pa=code action, po=outline, pv=virt-text-toggle, pf=format, pl=lint
         { "<leader>t", group = "[t]elescope", icon = { icon = "󰍉", color = "azure" } },          -- <leader>t{f,g,b,d} -- see plugins/{telescope,smart-open}.lua
         { "<leader>s", group = "[S]earch (kaleido)", icon = { icon = "󰫖", color = "purple" } },     -- <leader>s{s,n,a,c,l} kaleidosearch
         { "<leader>H", group = "[H]arpoon", icon = { icon = "󰀢", color = "blue" } },              -- <leader>H{a,n,p,m,l} -- see core_plugins/harpoon.lua
         { "<leader>v", group = "[V]im", icon = { icon = "󰈈", color = "azure" } },  -- option toggles + :registers/:marks/:messages/etc -- see keymaps.lua
         { "<leader>V", group = "[V]im tools", icon = { icon = "󰈉", color = "cyan" } }, -- <leader>Vb = neo-tree buffer panel, <leader>Vu = undotree
         { "<leader>Vn", group = "[V]n -> [N]oice", icon = { icon = "󰂞", color = "yellow" } }, -- <leader>Vnc=clear, <leader>Vnm=messages
         { "s", group = "[S]urround (mini)", icon = { icon = "󰅪", color = "purple" } }, -- sa/sd/sr/sf/sF/sh on upstream defaults; see core_plugins/mini.lua
         { "<Esc>",     hidden = true },
         { "<leader>h", hidden = true },
         { "<leader>l", hidden = true }, -- fix for checkhealth which-key
         { "<leader>j", hidden = true },
         { "<leader>k", hidden = true },
         { "gc",        hidden = true }, -- fix for checkhealth which-key
         { "<leader>e", hidden = true }, -- hide all wellknown leaders
         { "<leader>q", hidden = true },
         { "<leader>x", hidden = true },
         { "<leader>K", hidden = true },
      },
   },
   config = function(_, opts)
      -- Document existing key chains
      require('which-key').setup(opts)
   end,
}
-- vim: ts=3 sts=3 sw=3 et
