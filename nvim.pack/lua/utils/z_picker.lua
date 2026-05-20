--- Telescope picker over rupa/z's frecency database.
---
--- Reads ~/.z (or $_Z_DATA if set), parses the `dir|rank|time` format, sorts
--- by rank descending. Default action: :lcd to selected dir. <C-f> action:
--- :lcd then immediately fire find_files in that dir (the "z + file pick"
--- combo without leaving nvim).
---
--- z.sh stores: <abs_path>|<rank_float>|<unix_time>
---   rank is incremented on each cd, decayed by sqrt of $_Z_MAX_SCORE (default
---   9000) so frequently+recently used dirs bubble to the top.
---
--- Bound from keymaps.lua as <leader>td (under the <leader>t* telescope family).

local M = {}

---@param path string
---@return table[] list of { dir, rank, time } sorted by rank descending
local function read_z_file(path)
   local entries = {}
   local f = io.open(path, 'r')
   if not f then return entries end
   for line in f:lines() do
      -- "dir|rank|time" -- dir may itself contain anything except '|'
      local dir, rank, time = line:match('^(.-)|([%d%.eE+-]+)|(%d+)$')
      if dir and rank then
         table.insert(entries, { dir = dir, rank = tonumber(rank), time = tonumber(time) })
      end
   end
   f:close()
   table.sort(entries, function(a, b) return a.rank > b.rank end)
   return entries
end

function M.open()
   local pickers       = require('telescope.pickers')
   local finders       = require('telescope.finders')
   local conf          = require('telescope.config').values
   local actions       = require('telescope.actions')
   local action_state  = require('telescope.actions.state')
   local entry_display = require('telescope.pickers.entry_display')

   local z_path  = vim.env._Z_DATA or vim.fn.expand('~/.z')
   local entries = read_z_file(z_path)
   if #entries == 0 then
      vim.notify('z picker: no entries at ' .. z_path .. ' (cd around to populate)', vim.log.levels.WARN)
      return
   end

   -- Two columns: rank (right-aligned 10 chars) and dir (rest of the line).
   local displayer = entry_display.create({
      separator = '  ',
      items = {
         { width = 10, right_justify = true },
         { remaining = true },
      },
   })

   pickers.new({}, {
      prompt_title = 'z directories (frecency, <CR>=lcd, <C-f>=lcd+find)',
      finder = finders.new_table({
         results = entries,
         entry_maker = function(e)
            return {
               value   = e.dir,
               ordinal = e.dir,
               display = function()
                  return displayer({
                     { string.format('%.1f', e.rank), 'TelescopeResultsNumber' },
                     { e.dir,                          'TelescopeResultsField'  },
                  })
               end,
            }
         end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
         actions.select_default:replace(function()
            local sel = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if not sel then return end
            vim.cmd.lcd(sel.value)
            vim.notify('lcd ' .. sel.value, vim.log.levels.INFO)
         end)
         -- <C-f> -- lcd into the directory THEN immediately run find_files
         -- scoped to that cwd. Killer "z + file pick" combo.
         map({ 'i', 'n' }, '<C-f>', function()
            local sel = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if not sel then return end
            vim.cmd.lcd(sel.value)
            require('telescope.builtin').find_files({
               cwd = sel.value,
               prompt_title = 'Find Files in ' .. sel.value,
            })
         end)
         return true
      end,
   }):find()
end

return M
-- vim: ts=3 sts=3 sw=3 et
