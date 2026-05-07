--- Multi-choice telescope picker for built-in vim/telescope utilities.
---
--- Bound from user_commands.lua via :Utilities. Picks one of:
---   options / registers / colorscheme / helptags / man pages / autocommands
--- and forwards to the corresponding telescope.builtin picker with a nicer title.

local M = {}

-- Display name -> telescope.builtin function name.
local choices = {
   { 'Vim Options',   'vim_options' },
   { 'Vim Registers', 'registers' },
   { 'Colorscheme',   'colorscheme' },
   { 'Vim Helptags',  'help_tags' },
   { 'Unix Manpages', 'man_pages' },
   { 'Autocommands',  'autocommands' },
}

-- Per-builtin prompt overrides ('<esc> to quit' is set globally in plugins/telescope.lua).
local titles = {
   vim_options  = 'Vim Options (<esc> to quit)',
   registers    = 'Vim Registers (<esc> to quit)',
   colorscheme  = 'Colorschemes (<esc> to quit)',
   help_tags    = 'Helptags (<esc> to quit)',
   man_pages    = 'Manpages (<esc> to quit)',
   autocommands = 'Autocommands (<esc> to quit)',
}

function M.open()
   local actions      = require('telescope.actions')
   local action_state = require('telescope.actions.state')
   local pickers      = require('telescope.pickers')
   local finders      = require('telescope.finders')
   local conf         = require('telescope.config').values

   pickers.new({}, {
      prompt_title = 'Choose an Option',
      finder = finders.new_table({
         results = choices,
         entry_maker = function(entry)
            return { value = entry, display = entry[1], ordinal = entry[1] }
         end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function()
         actions.select_default:replace(function(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)

            local key = selection.value[2]
            local builtin = require('telescope.builtin')
            local opts = { prompt_title = titles[key] }
            if key == 'colorscheme' then
               opts.enable_preview = true
            end
            builtin[key](opts)
         end)
         return true
      end,
   }):find()
end

return M
-- vim: ts=3 sts=3 sw=3 et
