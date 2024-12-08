return {
   -- lazy.nvim
   "folke/noice.nvim",
   event = "VeryLazy",
   dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
   },
   config = function()
      require("noice").setup({
         lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
               ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
               ["vim.lsp.util.stylize_markdown"] = true,
               ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
            },
         },
         -- you can enable a preset for easier configuration
         presets = {
            bottom_search = true,         -- use a classic bottom cmdline for search
            command_palette = true,       -- position the cmdline and popupmenu together
            long_message_to_split = true, -- long messages will be sent to a split
            inc_rename = false,           -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = true,        -- add a border to hover docs and signature help
         },
         messages = {
            enabled = true,
            view = "notify",
            view_error = "notify",
            view_warn = "notify",
            view_history = "messages",
            view_search = "virtualtext",
         },
         routes = {
            {
               --[[ suppress all "written" messages ]]
               filter = {
                  event = "msg_show",
                  any = {
                     { find = "written" },
                  },
               },
               opts = { skip = true },
            },
            {
               --[[ only Push "User: " output to messages ]]
               filter = {
                  event = "msg_show",
                  any = {
                     { find = "User: " },
                  },
               },
               view = "messages",
            },
            {
               --[[ redirect annoying messages to mini ]]
               filter = {
                  event = "msg_show",
                  any = {
                     { find = '%d+L, %d+B' },
                     { find = '; after #%d+' },
                     { find = '; before #%d+' },
                  },
               },
               view = "mini",
            },
         },
      })
      -- Key binding to clear Noice messages
      vim.keymap.set("n", "<leader>nc", function()
         vim.cmd("Noice dismiss")
      end, { noremap = true, silent = true, desc = "Clear Noice Messages" })
      vim.keymap.set("n", "<leader>nm", function()
         vim.cmd("Noice last")
      end, { noremap = true, silent = true, desc = "View Noice Messages" })
   end
}
-- vim: ts=3 sts=3 sw=3 et
