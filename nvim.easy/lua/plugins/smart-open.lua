-- danielfalk/smart-open.nvim: telescope picker that ranks files by frecency
-- (frequency * recency) AND boosts files in the current working directory.
-- The frecency DB lives at ~/.local/share/nvim/smart_open.sqlite3 and is
-- updated automatically on BufWinEnter; survives restarts/reboots.
--
-- Bound to <leader>F (capital F = "Frecency"), pairing with the existing
-- telescope picker family:
--   <leader>E  -> find_files (alphabetical)         (lua/plugins/telescope.lua)
--   <leader>R  -> oldfiles   (chronological)        (lua/plugins/telescope.lua)
--   <leader>F  -> smart_open (frecency, project-aware)   <-- this file
--   <leader>G  -> live_grep                          (lua/plugins/telescope.lua)
--   <leader>B  -> buffers                            (lua/plugins/telescope.lua)
--
-- Requires libsqlite3 on the system. Verified present on RHEL 8 at
-- /usr/lib64/libsqlite3.so.0 (sqlite.lua FFIs to it; no compile step).

return {
   'danielfalk/smart-open.nvim',
   branch = '0.2.x',
   dependencies = {
      'kkharji/sqlite.lua',
      'nvim-telescope/telescope.nvim',
      -- fzf-native isn't strictly required here (telescope.nvim already pulls it)
      -- but smart-open's matcher integrates with it, so list it for clarity.
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
   },
   keys = {
      {
         '<leader>F',
         function()
            require('telescope').extensions.smart_open.smart_open({
               cwd_only = false,           -- show files outside cwd, but boost in-cwd matches
               filename_first = true,      -- "name  /path/to/" instead of "/path/to/name" (faster fuzzy)
               prompt_title = 'smart_open (<esc> to quit)',
            })
         end,
         desc = 'Telescope: smart_open ([F]recency + project)',
      },
   },
   config = function()
      -- load_extension is the canonical way to plug a telescope extension's
      -- pickers into the :Telescope namespace and into telescope.extensions.*
      require('telescope').load_extension('smart_open')
   end,
}
-- vim: ts=3 sts=3 sw=3 et
