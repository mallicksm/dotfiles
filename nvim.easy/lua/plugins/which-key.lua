return {
   'folke/which-key.nvim',
   event = 'VimEnter',
   opts = {
      icons = {
         mappings = true,
         keys = {}
      },
      spec = {
         { "<leader>d", group = "[D]ap" },
         { "<leader>g", group = "[G]it" },
         { "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "[G]it: toggle current line [b]lame" },
         { "<leader>n", group = "[N]oice" },
         { "<leader>t", group = "[t]elescope" },          -- <leader>t{f,g,b,d} -- see plugins/{telescope,smart-open}.lua
         { "<leader>m", group = "[M]ore tools (fmt/lnt)" }, -- <leader>mp=format, <leader>ml=lint
         { "<leader>c", group = "[C]ode action" },          -- <leader>ca (LSP, set on LspAttach)
         { "<leader>s", group = "[S]earch (kaleido)" },     -- <leader>s{s,n,a,c,l} kaleidosearch
         { "<leader>r", group = "[R]ename" },               -- <leader>rn (LSP, set on LspAttach)
         { "<leader>w", group = "[W]orkspace symbol" },     -- <leader>ws (LSP, set on LspAttach)
         -- (<leader>o group emptied; oo and ou both moved to <leader>v* family)
         { "<leader>H", group = "[H]arpoon" },              -- <leader>H{a,n,p,m,l} -- see core_plugins/harpoon.lua
         { "<leader>v", group = "[V]iew toggles + vim introspect" },  -- option toggles + :registers/:marks/:messages/etc -- see keymaps.lua
         { "s",         group = "[S]urround (mini)" }, -- sa/sd/sr/sf/sF/sh on upstream defaults; see core_plugins/mini.lua
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
