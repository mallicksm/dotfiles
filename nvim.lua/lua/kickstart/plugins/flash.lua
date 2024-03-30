return {
  {
    "folke/flash.nvim",
    config = function()
      require("flash").setup({
        modes = {
          char = {
            enabled = false,
          }
        }
      })
    end,
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  }
}
