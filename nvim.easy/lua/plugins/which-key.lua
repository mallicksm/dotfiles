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
         { "<leader>n", group = "[N]oice" },
         { "<leader>t", group = "[T]oggle" },
         { "<leader>m", group = "[M]ore tools (fmt/lnt)" }, -- <leader>mp=format, <leader>ml=lint
         { "<leader>c", group = "[C]ode action" },          -- <leader>ca (LSP, set on LspAttach)
         { "<leader>r", group = "[R]ename" },               -- <leader>rn (LSP, set on LspAttach)
         { "<leader>w", group = "[W]orkspace symbol" },     -- <leader>ws (LSP, set on LspAttach)
         { "<leader>o", group = "[O]ptions" },              -- <leader>oo=symbols, ou=undo, ob=buffers
         { "<leader>b", group = "[B]uffer delete" },
         { "<Esc>",     hidden = true },
         { "<leader>h", hidden = true },
         { "<leader>l", hidden = true }, -- fix for checkhealth which-key
         { "<leader>j", hidden = true },
         { "<leader>k", hidden = true },
         { "sh",        hidden = true }, -- fix for checkhealth which-key
         { "gc",        hidden = true }, -- fix for checkhealth which-key
         { "sr",        hidden = true }, -- fix for checkhealth which-key
         { "sf",        hidden = true }, -- fix for checkhealth which-key
         { "sF",        hidden = true }, -- fix for checkhealth which-key
         { "sd",        hidden = true }, -- fix for checkhealth which-key
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
