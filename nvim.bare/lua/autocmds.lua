--------------------------------------------------------------------------------
--- Basic Autocommands
--------------------------------------------------------------------------------
-- <leader>K for more info on cWORD lua-guide-autocommands`
-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
   group = vim.api.nvim_create_augroup('last_loc', { clear = true }),
   callback = function(event)
      local exclude = { "gitcommit" }
      local buf = event.buf
      if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
         return
      end
      vim.b[buf].lazyvim_last_loc = true
      local mark = vim.api.nvim_buf_get_mark(buf, '"')
      local lcount = vim.api.nvim_buf_line_count(buf)
      if mark[1] > 0 and mark[1] <= lcount then
         pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
   end,
})

--------------------------------------------------------------------------------
--- Basic user functions
--------------------------------------------------------------------------------
-- The first argument is the name of the command (which must start with an uppercase letter).
vim.api.nvim_create_user_command("Filename",
   function()
      vim.print("User: " .. vim.fn.expand('%:p'))
   end, { nargs = 0 })

vim.api.nvim_create_user_command("Explorer",
   function()
      local builtin = require 'telescope.builtin'
      builtin.find_files({
         prompt_title = 'Find Files (<esc> to quit)'
      })
   end, { nargs = 0 })

vim.api.nvim_create_user_command("Rg",
   function()
      local builtin = require 'telescope.builtin'
      builtin.live_grep({
         prompt_title = 'Live Grep in Open Files (<esc> to quit)',
      })
   end, { nargs = 0 })

vim.api.nvim_create_user_command("Git",
   function()
      vim.cmd('Neogit kind=auto')
   end, { nargs = 0 })

vim.api.nvim_create_user_command("Utilities", function()
   local actions = require('telescope.actions')
   local action_state = require('telescope.actions.state')
   local pickers = require('telescope.pickers')
   local finders = require('telescope.finders')
   local conf = require('telescope.config').values

   pickers.new({}, {
      prompt_title = "Choose an Option",
      finder = finders.new_table({
         results = {
            { "Vim Options",      "vim_options" },
            { "Vim Registers",    "registers" },
            { "Colorscheme",  "colorscheme" },
            { "Vim Helptags",     "help_tags" },
            { "Unix Manpages",     "man_pages" },
            { "Autocommands", "autocommands" },
         },
         entry_maker = function(entry)
            return {
               value = entry,
               display = entry[1],
               ordinal = entry[1],
            }
         end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function()
         actions.select_default:replace(function(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            local builtin = require('telescope.builtin')
            if selection.value[2] == "vim_options" then
               builtin.vim_options({
                  prompt_title = 'Vim Options (<esc> to quit)',
               })
            elseif selection.value[2] == "registers" then
               builtin.registers({
                  prompt_title = 'Vim Registers (<esc> to quit)',
               })
            elseif selection.value[2] == "colorscheme" then
               builtin.colorscheme({
                  prompt_title = 'Colorschemes (<esc> to quit)',
                  enable_preview = true
               })
            elseif selection.value[2] == "help_tags" then
               builtin.help_tags({
                  prompt_title = 'Helptags (<esc> to quit)',
               })
            elseif selection.value[2] == "man_pages" then
               builtin.man_pages({
                  prompt_title = 'Manpages (<esc> to quit)',
               })
            elseif selection.value[2] == "autocommands" then
               builtin.autocommands({
                  prompt_title = 'Autocommands (<esc> to quit)',
               })
            end
         end)
         return true
      end,
   }):find()
end, { nargs = 0 })
-- vim: ts=3 sts=3 sw=3 et
