-- kaleidosearch.nvim with a custom gruvbox-tuned palette using BOTH fg AND
-- bg per highlight (highlighter-pen style), instead of upstream's algorithmic
-- HSL fg-only colors. See nvim.easy/lua/plugins/kaleidosearch.lua for the
-- full breadcrumb on the monkey-patch -- short version: the plugin's
-- nvim_set_hl per-call would clobber our richer fg+bg+bold combo, so we
-- intercept those calls and drop them, letting our pre-defined groups stand.

local PALETTE = {
   { fg = '#1d2021', bg = '#fb4934', label = 'red'    },
   { fg = '#1d2021', bg = '#fabd2f', label = 'yellow' },
   { fg = '#1d2021', bg = '#83a598', label = 'blue'   },
   { fg = '#1d2021', bg = '#b8bb26', label = 'green'  },
   { fg = '#1d2021', bg = '#fe8019', label = 'orange' },
   { fg = '#1d2021', bg = '#d3869b', label = 'purple' },
   { fg = '#1d2021', bg = '#8ec07c', label = 'aqua'   },
   { fg = '#1d2021', bg = '#ebdbb2', label = 'cream'  },
}

local function apply_palette()
   for i, c in ipairs(PALETTE) do
      vim.api.nvim_set_hl(0, 'WordColor_' .. i, { fg = c.fg, bg = c.bg, bold = true })
   end
end
apply_palette()
vim.api.nvim_create_autocmd('ColorScheme', {
   group    = vim.api.nvim_create_augroup('user-kaleido-palette', { clear = true }),
   callback = apply_palette,
   desc     = 'Kaleidosearch: re-apply custom palette after theme switch',
})

-- Intercept the plugin's per-call nvim_set_hl on WordColor_<N> groups.
-- Without this, `{ fg = "1" }` (the index returned by our get_next_color)
-- would be set as the highlight, both clobbering our fg+bg combo AND
-- being an invalid color spec.
do
   local orig_set_hl = vim.api.nvim_set_hl
   vim.api.nvim_set_hl = function(ns, name, val)
      if type(name) == 'string' and name:match('^WordColor_%d+$') then
         return -- canonical definition is whatever apply_palette set
      end
      return orig_set_hl(ns, name, val)
   end
end

require('kaleidosearch').setup({
   keymaps          = { enabled = false }, -- we wire <leader>s* below
   case_sensitive   = false,
   whole_word_match = true,                -- only match \<word\> (like vim's `*`)
   get_next_color = function(buf_state)
      buf_state.current_color_index = (buf_state.current_color_index or 0) + 1
      local i = (buf_state.current_color_index + (buf_state.palette_shift or 0)) - 1
      return tostring((i % #PALETTE) + 1)
   end,
})

vim.keymap.set('n',          '<leader>ss', '<cmd>KaleidosearchAddWord<cr>',          { desc = 'Kaleido[s]earch: prompt for word, add to existing highlights' })
vim.keymap.set({ 'n', 'x' }, '<leader>sa', '<cmd>KaleidosearchToggleCursorWord<cr>', { desc = 'Kaleidosearch: toggle cursor word / visual selection ([a]dd, .-repeatable)' })
vim.keymap.set('n',          '<leader>sc', '<cmd>KaleidosearchClear<cr>',            { desc = 'Kaleidosearch: [c]lear all highlights' })
vim.keymap.set('n',          '<leader>sl', '<cmd>KaleidosearchColorLines<cr>',       { desc = 'Kaleidosearch: color all [l]ines (identical lines share a color)' })

-- vim: ts=3 sts=3 sw=3 et
