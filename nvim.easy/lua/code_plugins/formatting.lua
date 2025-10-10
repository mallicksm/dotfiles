return {
   { -- Autoformat
      'stevearc/conform.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      config = function()
         require('conform').setup({
            formatters = {
               clang_format = {
                  command = 'clang-format',
                  args = { '--style=file:' .. vim.fn.expand('$HOME') .. '/dotfiles/formatters/clang-format' },
               },
               verible_verilog_format = {
                  command = 'verible-verilog-format',
                  args = {
                     '--port_declarations_indentation=indent',
                     '--port_declarations_alignment=align',
                     '--indentation_spaces=3',
                     '--named_port_indentation=indent',
                     '--named_port_alignment=align',
                     '$FILENAME'
                  },
               },
               black = {
                  command = 'black',
                  args = {
                     '--config',
                     vim.fn.expand('$HOME') .. '/dotfiles/formatters/py-format.toml',
                     '--quiet',
                     '-',
                  },
                  stdin = true,
               },
               csrfmt = {
                  command = "fmtcsr.py",
                  stdin = true,
               },
            },
            formatters_by_ft = {
               lua = { 'stylua' },                                   -- brew install stylua
               json = { 'prettier' },                                -- npm install prettier
               python = { 'black' },                                 -- pip install black
               c = { 'clang_format' },                               -- gcc13 + clang11
               cpp = { 'clang_format' },                             -- gcc13 + clang11
               verilog_systemverilog = { 'verible_verilog_format' }, -- https://github.com/chipsalliance/verible/releases
               semifore = { 'csrfmt'},
            },
            notify_on_error = false,
         })
         -- Recursive formatter: formats all *.sv, *.svh, *.v under cwd
         local function format_all_sv_in_cwd()
            local uv    = vim.loop
            local cwd   = uv.cwd()
            local pats  = { "**/*.sv", "**/*.svh", "**/*.v" }

            -- collect files recursively
            local files = {}
            for _, pat in ipairs(pats) do
               -- globpath(dir, pattern, nosuf, list) ? list
               for _, f in ipairs(vim.fn.globpath(cwd, pat, false, true)) do
                  table.insert(files, f)
               end
            end

            -- de-dup (in case patterns overlap)
            local seen = {}
            local unique = {}
            for _, f in ipairs(files) do
               if not seen[f] and vim.loop.fs_stat(f) and vim.loop.fs_stat(f).type == "file" then
                  seen[f] = true
                  table.insert(unique, f)
               end
            end

            if #unique == 0 then
               vim.notify("[conform] no SV files found under " .. cwd, vim.log.levels.WARN)
               return
            end

            -- format each file via Conform (respects your verible args)
            for _, f in ipairs(unique) do
               local bufnr = vim.fn.bufadd(f)
               vim.fn.bufload(bufnr)
               require("conform").format({ bufnr = bufnr })
               vim.api.nvim_buf_call(bufnr, function()
                  vim.cmd("write")
               end)
            end

            vim.notify(string.format("[conform] formatted %d SV files under %s", #unique, cwd))
         end

         -- :FormatAllSV command
         vim.api.nvim_create_user_command("FormatAllSV", format_all_sv_in_cwd, {})
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
