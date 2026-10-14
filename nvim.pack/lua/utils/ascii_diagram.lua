-- :AsciiDiagram -- render a Graph::Easy DSL buffer (or range) as ASCII art.
--
-- Graph::Easy is pure Perl from CPAN, installed under ~/perl5 as a local::lib,
-- so its `graph-easy` script can't find its own modules without PERL5LIB. We
-- set that here rather than in the shell rc so the command works however nvim
-- was started (and without clobbering the PERL5LIB setup_proj already exports).
--
-- DSL is one edge per line, nodes in brackets:
--
--    [ TPS ] -> [ NIG ] -> [ MAC ]
--    [ NIG ] -- backpressure --> [ TPS ]
--
-- Default charset is boxart (Unicode); pass `ascii` for the portable +--+ set.

local M = {}

local LOCAL_LIB   = vim.fn.expand('~/perl5/lib/perl5')
local FALLBACK_BIN = vim.fn.expand('~/perl5/bin/graph-easy')
local PREVIEW_NAME = 'AsciiDiagram'
local MAX_WIDTH    = 100 -- cap on the preview split, wide diagrams scroll

M.charsets = { 'boxart', 'ascii' }

local function resolve_bin()
   local on_path = vim.fn.exepath('graph-easy')
   if on_path ~= '' then
      return on_path
   end
   if vim.fn.executable(FALLBACK_BIN) == 1 then
      return FALLBACK_BIN
   end
   return nil
end

---@return string[]|nil lines, string|nil err
local function render(lines, charset)
   local bin = resolve_bin()
   if not bin then
      return nil, ('graph-easy not found on $PATH or at %s -- install with: cpanm --local-lib=$HOME/perl5 Graph::Easy'):format(FALLBACK_BIN)
   end

   local perl5lib = vim.env.PERL5LIB and (LOCAL_LIB .. ':' .. vim.env.PERL5LIB) or LOCAL_LIB
   local ok, res = pcall(function()
      return vim
         .system({ bin, '--as=' .. charset }, {
            stdin = table.concat(lines, '\n') .. '\n',
            env   = { PERL5LIB = perl5lib },
            text  = true,
         })
         :wait(15000)
   end)

   if not ok then
      return nil, tostring(res)
   end
   if res.code ~= 0 then
      local err = vim.trim(res.stderr or '')
      return nil, err ~= '' and err or ('graph-easy exited ' .. tostring(res.code))
   end

   local out = vim.trim(res.stdout or '')
   if out == '' then
      -- graph-easy is happy to exit 0 on input it parsed as no graph at all
      local err = vim.trim(res.stderr or '')
      return nil, err ~= '' and err or 'graph-easy produced no output (is the range Graph::Easy DSL?)'
   end
   return vim.split(out, '\n', { plain = true })
end

local function preview_buf()
   for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(b) and vim.fs.basename(vim.api.nvim_buf_get_name(b)) == PREVIEW_NAME then
         return b
      end
   end
   return nil
end

local function preview(out)
   -- Focus stays in the DSL window throughout: the whole point is to edit,
   -- re-render, edit. Landing in the preview would make the next
   -- :AsciiDiagram try to parse the art it just produced.
   local from_win = vim.api.nvim_get_current_win()
   local buf = preview_buf()

   if not buf then
      buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, PREVIEW_NAME)
      vim.bo[buf].bufhidden = 'hide'
      vim.bo[buf].filetype  = 'text'
   end

   vim.bo[buf].modifiable = true
   vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
   vim.bo[buf].modifiable = false

   local win
   for _, w in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(w) == buf then
         win = w
         break
      end
   end

   if not win then
      vim.cmd('botright vsplit')
      win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(win, buf)
      vim.wo[win].wrap   = false
      vim.wo[win].number = false
   end

   local width = 0
   for _, l in ipairs(out) do
      width = math.max(width, vim.fn.strdisplaywidth(l))
   end
   vim.api.nvim_win_set_width(win, math.min(width + 2, MAX_WIDTH))
   pcall(vim.api.nvim_win_set_cursor, win, { 1, 0 })

   if vim.api.nvim_win_is_valid(from_win) then
      vim.api.nvim_set_current_win(from_win)
   end
end

---@param opts table the nvim_create_user_command callback argument
function M.run(opts)
   local charset = (opts.fargs or {})[1] or M.charsets[1]
   if not vim.tbl_contains(M.charsets, charset) then
      vim.notify(
         ('AsciiDiagram: unknown charset %q (want: %s)'):format(charset, table.concat(M.charsets, ', ')),
         vim.log.levels.ERROR
      )
      return
   end

   local src = vim.api.nvim_get_current_buf()
   if src == preview_buf() then
      vim.notify('AsciiDiagram: that is the rendered output -- run this from the DSL buffer', vim.log.levels.WARN)
      return
   end

   local lines = vim.api.nvim_buf_get_lines(src, opts.line1 - 1, opts.line2, false)
   if vim.trim(table.concat(lines, '')) == '' then
      vim.notify('AsciiDiagram: nothing to render', vim.log.levels.WARN)
      return
   end

   local out, err = render(lines, charset)
   if not out then
      vim.notify('AsciiDiagram: ' .. err, vim.log.levels.ERROR)
      return
   end

   if opts.bang then
      -- Insert below the source rather than replacing it: the DSL is the
      -- editable artifact, the art is disposable and can be re-rendered.
      vim.api.nvim_buf_set_lines(src, opts.line2, opts.line2, false, out)
   else
      preview(out)
   end
end

return M

-- vim: ts=3 sts=3 sw=3 et
