return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		{ "nvim-neotest/nvim-nio" },
	},
	config = function()
		require("dapui").setup()

		require("dap").adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
				args = { "--port", "${port}" },
			},

			name = "lldb",
		}
		require("dap").configurations.c = {
			{
				name = "Launch",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input({
						prompt = "Path to executable: ",
						default = vim.fn.getcwd() .. "/",
						completion = "file",
					})
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = true,
				args = {},
				runInTerminal = false,
			},
		}
		require("dap").listeners.before.attach.dapui_config = function()
			require("dapui").open()
		end
		require("dap").listeners.before.launch.dapui_config = function()
			require("dapui").open()
		end
		require("dap").listeners.before.event_terminated.dapui_config = function()
			require("dapui").close()
		end
		require("dap").listeners.before.event_exited.dapui_config = function()
			require("dapui").close()
		end
		vim.keymap.set("n", "<leader>db", require("dap").toggle_breakpoint, { desc = "DAP: toggle breakpoint" })
		vim.keymap.set("n", "<leader>dc", require("dap").continue, { desc = "DAP: continue" })
	end,
}
-- vim: ts=3 sts=3 sw=3 et
