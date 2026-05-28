--- :Utilities -- vim.ui.select dispatch into snacks.picker built-ins.
---
--- Bound from user_commands.lua via :Utilities. vim.ui.select is intercepted
--- by snacks.input (configured in core_plugins/snacks.lua), so the prompt
--- itself uses the same picker UI as the dispatch targets.
---
--- Picks one of: registers / colorscheme / helptags / autocommands /
--- commands / highlights / keymaps / marks. (Old telescope-only items --
--- vim_options and man_pages -- dropped on the telescope -> snacks.picker
--- migration; reach for vim's `:options` / `:Man` directly when needed.)

local M = {}

local choices = {
   { label = 'Vim Registers', fn = function() require('snacks').picker.registers()    end },
   { label = 'Colorscheme',   fn = function() require('snacks').picker.colorschemes() end },
   { label = 'Help Tags',     fn = function() require('snacks').picker.help()         end },
   { label = 'Autocommands',  fn = function() require('snacks').picker.autocmds()     end },
   { label = 'Commands',      fn = function() require('snacks').picker.commands()     end },
   { label = 'Highlights',    fn = function() require('snacks').picker.highlights()   end },
   { label = 'Keymaps',       fn = function() require('snacks').picker.keymaps()      end },
   { label = 'Marks',         fn = function() require('snacks').picker.marks()        end },
}

function M.open()
   vim.ui.select(choices, {
      prompt = 'Choose a Utility',
      format_item = function(c) return c.label end,
   }, function(choice)
      if choice then choice.fn() end
   end)
end

return M
-- vim: ts=3 sts=3 sw=3 et
