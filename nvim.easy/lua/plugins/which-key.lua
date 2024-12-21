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
         { "<leader>m", group = "[F]ormat" },
         { "<leader>c", group = "[L]sp" },
         { "<leader>r", group = "[L]sp" },
         { "<leader>w", group = "[L]sp" },
         { "<leader>o", group = "[O]ptions" },
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
      },
   },
   config = function(_, opts)
      -- Document existing key chains
      require('which-key').setup(opts)
   end,
}
-- vim: ts=3 sts=3 sw=3 et
