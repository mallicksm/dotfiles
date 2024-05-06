--[[ marks help text
    mx              Set mark x
    dmx             Delete mark x
    dm<space>       Delete all marks in the current buffer
--]]
return {
   {
      'chentoast/marks.nvim',
      config = function()
         require('marks').setup({
            mappings = {
               -- nuked
               set_next = false,
               toggle = false,
               delete_line = false,
               delete_buf = false,
               next = false,
               prev = false,
               preview = false,
               set = false,
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
               delete_bookmark0 = false,
               delete_bookmark1 = false,
               delete_bookmark2 = false,
               delete_bookmark3 = false,
               delete_bookmark4 = false,
               delete_bookmark5 = false,
               delete_bookmark6 = false,
               delete_bookmark7 = false,
               delete_bookmark8 = false,
               delete_bookmark9 = false,
               delete_bookmark = false,
               prev_bookmark = false,
               next_bookmark = false,
               next_bookmark0 = false,
               next_bookmark1 = false,
               next_bookmark2 = false,
               next_bookmark3 = false,
               next_bookmark4 = false,
               next_bookmark5 = false,
               next_bookmark6 = false,
               next_bookmark7 = false,
               next_bookmark8 = false,
               next_bookmark9 = false,
               prev_bookmark0 = false,
               prev_bookmark1 = false,
               prev_bookmark2 = false,
               prev_bookmark3 = false,
               prev_bookmark4 = false,
               prev_bookmark5 = false,
               prev_bookmark6 = false,
               prev_bookmark7 = false,
               prev_bookmark8 = false,
               prev_bookmark9 = false,
            },
         })
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
