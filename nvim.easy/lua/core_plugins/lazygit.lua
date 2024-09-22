return {
  {
    "voldikss/vim-floaterm",
    keys = {
      { "<leader>gl", "<cmd>FloatermNew --height=0.9 --width=0.9 --name=lazygit lazygit -ucf ~/.config/lazygit/config.yml<cr><cr>", desc = "LazyGit" },
      { "<leader>gt", "<cmd>FloatermNew --height=0.9 --width=0.9<cr><cr>", desc = "ToggleTerm" },
    }
  },
}
