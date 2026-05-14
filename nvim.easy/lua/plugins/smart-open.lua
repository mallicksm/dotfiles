-- danielfalk/smart-open.nvim: telescope picker that ranks files by frecency
-- (frequency * recency). Frecency DB lives at ~/.local/share/nvim/smart_open.sqlite3
-- and is updated automatically on BufWinEnter; survives restarts/reboots.
--
-- Bound to <leader>tf -- the canonical "find files" key, since smart_open is
-- a strict superset of telescope's find_files. The [t]elescope family:
--   <leader>tf  -> smart_open  (PURE frecency, no cwd preference)   <-- this file
--   <leader>tg  -> live_grep
--   <leader>tb  -> buffers
-- (telescope's bare find_files dropped; smart_open covers it. <leader>R /
--  oldfiles also dropped earlier.)
--
-- We override smart-open's default weights to KILL the cwd-preference behavior:
--   * project   = 0  (was 10) -- no flat boost for files under cwd
--   * proximity = 0  (was 13) -- no boost for files near current buffer's path
--   * frecency  = 30 (was 17) -- bumped to absorb the deleted weight, so
--                                pure history dominates the empty-prompt ranking
-- Effect: ranking is "what did I touch most recently/often, anywhere", not
-- "what's nearby". Files in the current cwd still appear (the file scanner
-- still walks cwd) but they don't get an artificial leg up.
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
         '<leader>tf',
         function()
            require('telescope').extensions.smart_open.smart_open({
               cwd_only       = false,                  -- show files outside cwd
               filename_first = true,                   -- "name  /path/to/" rendering
               prompt_title   = 'smart_open (frecency, no cwd boost)',
               -- Per-call weight override -- defeats cwd preference. Other
               -- weights (open=3, alt=4, recency=9, fzy=140/131) keep their
               -- defaults; we only zero what biases towards "near here".
               weights = {
                  project          = 0,
                  proximity        = 0,
                  frecency         = 30,
                  recency          = 9,
                  open             = 3,
                  alt              = 4,
                  path_fzy         = 140,
                  virtual_name_fzy = 131,
                  path_fzf         = 140,
                  virtual_name_fzf = 131,
               },
            })
         end,
         desc = 'Telescope: smart_open ([f]recency-ranked file picker, no cwd preference)',
      },
   },
   config = function()
      -- load_extension is the canonical way to plug a telescope extension's
      -- pickers into the :Telescope namespace and into telescope.extensions.*
      require('telescope').load_extension('smart_open')
   end,
}
-- vim: ts=3 sts=3 sw=3 et
