-- Real autocmds only. User commands moved to lua/user_commands.lua.
-- See `:help lua-guide-autocommands` for the API.

-- Open PDFs in the system's default viewer (vim.ui.open dispatches to `open` on macOS,
-- `xdg-open` on Linux, etc.). Leaves a small placeholder buffer in nvim so we don't
-- accidentally close the editor when the PDF was the sole argument.
vim.api.nvim_create_autocmd('BufReadCmd', {
   pattern = '*.pdf',
   callback = function()
      local fname = vim.fn.fnamemodify(vim.fn.expand('<afile>'), ':p')

      vim.bo.buftype = 'nofile'
      vim.bo.bufhidden = 'wipe'
      vim.bo.swapfile = false
      -- Rename the placeholder so the buffer name does NOT end in `.pdf`.
      -- snacks.image keys off the extension and would otherwise try to
      -- render the file as an inline PNG via `magick` (failing loudly when
      -- ImageMagick isn't installed -- exactly the case here). The rename
      -- also matches the historical `foo.pdf.txt` naming the old
      -- pdftotext.py flow used.
      pcall(vim.api.nvim_buf_set_name, 0, fname .. '.opened')
      vim.b.snacks_image = false -- belt-and-suspenders against snacks.image
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {
         '-- Opened ' .. fname .. ' in the system PDF viewer --',
         '',
         'Use :bd to close this placeholder buffer.',
      })
      vim.bo.modifiable = false
      vim.bo.readonly = true

      -- NB: use jobstart (not vim.ui.open / vim.system) so the child doesn't
      -- inherit captured pipes that some viewers trip on with thumbnailer
      -- warnings. Plain shell `xdg-open foo.pdf` is clean because stdio is
      -- just the tty -- jobstart+detach mirrors that.
      --
      -- On Linux, open in evince. To use a different viewer, swap 'evince'
      -- below for whatever's in PATH (or use 'xdg-open' to follow the system
      -- default association).
      local cmd
      if vim.fn.has('mac') == 1 then
         cmd = { 'open', fname }
      else
         cmd = { 'evince', fname }
      end
      local ok, jid = pcall(vim.fn.jobstart, cmd, { detach = true })
      if not ok or jid <= 0 then
         vim.notify('Failed to launch PDF viewer: ' .. tostring(jid), vim.log.levels.ERROR)
      end
   end,
})

-- Restore the cursor to its last position when re-opening a buffer.
vim.api.nvim_create_autocmd('BufReadPost', {
   group = vim.api.nvim_create_augroup('last_loc', { clear = true }),
   callback = function(event)
      local exclude = { 'gitcommit' }
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

-- vim: ts=3 sts=3 sw=3 et

-- Persist per-file fold/view state across sessions. `loadview` is scheduled so
-- treesitter foldexpr / filetype setup has finished before folds are restored.
vim.opt.viewoptions = { "folds", "cursor" }

local persist_view_group = vim.api.nvim_create_augroup("user-persist-view", { clear = true })
local persist_view_exclude = {
   gitcommit = true,
   gitrebase = true,
   help = true,
   qf = true,
   TelescopePrompt = true,
}

local function can_persist_view(buf)
   if not vim.api.nvim_buf_is_valid(buf) then return false end
   if vim.bo[buf].buftype ~= "" then return false end
   if vim.api.nvim_buf_get_name(buf) == "" then return false end
   if persist_view_exclude[vim.bo[buf].filetype] then return false end
   return true
end

vim.api.nvim_create_autocmd("BufWinLeave", {
   group = persist_view_group,
   callback = function(event)
      if can_persist_view(event.buf) then
         pcall(vim.cmd.mkview, { mods = { emsg_silent = true } })
      end
   end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
   group = persist_view_group,
   callback = function(event)
      if not can_persist_view(event.buf) then return end
      vim.schedule(function()
         if can_persist_view(event.buf) then
            pcall(vim.cmd.loadview, { mods = { emsg_silent = true } })
         end
      end)
   end,
})
