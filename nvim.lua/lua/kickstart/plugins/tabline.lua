return {
  'crispgm/nvim-tabline',
  dependencies = { 'nvim-tree/nvim-web-devicons' }, -- optional
  config = function()
    require("tabline").setup({
      show_icon = true,
      modify_indicator = '[*]',
    })
    vim.cmd.hi 'TablineSel gui=Bold guifg=#a3e512 guibg=NvimDarkGrey4'
    vim.cmd.hi 'Tabline guifg=LightGray guibg=NvimDarkGrey2'
    vim.cmd.hi 'TablineFill guibg=NONE'
    vim.opt.showtabline = 1
  end,
}
