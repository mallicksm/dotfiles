--- Recursively format every *.sv / *.svh / *.v under cwd via conform.nvim.
---
--- Bound from user_commands.lua via :FormatAllSV. Uses the verible_verilog_format
--- formatter args declared in lua/code_plugins/formatting.lua, so house-style
--- indentation/alignment stays consistent with single-buffer formatting.

local M = {}

function M.format_all_in_cwd()
   local uv = vim.uv or vim.loop
   local cwd = uv.cwd()
   local pats = { '**/*.sv', '**/*.svh', '**/*.v' }

   -- Collect files recursively.
   local files = {}
   for _, pat in ipairs(pats) do
      for _, f in ipairs(vim.fn.globpath(cwd, pat, false, true)) do
         table.insert(files, f)
      end
   end

   -- De-dup and stat-filter (overlapping patterns + dangling globs).
   local seen, unique = {}, {}
   for _, f in ipairs(files) do
      local stat = uv.fs_stat(f)
      if not seen[f] and stat and stat.type == 'file' then
         seen[f] = true
         table.insert(unique, f)
      end
   end

   if #unique == 0 then
      vim.notify('[conform] no SV files found under ' .. cwd, vim.log.levels.WARN)
      return
   end

   for _, f in ipairs(unique) do
      local bufnr = vim.fn.bufadd(f)
      vim.fn.bufload(bufnr)
      require('conform').format({ bufnr = bufnr })
      vim.api.nvim_buf_call(bufnr, function() vim.cmd('write') end)
   end

   vim.notify(string.format('[conform] formatted %d SV files under %s', #unique, cwd))
end

return M
-- vim: ts=3 sts=3 sw=3 et
