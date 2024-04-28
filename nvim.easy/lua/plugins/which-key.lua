return {
	"folke/which-key.nvim",
	event = "VimEnter",
	config = function()
		require("which-key").setup()
	end,
}
-- vim: ts=3 sts=3 sw=3 et
