local M = {}

local function history_items(kind)
   local raw = vim.fn.execute('history ' .. kind)
   local lines = vim.split(raw, '\n', { trimempty = true })
   local out = {}
   -- :history output is oldest -> newest after two header lines. Walk backwards
   -- so index=1 is the most recent entry.
   for i = #lines, 3, -1 do
      local line = lines[i]
      local _, finish = line:find('%d+ +')
      if finish then
         local value = line:sub(finish + 1)
         if value ~= '' then
            out[#out + 1] = { value = value, ordinal = value, index = #out + 1 }
         end
      end
   end
   return out
end

local function recency_sorter()
   local sorters = require('telescope.sorters')
   local fzy = require('telescope.algos.fzy')
   local OFFSET = -fzy.get_score_floor()
   return sorters.Sorter:new({
      discard = true,
      scoring_function = function(_, prompt, line, entry)
         if prompt == '' then
            return entry.index or 1
         end
         if not fzy.has_match(prompt, line) then
            return -1
         end
         local score = fzy.score(prompt, line)
         if score == fzy.get_score_min() then
            score = fzy.get_score_floor()
         end
         local fuzzy = 1 / (score + OFFSET)
         return (entry.index or 1) + fuzzy
      end,
      highlighter = function(_, prompt, line)
         return fzy.positions(prompt, line)
      end,
   })
end

local function picker(kind, opts)
   opts = opts or {}
   local actions = require('telescope.actions')
   local finders = require('telescope.finders')
   local make_entry = require('telescope.make_entry')
   local pickers = require('telescope.pickers')

   local is_cmd = kind == 'cmd'
   pickers.new(opts, {
      prompt_title = opts.prompt_title or (is_cmd and 'Command History' or 'Search History'),
      finder = finders.new_table({
         results = history_items(kind),
         entry_maker = function(item)
            return make_entry.set_default_entry_mt({
               value = item.value,
               ordinal = item.ordinal,
               display = item.value,
               index = item.index,
            }, {})
         end,
      }),
      sorter = recency_sorter(),
      attach_mappings = function(_, map)
         if is_cmd then
            actions.select_default:replace(actions.set_command_line)
            map({ 'i', 'n' }, '<C-e>', actions.edit_command_line)
         else
            actions.select_default:replace(actions.set_search_line)
            map({ 'i', 'n' }, '<C-e>', actions.edit_search_line)
         end
         return true
      end,
   }):find()
end

function M.command_history(opts)
   picker('cmd', opts)
end

function M.search_history(opts)
   picker('search', opts)
end

return M
