return {
   'mfussenegger/nvim-dap',
   dependencies = {
      'rcarriga/nvim-dap-ui',
      "theHamsta/nvim-dap-virtual-text",
      'nvim-neotest/nvim-nio',
   },
   config = function()
      require('nvim-dap-virtual-text').setup()
      local dap, dapui = require('dap'), require('dapui')
      dapui.setup()
      if vim.fn.exepath "lldb-dap" ~= "" then
         dap.adapters.lldb = {
            type = 'executable',
            command = 'lldb-dap',
            name = 'lldb'
         }
         dap.configurations.cpp = {
            {

               name = 'Launch',
               type = 'lldb',
               request = 'launch',
               program = function()
                  return vim.fn.input({
                     prompt = 'Path to executable: ',
                     default = vim.fn.getcwd() .. '/',
                     completion = 'file'
                  })
               end,
               cwd = '${workspaceFolder}',
               stopOnEntry = false,
               args = {},
            }
         }
         dap.configurations.c = dap.configurations.cpp
         dap.listeners.before.attach.dapui_config = function()
            dapui.open()
         end
         dap.listeners.before.launch.dapui_config = function()
            dapui.open()
         end
         dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
         end
         dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
         end
      end
   end,
}
-- vim: ts=3 sts=3 sw=3 et
