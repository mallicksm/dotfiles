-- Built-in nvim 0.12+ undotree plugin.
--
-- The actual code ships in $VIMRUNTIME/pack/dist/opt/nvim.undotree/ (opt
-- means "load on demand via :packadd"). Lazy.nvim manages it via the
-- `dir = ...` field pointing at the runtime path -- nothing is fetched
-- from GitHub, but lazy still adds it to runtimepath and lazy-loads it
-- on cmd / key. First press of <leader>Vu pulls in ~400 lines of pure Lua.
--
-- Differences vs the old mbbill/undotree:
--   - Tree-only view (no diff pane below). For a diff, do `:DiffOrig`
--     or open a fugitive `:Gvdiffsplit` against the saved buffer.
--   - Cursor movement in the tree window auto-applies the corresponding
--     undo state via `:undo {seq}` -- no <CR> needed.
--   - Auto-redraws on TextChanged / InsertLeave.
--   - `q` closes the side window (default Nvim behavior on nofile bufs).
--
-- Replaces mbbill/undotree (removed from spec list).
return {
   dir  = vim.env.VIMRUNTIME .. '/pack/dist/opt/nvim.undotree',
   name = 'nvim.undotree',
   cmd  = { 'Undotree' },
   keys = {
      {
         -- Lives under <leader>v* alongside other "introspection" commands.
         '<leader>Vu',
         function()
            require('undotree').open({ command = 'topleft 50vnew' })
         end,
         desc = '[V]im tools: [u]ndotree (built-in nvim 0.12+)',
      },
   },
   init = function()
      -- Persistent undo dir. Independent of the visualizer; needed so
      -- :undo <seq> works across nvim sessions. `undofile = true` is
      -- already set in options.lua.
      local undodir = vim.fn.expand('$HOME') .. '/.undodir'
      if not (vim.uv or vim.loop).fs_stat(undodir) then
         vim.fn.mkdir(undodir, 'p')
      end
      vim.opt.undodir = undodir
   end,
}
-- vim: ts=3 sts=3 sw=3 et
