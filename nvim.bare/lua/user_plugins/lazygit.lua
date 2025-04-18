-- Define keymap functions
local function open_lazygit()
   vim.cmd("FloatermNew --height=0.9 --width=0.9 --name=lazygit lazygit -ucf ~/.config/lazygit/config.yml")
end
local function open_term()
   vim.cmd("FloatermNew --height=0.9 --width=0.9")
end

-- Create a Vim command to use elsewhere
vim.api.nvim_create_user_command("OpenLazyGit", open_lazygit, {})

return {
   {
      "voldikss/vim-floaterm",
      lazy = false,
      keys = {
         -- Key mapping for LazyGit
         {
            "<leader>gl",
            open_lazygit,
            desc = "LazyGit",
         },
         -- Key mapping for a generic floating terminal
         {
            "<leader>gt",
            open_term,
            desc = "ToggleTerm"
         },
      }
   },
}
