return {
   'stevearc/aerial.nvim',
   opts = {},
   dependencies = {
      "nvim-treesitter/nvim-treesitter", -- Treesitter for better symbol parsing
      "nvim-tree/nvim-web-devicons",     -- Icons for better UI
   },
   config = function()
      require("aerial").setup({
         -- Attach keymaps when aerial attaches to a buffer
         on_attach = function(bufnr)
            local map_opts = { buffer = bufnr, silent = true, noremap = true }
            vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>",
               vim.tbl_extend("force", map_opts, { desc = "Aerial: Jump to previous symbol" }))
            vim.keymap.set("n", "}", "<cmd>AerialNext<CR>",
               vim.tbl_extend("force", map_opts, { desc = "Aerial: Jump to next symbol" }))
         end,
         -- Additional configurations
         backends = { "treesitter", "lsp", "markdown" }, -- Use these providers
         filter_kind = false,                            -- Show all kinds of symbols, including variables
         layout = {
            default_direction = "prefer_right",          -- Prefer to open on the right
            placement = "window",                        -- Open aerial in the same window
         },
         icons = {
            Method = "ƒ",
            Function = "󰡱",
            Class = "󰠱",
            Interface = "",
            Module = "",
            Namespace = "󰦮",
            Variable = "󰂡",
         },
         show_guides = true,       -- Show hierarchy guides
         highlight_on_jump = true, -- Highlight symbol on jump
      })

      -- Keymap to toggle aerial
      vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle!<CR>", { desc = "Aerial: Toggle outline" })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
