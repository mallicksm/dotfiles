-- noice.nvim -- replaces nvim's cmdline / messages / popupmenu UIs.
-- Depends on MunifTanjim/nui.nvim (added in plugins.lua). nvim-notify is gone:
-- snacks.notifier (enabled in plugins/snacks.lua) is now the notification
-- backend, and snacks is required BEFORE noice in plugins.lua so it's already
-- registered as the "notify" view sink by the time noice starts routing.

require('noice').setup({
   lsp = {
      override = {
         ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
         ['vim.lsp.util.stylize_markdown']                = true,
         ['vim.lsp.util.open_floating_preview']           = true,
      },
   },
   presets = {
      bottom_search         = true,
      command_palette       = true,
      long_message_to_split = true,
      inc_rename            = false,
      lsp_doc_border        = true,
   },
   messages = {
      enabled      = true,
      view         = 'notify',
      view_error   = 'notify',
      view_warn    = 'notify',
      view_history = 'messages',
      view_search  = 'virtualtext',
   },
   -- vim.notify() routing:
   --   WARN / ERROR  -> snacks.notifier (big top-right popup, demands attention)
   --   INFO / DEBUG  -> mini view       (small bottom-right toast, fades in ~2s)
   -- noice's "notify" view name maps to whichever notifier is registered; with
   -- snacks.notifier enabled in snacks.lua, that's snacks (not nvim-notify).
   notify = {
      enabled = true,
      view    = 'notify',
   },
   views = {
      -- Bottom-right, short timeout, borderless, slightly transparent toast.
      mini = {
         timeout     = 2000,
         position    = { row = -2, col = '100%' }, -- 2 rows above cmdline, right edge
         border      = { style = 'none' },
         win_options = { winblend = 30 },
      },
   },
   routes = {
      -- Redirect noisy info messages to the small mini view
      {
         filter = { event = 'msg_show', any = {
            { find = '%d+L, %d+B' },
            { find = '; after #%d+' },
            { find = '; before #%d+' },
            { find = 'yanked' },
         } },
         view = 'mini',
      },
      -- vim.notify(..., INFO/DEBUG/TRACE) -> mini. WARN/ERROR fall through.
      {
         filter = {
            event = 'notify',
            cond  = function(message)
               local lvl = message.level
               return lvl == 'info' or lvl == 'debug' or lvl == 'trace'
            end,
         },
         view = 'mini',
      },
   },
})

vim.keymap.set('n', '<leader>Vc', '<cmd>Noice dismiss<cr>', { noremap = true, silent = true, desc = '[V]im tools: clear/dismiss Noice messages' })
vim.keymap.set('n', '<leader>vM', '<cmd>NoiceAll<cr>',      { noremap = true, silent = true, desc = 'View Noice Messages' })

-- vim: ts=3 sts=3 sw=3 et
