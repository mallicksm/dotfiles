-- marks.nvim -- visualizes vim marks in the gutter. We disable all of its
-- bookmark/management mappings and let plain vim mx / dmx / 'x do the work.
local mappings = {
   set_next        = false,
   toggle          = false,
   delete_line     = false,
   delete_buf      = false,
   next            = false,
   prev            = false,
   preview         = false,
   set             = false,
   delete_bookmark = false,
   prev_bookmark   = false,
   next_bookmark   = false,
}
for i = 0, 9 do
   mappings['set_bookmark'    .. i] = false
   mappings['delete_bookmark' .. i] = false
   mappings['next_bookmark'   .. i] = false
   mappings['prev_bookmark'   .. i] = false
end

require('marks').setup({ mappings = mappings })

-- vim: ts=3 sts=3 sw=3 et
