--[[ marks help text
    mx              Set mark x
    <leader>dmx     Delete mark x
    dm<space>       Delete all marks in the current buffer
    dm-             Delete all marks on the current line
--]]
return {
  {
    'chentoast/marks.nvim',
    config = function()
      require("marks").setup({
        mappings = {
          -- changed
          delete = '<leader>dm',
          -- nuked
          next = false,
          prev = false,
          toggle = false,
          set_next = false,
          preview = false,
          prev_bookmark = false,
          next_bookmark = false,
          set_bookmark0 = false,
          set_bookmark1 = false,
          set_bookmark2 = false,
          set_bookmark3 = false,
          set_bookmark4 = false,
          set_bookmark5 = false,
          set_bookmark6 = false,
          set_bookmark7 = false,
          set_bookmark8 = false,
          set_bookmark9 = false,
        }
      })
    end
  },
}
