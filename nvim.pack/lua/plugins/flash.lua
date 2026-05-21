-- flash.nvim -- minimalist setup.
--
-- Everything except `f` is on vim defaults. `f` becomes flash.jump:
-- bidirectional, multi-char, labeled. That's the one feature we keep.
--
-- Released back to vim defaults: s, S, F, t, T, ;, ,, r, R, /, ?, <C-s>.
-- (modes.search.enabled is `false` by default, so `/` and `?` were never
-- flash-enhanced anyway; modes.char enhancement of f/F/t/T is what we
-- explicitly disable below.)
--
-- Trade-offs of replacing vim's default `f`:
--   * lose `<count>fX` -- flash labels every match, so picking the Nth
--     match is now "look at label, press label" instead of counting.
--   * lose `;`/`,` repeat for `f` -- they still work for `t`/`T` (vim
--     native again) and for `F` (vim native again).
--   * gain bidirectional + multi-char + labeled jumps in one keystroke.
require('flash').setup({
   modes = {
      char = { enabled = false }, -- release f/F/t/T/;/, to vim defaults
   },
})

-- Visual-mode `f` deliberately excluded so vim's "extend selection to next
-- char" still works there. operator-pending IS included so `df<chars><label>`
-- deletes from cursor to the labeled spot.
vim.keymap.set({ 'n', 'o' }, 'f', function() require('flash').jump() end,
   { desc = 'Flash: jump (bidirectional multi-char, replaces vim f)' })


-- Make label letters visually distinct from matched chars. By default
-- FlashMatch -> Search (yellow in gruvbox) and FlashLabel -> Substitute
-- (also yellow-ish), which made matched-text and the label letter look the
-- same color. Re-applying on ColorScheme so theme switches don't wipe these.
local function apply_flash_hl()
   -- Matched char: keep on default Search highlight (yellow bg).
   -- Label letter: dark text on bright RED bg, bold. Pops hard.
   vim.api.nvim_set_hl(0, 'FlashLabel',   { fg = '#1d2021', bg = '#fb4934', bold = true }) -- gruvbox bg0 on bright_red
   vim.api.nvim_set_hl(0, 'FlashCurrent', { fg = '#1d2021', bg = '#fe8019', bold = true }) -- gruvbox bg0 on bright_orange (the "currently picked" match)
end
apply_flash_hl()
vim.api.nvim_create_autocmd('ColorScheme', {
   group    = vim.api.nvim_create_augroup('user-flash-hl', { clear = true }),
   callback = apply_flash_hl,
   desc     = 'Flash: re-apply label/current highlights after theme switch',
})

-- vim: ts=3 sts=3 sw=3 et
