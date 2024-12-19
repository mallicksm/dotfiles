return {
   "folke/snacks.nvim",
   priority = 1000,
   lazy = false,
   opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      dashboard = { enabled = false },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
   },
   keys = {
      { "<leader>.",  function() require('snacks').scratch() end,                 desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() require('snacks').scratch.select() end,          desc = "Select Scratch Buffer" },
      { "<leader>n",  function() require('snacks').notifier.show_history() end,   desc = "Notification History" },
      { "<leader>bd", function() require('snacks').bufdelete() end,               desc = "Delete Buffer" },
      { "<leader>cR", function() require('snacks').rename.rename_file() end,      desc = "Rename File" },
      { "<leader>gB", function() require('snacks').gitbrowse() end,               desc = "Git Browse",                  mode = { "n", "v" } },
      { "<leader>gb", function() require('snacks').git.blame_line() end,          desc = "Git Blame Line" },
      { "<leader>gf", function() require('snacks').lazygit.log_file() end,        desc = "Lazygit Current File History" },
      { "<leader>gg", function() require('snacks').lazygit() end,                 desc = "Lazygit" },
      { "<leader>gl", function() require('snacks').lazygit.log() end,             desc = "Lazygit Log (cwd)" },
      { "<leader>Un", function() require('snacks').notifier.hide() end,           desc = "Dismiss All Notifications" },
      { "<c-/>",      function() require('snacks').terminal() end,                desc = "Toggle Terminal" },
      { "<c-_>",      function() require('snacks').terminal() end,                desc = "which_key_ignore" },
      { "]]",         function() require('snacks').words.jump(vim.v.count1) end,  desc = "Next Reference",              mode = { "n", "t" } },
      { "[[",         function() require('snacks').words.jump(-vim.v.count1) end, desc = "Prev Reference",              mode = { "n", "t" } },
   },
   init = function()
      vim.api.nvim_create_autocmd("User", {
         pattern = "VeryLazy",
         callback = function()
            -- Setup some globals for debugging (lazy-loaded)
            _G.dd = function(...)
               require('snacks').debug.inspect(...)
            end
            _G.bt = function()
               require('snacks').debug.backtrace()
            end
            vim.print = _G.dd -- Override print to use snacks for `:=` command

            -- Create some toggle mappings
            require('snacks').toggle.option("conceallevel",
               { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>Uc")
            require('snacks').toggle.treesitter():map("<leader>UT")
            require('snacks').toggle.inlay_hints():map("<leader>Uh")
            require('snacks').toggle.indent():map("<leader>Ug")
            require('snacks').toggle.dim():map("<leader>UD")
         end,
      })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
