-- kaleidosearch.nvim with a custom gruvbox-tuned palette that uses BOTH
-- foreground AND background per highlight (highlighter-pen style), instead
-- of upstream's algorithmic HSL fg-only colors.
--
-- Why <leader>s* and not the plugin's <leader>c* defaults: <leader>ca is the
-- LSP code action (see code_plugins/lspconfig.lua) and the entire <leader>c
-- namespace is documented in which-key as "[C]ode action". <leader>s
-- ("[S]earch") was free, so we route there and disable the plugin's
-- keymaps.enabled. Group label is added in plugins/which-key.lua.
--
-- Optional dep: tpope/vim-repeat -> dot-repeat for AddCursorWord, so after
-- <leader>sa on one word you can `.` on the next word and it picks the next
-- color automatically.
--
-- ----------------------------------------------------------------------------
-- Custom palette implementation:
--
-- Upstream's flow per highlighted word is:
--   color      = config.get_next_color(buf_state)        -- returns hex string
--   group_name = "WordColor_" .. sanitize(color)         -- e.g. WordColor_FE8019
--   nvim_set_hl(0, group_name, { fg = color })           -- per-call, fg only
--   nvim_buf_add_highlight(buf, ns, group_name, ...)     -- apply to range
--
-- We intervene at three places:
--   1. `get_next_color` returns "1".."8" so groups become WordColor_1..8.
--   2. We pre-create those eight groups with fg + bg + bold (apply_palette)
--      and re-apply on ColorScheme so theme switches don't wipe them.
--   3. We monkey-patch nvim_set_hl to drop any per-call write to a
--      WordColor_<N> group -- otherwise the plugin's {fg="1"} (which is
--      both nonsense and fg-only) would clobber our richer pre-definition.
-- ----------------------------------------------------------------------------
return {
   'hamidi-dev/kaleidosearch.nvim',
   dependencies = {
      'tpope/vim-repeat',
   },
   keys = {
      -- <leader>ss is the only "prompt for word(s)" key. It uses AddWord (not
      -- the bare :Kaleidosearch which wipes existing highlights and starts a
      -- fresh palette) so repeated invocations build up a multi-color palette
      -- the way you'd expect. To wipe-and-restart, use <leader>sc then <leader>ss.
      { '<leader>ss', '<cmd>KaleidosearchAddWord<cr>',          mode = 'n',          desc = 'Kaleido[s]earch: prompt for word, add to existing highlights' },
      { '<leader>sa', '<cmd>KaleidosearchToggleCursorWord<cr>', mode = { 'n', 'x' }, desc = 'Kaleidosearch: toggle cursor word / visual selection ([a]dd, .-repeatable)' },
      { '<leader>sc', '<cmd>KaleidosearchClear<cr>',            mode = 'n',          desc = 'Kaleidosearch: [c]lear all highlights' },
      { '<leader>sl', '<cmd>KaleidosearchColorLines<cr>',       mode = 'n',          desc = 'Kaleidosearch: color all [l]ines (identical lines share a color)' },
   },
   cmd = {
      'Kaleidosearch',
      'KaleidosearchClear',
      'KaleidosearchAddWord',
      'KaleidosearchToggleCursorWord',
      'KaleidosearchColorLines',
   },
   config = function()
      -- 8-color highlighter-pen palette in the gruvbox bright family.
      -- Dark text on bright bg gives strong contrast against either light or
      -- dark themes. Order is chosen so adjacent words contrast (warm/cool
      -- alternation) rather than two reds in a row.
      local PALETTE = {
         { fg = '#1d2021', bg = '#fb4934', label = 'red'    }, -- gruvbox bright_red
         { fg = '#1d2021', bg = '#fabd2f', label = 'yellow' }, -- gruvbox bright_yellow
         { fg = '#1d2021', bg = '#83a598', label = 'blue'   }, -- gruvbox bright_blue
         { fg = '#1d2021', bg = '#b8bb26', label = 'green'  }, -- gruvbox bright_green
         { fg = '#1d2021', bg = '#fe8019', label = 'orange' }, -- gruvbox bright_orange
         { fg = '#1d2021', bg = '#d3869b', label = 'purple' }, -- gruvbox bright_purple
         { fg = '#1d2021', bg = '#8ec07c', label = 'aqua'   }, -- gruvbox bright_aqua
         { fg = '#1d2021', bg = '#ebdbb2', label = 'cream'  }, -- gruvbox fg1 (light cream)
      }

      -- Define WordColor_1 .. WordColor_N with our combos. Re-applied on
      -- ColorScheme switch so a theme reload doesn't wipe them.
      local function apply_palette()
         for i, c in ipairs(PALETTE) do
            vim.api.nvim_set_hl(0, 'WordColor_' .. i, {
               fg = c.fg, bg = c.bg, bold = true,
            })
         end
      end
      apply_palette()
      vim.api.nvim_create_autocmd('ColorScheme', {
         group    = vim.api.nvim_create_augroup('user-kaleido-palette', { clear = true }),
         callback = apply_palette,
         desc     = 'Kaleidosearch: re-apply custom palette after theme switch',
      })

      -- Intercept the plugin's per-call nvim_set_hl on WordColor_N groups.
      -- See header comment for why; tl;dr the plugin would otherwise overwrite
      -- our fg+bg+bold combo with `{ fg = "1" }` on every highlight call.
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
         keymaps          = { enabled = false }, -- wired via the `keys` table above
         case_sensitive   = false,
         whole_word_match = true,                -- only match \<word\> (like vim's `*`); flip to false if you want substring matches
         get_next_color = function(buf_state)
            -- Cycle through PALETTE indices. start_new_palette() resets
            -- buf_state.current_color_index, so each fresh search starts at
            -- index 1. palette_shift is added so consecutive searches don't
            -- always start on red -- the plugin bumps it by 29 per reset, and
            -- 29 mod 8 = 5, giving a nice pseudo-random spread.
            buf_state.current_color_index = (buf_state.current_color_index or 0) + 1
            local i = (buf_state.current_color_index + (buf_state.palette_shift or 0)) - 1
            return tostring((i % #PALETTE) + 1)
         end,
      })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
