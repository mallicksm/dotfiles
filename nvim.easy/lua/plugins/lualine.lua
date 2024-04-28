return {
	"nvim-lualine/lualine.nvim",
	config = function()
		require("lualine").setup({
			options = {
				theme = "dracula",
			},
		})
	end,
}
-- vim: ts=3 sts=3 sw=3 et
