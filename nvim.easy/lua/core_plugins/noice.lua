-- Key binding to clear Noice messages
return {
   -- lazy.nvim
   "folke/noice.nvim",
   event = "VeryLazy",
   keys = {
      { '<leader>Vc', '<cmd>Noice dismiss<cr>', noremap = true, silent = true, desc = '[V]im tools: clear/dismiss Noice messages' },
      { '<leader>vM', '<cmd>NoiceAll<cr>',      noremap = true, silent = true, desc = 'View Noice Messages' },
   },
   dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- nvim-notify removed: snacks.notifier (enabled in core_plugins/snacks.lua)
      -- is now the notification backend. snacks gets a higher-priority load
      -- order than noice (priority = 1000, lazy = false) so the notifier is
      -- already running by the time noice starts routing messages to it.
   },
   config = function()
      require("noice").setup({
         lsp = {
            -- override markdown rendering so plugins use Treesitter for hover/docs
            override = {
               ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
               ["vim.lsp.util.stylize_markdown"] = true,
               ["vim.lsp.util.open_floating_preview"] = true,
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
         -- vim.notify() routing:
         --   WARN / ERROR  -> snacks.notifier (big top-right popup, demands attention)
         --   INFO / DEBUG  -> mini view       (small bottom-right toast, fades in 10s)
         -- noice's "notify" view name still maps to whichever notifier is
         -- registered; with snacks.notifier enabled in snacks.lua, that's
         -- snacks instead of nvim-notify.
         notify = {
            enabled = true,
            view = "notify",
         },
         views = {
            -- Tighten the mini view a bit: bottom-right, no border.
            -- (These are the noice defaults for "mini" plus an explicit timeout.)
            mini = {
               timeout = 10000,
               position = { row = -2, col = "100%" }, -- 2 rows above cmdline, right edge
               border = { style = "none" },
               win_options = { winblend = 30 }, -- semi-transparent
            },
            -- Bordered box via snacks.notifier -- the same presentation
            -- nvim's own "Type :qa and press <Enter> to exit Nvim" gets,
            -- since messages.view above routes msg_show to "notify" too.
            -- `view = "notify"` inherits that view's snacks backend and
            -- {message} format; only the title and lifetime differ. No
            -- `level` override on purpose: snacks links a box's
            -- icon/border/title to Diagnostic<Level>, so the INFO level the
            -- keymap notifies at gives the same blue DiagnosticInfo trim as
            -- the Ctrl-C hint (WARN would make it yellow). snacks also keeps
            -- any notification alive while the cursor sits in the cmdline
            -- (its default global `keep` is getcmdpos() > 0), which is why
            -- the Ctrl-C hint appears to linger. replace reuses a single
            -- notification id, so repeated double-clicks update one box
            -- instead of stacking a column of them.
            hint_box = {
               view = "notify",
               title = "Mouse <double-click>",
               timeout = 10000,
               replace = true,
            },
         },
         routes = {
            {
               -- Mouse-selection hint from the <2-LeftMouse> map in
               -- keymaps.lua. First match wins in noice, so this has to
               -- precede the generic INFO -> mini route below, which would
               -- otherwise take it (in white).
               filter = { event = "notify", find = 'shift%+drag' },
               view = "hint_box",
            },
            {
               --[[ redirect annoying messages to mini ]]
               filter = {
                  event = "msg_show",
                  any = {
                     { find = '%d+L, %d+B' },
                     { find = '; after #%d+' },
                     { find = '; before #%d+' },
                     { find = 'yanked' },
                  },
               },
               view = "mini",
            },
            {
               -- vim.notify(..., INFO/DEBUG/TRACE) -> mini (bottom-right toast)
               -- WARN/ERROR fall through to the default `notify` view above.
               filter = {
                  event = "notify",
                  cond = function(message)
                     local lvl = message.level
                     return lvl == "info" or lvl == "debug" or lvl == "trace"
                  end,
               },
               view = "mini",
            },
         },
      })
   end
}
-- vim: ts=3 sts=3 sw=3 et
