return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
		"3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	config = function()
		vim.keymap.set(
			"n",
			"<leader>e",
			":Neotree reveal_force_cwd toggle<cr>",
			{ desc = "Neo-tree: File browser toggle" }
		)
	end,
}
-- vim: ts=3 sts=3 sw=3 et
