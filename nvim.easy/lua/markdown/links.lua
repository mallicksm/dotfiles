--- Markdown link follower used by after/ftplugin/markdown.lua.
---
--- Recognises three link forms:
---   - inline       `[label](target)`
---   - reference    `[label][ref]`, collapsed `[label][]`, and the
---                  `[ref]: target` definition line itself.
---
--- and three target kinds:
---   - `#anchor`        -> jumps to <a id="anchor"></a> or to a heading whose
---                         slug matches `anchor`.
---   - `https://...` /  -> opens via xdg-open (system browser / mailto).
---     `mailto:...`
---   - file path        -> :edit relative-to-current-file path. Strips any
---                         trailing `#anchor` from the path.
---
--- Public surface:
---   M.follow_link()      -- the action; bound to <CR> in a markdown buffer
---   M.setup_keymaps()    -- buffer-local <CR> + <BS> bindings; call from ftplugin
---
--- Why a module: keeps after/ftplugin/markdown.lua thin and lets other
--- ftplugins (e.g. .mdc, .txt with markdown-style links) reuse the same logic
--- by calling setup_keymaps() themselves.

local M = {}

local function slugify(s)
   s = s:lower()
   s = s:gsub('[^%w%s%-]', '')
   s = s:gsub('[%s_%-]+', '-')
   s = s:gsub('^%-+', ''):gsub('%-+$', '')
   return s
end

-- Scans the buffer for a `[ref]: target` definition. Reference labels are
-- case-insensitive per the markdown spec.
local function resolve_ref(ref)
   local needle = ref:lower()
   for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
      local key, target = line:match('^%s*%[([^%]]+)%]:%s+(%S+)')
      if key and key:lower() == needle then
         return target
      end
   end
   return nil
end

-- Returns (label, target) of the markdown link the cursor is sitting inside,
-- or (nil, nil) if there isn't one. Iterates over the matches on the current
-- line and picks the one whose byte-range covers the cursor column.
-- A reference with no matching definition returns (label, nil, ref).
local function link_at_cursor()
   local line = vim.api.nvim_get_current_line()
   local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-indexed

   for s, label, target, e in line:gmatch('()%[([^%]]+)%]%(([^%)]+)%)()') do
      if col >= s and col < e then
         return label, target
      end
   end

   for s, label, ref, e in line:gmatch('()%[([^%]]+)%]%[([^%]]*)%]()') do
      if col >= s and col < e then
         ref = ref ~= '' and ref or label -- collapsed `[label][]`
         return label, resolve_ref(ref), ref
      end
   end

   -- Sitting on the definition line itself: follow it like any other target.
   local key, target = line:match('^%s*%[([^%]]+)%]:%s+(%S+)')
   if key then
      return key, target
   end

   return nil, nil
end

-- Try `<a id="anchor">` first (databook / pdf-converted markdown), then fall
-- back to slugify-matching against any heading line.
local function jump_to_anchor(anchor)
   anchor = anchor:gsub('^#', '')
   local needle_html = '<a id="' .. anchor .. '"></a>'

   local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
   for i, line in ipairs(lines) do
      if line:find(needle_html, 1, true) then
         vim.api.nvim_win_set_cursor(0, { i, 0 })
         vim.cmd('normal! zz')
         return true
      end
   end
   for i, line in ipairs(lines) do
      local hashes, title = line:match('^(#+)%s+(.*)$')
      if hashes and slugify(title) == anchor then
         vim.api.nvim_win_set_cursor(0, { i, 0 })
         vim.cmd('normal! zz')
         return true
      end
   end
   return false
end

function M.follow_link()
   local _, target, badref = link_at_cursor()
   if not target then
      if badref then
         vim.notify('undefined link reference: [' .. badref .. ']', vim.log.levels.WARN)
      else
         vim.notify('no markdown link under cursor', vim.log.levels.INFO)
      end
      return
   end

   if target:match('^#') then
      if not jump_to_anchor(target) then
         vim.notify('anchor not found: ' .. target, vim.log.levels.WARN)
      end
      return
   end

   if target:match('^https?://') or target:match('^mailto:') then
      if vim.fn.executable('xdg-open') == 1 then
         vim.fn.system('xdg-open ' .. vim.fn.shellescape(target))
         vim.notify('opening: ' .. target)
      else
         vim.notify('xdg-open not available', vim.log.levels.WARN)
      end
      return
   end

   -- Relative or absolute file path. Strip trailing #anchor before checking
   -- file existence; we don't currently honor cross-file anchors, just open the file.
   local path = target
   if not path:match('^/') and vim.fn.expand('%') ~= '' then
      path = vim.fn.expand('%:p:h') .. '/' .. path
   end
   path = path:gsub('#.*$', '')
   if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
      vim.cmd('edit ' .. vim.fn.fnameescape(path))
   else
      vim.notify('cannot resolve link target: ' .. target, vim.log.levels.WARN)
   end
end

-- Buffer-local keymaps. Call from after/ftplugin/markdown.lua (or any other
-- ftplugin where markdown-style links are useful).
function M.setup_keymaps()
   vim.keymap.set('n', '<CR>', M.follow_link, {
      buffer = 0,
      silent = true,
      desc = 'Follow markdown link (#anchor / file / URL)',
   })
   vim.keymap.set('n', '<BS>', '<C-o>', {
      buffer = 0,
      silent = true,
      desc = 'Jump back (jumplist)',
   })
end

return M
-- vim: ts=3 sts=3 sw=3 et
