--- Switch the active markdown previewer at runtime.
---
--- Both render-markdown.nvim and markview.nvim are installed; only one should
--- render at a time. The :MdViewer user command (registered in user_commands.lua)
--- delegates to M.set() here.
---
--- Accepted choices (case-insensitive, with abbreviations):
---   render | render-markdown | rm   -> render-markdown.nvim
---   markview | mv                   -> markview.nvim
---   none | off                      -> disable both (raw markdown view)
---   '' | status                     -> just print the choices

local M = {}

local function quiet(cmd)
   pcall(vim.cmd, 'silent! ' .. cmd)
end

function M.set(choice)
   choice = (choice or ''):lower()

   if choice == '' or choice == 'status' then
      vim.notify('md viewer choices: render | markview | none')
      return
   end

   if choice == 'render' or choice == 'render-markdown' or choice == 'rm' then
      quiet('Markview Disable')
      quiet('RenderMarkdown enable')
      vim.notify('md viewer: render-markdown')
   elseif choice == 'markview' or choice == 'mv' then
      quiet('RenderMarkdown disable')
      quiet('Markview Enable')
      -- Ensure the current buffer (if markdown) is attached/refreshed.
      quiet('Markview attach')
      vim.notify('md viewer: markview')
   elseif choice == 'none' or choice == 'off' then
      quiet('RenderMarkdown disable')
      quiet('Markview Disable')
      vim.notify('md viewer: off')
   else
      vim.notify('Usage: :MdViewer {render|markview|none}', vim.log.levels.WARN)
   end
end

return M
-- vim: ts=3 sts=3 sw=3 et
