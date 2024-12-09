--[[ marks help text
    mx              Set mark x
    dmx             Delete mark x
--]]
return {
   {
      'chentoast/marks.nvim',
      config = function()
         -- Predefined mappings
         local mappings = {
            -- Common mappings to disable
            set_next = false,
            toggle = false,
            delete_line = false,
            delete_buf = false,
            next = false,
            prev = false,
            preview = false,
            set = false,
            delete_bookmark = false,
            prev_bookmark = false,
            next_bookmark = false,
         }

         -- Dynamically add set_bookmark0..9
         for i = 0, 9 do
            mappings["set_bookmark" .. i] = false
            mappings["delete_bookmark" .. i] = false
            mappings["next_bookmark" .. i] = false
            mappings["prev_bookmark" .. i] = false
         end

         -- Setup marks with dynamically enhanced mappings
         require('marks').setup({
            mappings = mappings,
         })
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
