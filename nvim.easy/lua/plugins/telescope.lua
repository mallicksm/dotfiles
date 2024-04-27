return {
   'nvim-telescope/telescope.nvim',
   tag = '0.1.6',
   dependencies = { 'nvim-lua/plenary.nvim' },
   config = function()
      require("telescope").setup({
         defaults = {
            mappings = {
               i = {['<esc>'] = require("telescope.actions").close},
            },
         },
      })
      local builtin = require("telescope.builtin")
      vim.keymap.set('n', ',e', function()
         builtin.find_files {
            prompt_title = "Find Files (<esc> to quit)"
         }
      end, { desc = "Telescope: [e]xplorer" })
      vim.keymap.set('n', ',g', function()
         builtin.find_files {
            prompt_title = "Grep Files (<esc> to quit)"
         }
      end, { desc = "Telescope: [e]xplorer" })
   end
}
-- vim: ts=3 sts=3 sw=3 et
