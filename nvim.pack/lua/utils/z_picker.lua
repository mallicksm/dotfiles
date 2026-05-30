--- snacks.picker over rupa/z's frecency database.
---
--- Reads ~/.z (or $_Z_DATA if set), parses the `dir|rank|time` format, sorts
--- by rank descending. Default action: :lcd to selected dir. <C-f> action:
--- :lcd then immediately fire snacks.picker.files in that dir (the "z + file
--- pick" combo without leaving nvim).
---
--- z.sh stores: <abs_path>|<rank_float>|<unix_time>
---   rank is incremented on each cd, decayed by sqrt of $_Z_MAX_SCORE (default
---   9000) so frequently+recently used dirs bubble to the top.
---
--- Bound from snacks.lua keys table as <leader>ed.
--- Telescope-version replaced on the telescope -> snacks.picker migration.

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
   local z_path  = vim.env._Z_DATA or vim.fn.expand('~/.z')
   local entries = read_z_file(z_path)
   if #entries == 0 then
      vim.notify('z picker: no entries at ' .. z_path .. ' (cd around to populate)', vim.log.levels.WARN)
      return
   end

   -- snacks.picker items: each needs `text` for the matcher; `file` lets us
   -- reuse the built-in file/dir previewer. `rank` is carried as extra metadata
   -- and rendered into the display.
   local items = {}
   for _, e in ipairs(entries) do
      items[#items + 1] = {
         text = e.dir,
         file = e.dir,
         dir  = e.dir,
         rank = e.rank,
      }
   end

   require('snacks').picker.pick({
      source = 'z',
      title  = 'z directories (frecency, <CR>=lcd, <C-f>=lcd+files)',
      items  = items,
      -- Custom 2-column display: right-aligned rank, then dir.
      format = function(item, _)
         local rank_str = string.format('%8.1f', item.rank)
         return {
            { rank_str,  'SnacksPickerComment' },
            { '  ',                              },
            { item.dir,  'SnacksPickerDir'     },
         }
      end,
      preview = 'directory',
      confirm = function(picker, item)
         picker:close()
         if not item then return end
         vim.cmd.lcd(item.dir)
         vim.notify('lcd ' .. item.dir, vim.log.levels.INFO)
      end,
      -- <C-f>: lcd into the dir THEN immediately open snacks.picker.files
      -- scoped to it. Killer "z + file pick" combo.
      win = {
         input = {
            keys = {
               ['<c-f>'] = { 'z_lcd_and_files', mode = { 'n', 'i' } },
            },
         },
      },
      actions = {
         z_lcd_and_files = function(picker)
            local item = picker:current()
            picker:close()
            if not item then return end
            vim.cmd.lcd(item.dir)
            require('snacks').picker.files({
               cwd   = item.dir,
               title = 'Find Files in ' .. item.dir,
            })
         end,
      },
   })
end

return M
-- vim: ts=3 sts=3 sw=3 et
