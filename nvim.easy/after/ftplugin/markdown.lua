-- Buffer-local extras for markdown.

-- Soft-wrap long lines at word boundaries (the converted PDF .md files have
-- table cells wrapped to 150 cols already, but body paragraphs can be longer).
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true

----------------------------------------------------------------------------
-- <CR> follows a markdown link under the cursor.
--   `[text](#anchor)`     -> jump to <a id="anchor"> or matching heading
--   `[text](path/file)`   -> :edit path/file (relative to current file's dir)
--   `[text](https://...)` -> open via xdg-open (matches the smart-open elsewhere)
----------------------------------------------------------------------------

local function slugify(s)
   s = s:lower()
   s = s:gsub('[^%w%s%-]', '')
   s = s:gsub('[%s_%-]+', '-')
   s = s:gsub('^%-+', ''):gsub('%-+$', '')
   return s
end

local function link_at_cursor()
   local line = vim.api.nvim_get_current_line()
   local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-indexed
   for s, label, target, e in line:gmatch('()%[([^%]]+)%]%(([^%)]+)%)()') do
      if col >= s and col < e then
         return label, target
      end
   end
   return nil, nil
end

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

local function follow_markdown_link()
   local _, target = link_at_cursor()
   if not target then
      vim.notify('no markdown link under cursor', vim.log.levels.INFO)
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
   -- Relative or absolute file path
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

vim.keymap.set('n', '<CR>', follow_markdown_link, {
   buffer = 0,
   silent = true,
   desc = 'Follow markdown link (#anchor / file / URL)',
})

vim.keymap.set('n', '<BS>', '<C-o>', {
   buffer = 0,
   silent = true,
   desc = 'Jump back (jumplist)',
})

-- vim: ts=3 sts=3 sw=3 et
