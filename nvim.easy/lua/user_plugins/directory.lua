local cmp = require('cmp')

local directory_source = {}

-- Directory to read files from
local directory_path = "~/dotfiles/nvim.easy/nvim_notes"

-- Complete function for nvim-cmp
directory_source.complete = function(_, _, callback)
  local items = {}

  -- Expand `~` to the home directory
  local expanded_path = vim.fn.expand(directory_path)

  -- Use `vim.fn.readdir` to get files in the directory
  local files = vim.fn.readdir(expanded_path)

  for _, name in ipairs(files) do
    local file_path = expanded_path .. "/" .. name
    local file = io.open(file_path, "r")
    local content = file and file:read("*all") or "No content"
    if file then file:close() end

    -- Add to completion items
    table.insert(items, {
      label = name, -- File name as trigger
      documentation = content, -- File contents as documentation
      kind = cmp.lsp.CompletionItemKind.File, -- Kind
    })
  end

  callback(items)
end

-- Documentation resolver for showing file content
directory_source.resolve = function(_, completion_item, callback)
  if completion_item.documentation then
    completion_item.documentation = {
      kind = "markdown",
      value = completion_item.documentation,
    }
  end
  callback(completion_item)
end

return directory_source
