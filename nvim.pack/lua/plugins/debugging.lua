-- nvim-dap + nvim-dap-ui + nvim-dap-virtual-text + nvim-nio.
-- LLDB-DAP setup conditional: only wire C/C++ if `lldb-dap` is on PATH.
require('nvim-dap-virtual-text').setup()

local dap, dapui = require('dap'), require('dapui')
dapui.setup()

if vim.fn.exepath('lldb-dap') ~= '' then
   dap.adapters.lldb = {
      type    = 'executable',
      command = 'lldb-dap',
      name    = 'lldb',
   }
   dap.configurations.cpp = {
      {
         name        = 'Launch',
         type        = 'lldb',
         request     = 'launch',
         program     = function()
            return vim.fn.input({
               prompt     = 'Path to executable: ',
               default    = vim.fn.getcwd() .. '/',
               completion = 'file',
            })
         end,
         cwd         = '${workspaceFolder}',
         stopOnEntry = false,
         args        = {},
      },
   }
   dap.configurations.c = dap.configurations.cpp

   -- Auto-open dap-ui when a session starts; close on terminate / exit.
   dap.listeners.before.attach.dapui_config           = function() dapui.open()  end
   dap.listeners.before.launch.dapui_config           = function() dapui.open()  end
   dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
   dap.listeners.before.event_exited.dapui_config     = function() dapui.close() end
end

vim.keymap.set('n', '<leader>cdb', function() require('dap').toggle_breakpoint() end, { desc = '[c]ode [d]ap: toggle breakpoint' })
vim.keymap.set('n', '<leader>cdc', function() require('dap').continue() end,         { desc = '[c]ode [d]ap: continue' })
vim.keymap.set('n', '<leader>cdr', function() require('dap').restart() end,          { desc = '[c]ode [d]ap: restart' })

-- vim: ts=3 sts=3 sw=3 et
