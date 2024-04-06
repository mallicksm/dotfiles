--[[ marks help text
    mx              Set mark x
    m,              Set the next available alphabetical (lowercase) mark
    m;              Toggle the next available mark at the current line
    dmx             Delete mark x
    dm-             Delete all marks on the current line
    dm<space>       Delete all marks in the current buffer
    m]              Move to next mark
    m[              Move to previous mark
    m:              Preview mark. This will prompt you for a specific mark to preview; press <cr> to preview the next mark.

    Poor man's harpoon (bookmark)
    -----------------------------
    m[0-9]          Add a bookmark from bookmark group[0-9].
    dm[0-9]         Delete all bookmarks from bookmark group[0-9].
    m}              Move to the next bookmark having the same type as the bookmark under the cursor. Works across buffers.
    m{              Move to the previous bookmark having the same type as the bookmark under the cursor. Works across buffers.
    dm=             Delete the bookmark under the cursor.
--]]
return {
  {
    'chentoast/marks.nvim',
    config = function()
      require("marks").setup({
        mappings = {
          next = false,
          prev = false,
          toggle = false,
          set_next = false,
          delete = '<leader>dm',
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
