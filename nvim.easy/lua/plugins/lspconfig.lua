return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "bashls" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "folke/neodev.nvim", opts = {} },
		},
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			lspconfig.lua_ls.setup({ capabilities = capabilities })
			lspconfig.bashls.setup({ capabilities = capabilities })
			lspconfig.clangd.setup({ capabilities = capabilities })

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
					map("K", vim.lsp.buf.hover, "Documentation")
					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinitions")
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
				end,
			})
		end,
	},
}
-- vim: ts=3 sts=3 sw=3 et
