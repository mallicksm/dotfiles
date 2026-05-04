--- Smart "open thing under cursor" dispatcher used by <leader>K.
---
--- Order of attempts:
---   1. <cWORD> looks like a URL  -> xdg-open (system browser / mailto handler)
---   2. <cWORD> has a man page    -> :Man <word>
---   3. fallback                  -> :help <word>
---   4. nothing matches           -> warn
---
--- Bound from lua/keymaps.lua via `require('utils.smart_open').open()`.

local M = {}

local function is_url(text)
   return text:match("^https?://") ~= nil
end

function M.open()
   -- <cWORD> = whitespace-delimited token, so it captures URLs / hyphenated names.
   local word = vim.fn.expand("<cWORD>")

   if is_url(word) then
      if vim.fn.executable("xdg-open") ~= 1 then
         vim.notify("xdg-open not found on your system", vim.log.levels.ERROR)
         return
      end
      vim.fn.system("xdg-open " .. vim.fn.shellescape(word))
      vim.notify("Opening URL: " .. word, vim.log.levels.INFO)
      return
   end

   -- Try man page; `man -w` prints the resolved path (or fails) without rendering.
   if vim.fn.executable("man") == 1 then
      vim.fn.system("man -w " .. word)
      if vim.v.shell_error == 0 then
         vim.cmd("Man " .. word)
         return
      end
   end

   -- Fallback to vim help.
   local ok = pcall(vim.cmd, "help " .. word)
   if not ok then
      vim.notify("No man page or help available for: " .. word, vim.log.levels.WARN)
   end
end

return M
-- vim: ts=3 sts=3 sw=3 et
