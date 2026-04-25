--- Native blink.cmp source: serves files in ~/dotfiles/nvim_notes as
--- completion items where the label is the filename and the docs popup
--- shows the file contents.

local directory_path = '~/dotfiles/nvim_notes'

---@class blink.cmp.Source
local source = {}

function source.new()
   return setmetatable({}, { __index = source })
end

function source:enabled()
   return vim.fn.isdirectory(vim.fn.expand(directory_path)) == 1
end

function source:get_completions(_, callback)
   local items = {}
   local expanded = vim.fn.expand(directory_path)

   for _, name in ipairs(vim.fn.readdir(expanded)) do
      local file_path = expanded .. '/' .. name
      local fd = io.open(file_path, 'r')
      local content = fd and fd:read('*all') or 'No content'
      if fd then fd:close() end

      table.insert(items, {
         label = name,
         kind = vim.lsp.protocol.CompletionItemKind.File,
         documentation = { kind = 'markdown', value = content },
      })
   end

   callback({
      items = items,
      is_incomplete_backward = false,
      is_incomplete_forward = false,
   })

   return function() end
end

function source:resolve(item, callback)
   callback(item)
end

return source
