-- ----------------------------------------------------------------------------
-- pack_nfs_dtype_fix -- make vim.pack stop "reinstalling" plugins every launch
-- on NFS-backed plugin stores.
--
-- SYMPTOM
--   `nvim -p` (nvim.pack) prints "vim.pack: Installing plugins (N/M)" on EVERY
--   startup for the same subset of plugins and can hang there over slow
--   SSH/NFS -- even though the plugins are already cloned and valid.
--
-- ROOT CAUSE
--   ~/.local/share/nvim.pack/site/pack/core/opt lives on NFS. An NFS server's
--   READDIR reply carries no d_type unless the client did a READDIRPLUS, so the
--   kernel hands back DT_UNKNOWN for entries not warm in the dcache. libuv's
--   uv.fs_scandir_next() surfaces DT_UNKNOWN as a *nil* type, and so does
--   vim.fs.dir(). vim.pack's lock_sync() then does, per entry:
--       installed[name] = fs_type            -- nil for those dirs
--       ... if not installed[name] then to_install[] ...   -- => reinstall!
--   i.e. a nil type is read as "not a directory" => "plugin missing" => clone.
--   (Python's os.scandir avoids this because DirEntry.is_dir() falls back to a
--   stat() when d_type is unknown; libuv/vim.fs.dir does not.)
--
-- FIX
--   Wrap vim.fs.dir so that whenever the iterator yields a nil type we backfill
--   it with a single uv.fs_stat() -- the same stat() fallback Python does. Costs
--   one extra stat per DT_UNKNOWN entry at startup (0 on local ext4, ~13 on this
--   NFS home) which is trivial next to re-cloning repos over the network.
--
--   MUST load before vim.pack.add() (see lua/plugins.lua) so lock_sync() sees
--   correct types. Idempotent via the vim.g guard.
--
-- SCOPE
--   Global override of vim.fs.dir, but strictly correctness-improving: it only
--   ever replaces a nil type with the real one; known types pass through
--   untouched. Safe to keep even once the plugin store moves to local disk.
-- ----------------------------------------------------------------------------

if vim.g._pack_nfs_dtype_shim then
   return
end
vim.g._pack_nfs_dtype_shim = true

local uv = vim.uv or vim.loop
local orig_dir = vim.fs.dir

vim.fs.dir = function(path, opts)
   local it = orig_dir(path, opts)
   return function()
      local name, ty = it()
      -- name is relative to `path` for both depth==1 (basename) and depth>1
      -- (path fragment), so joinpath(path, name) resolves either way.
      if name ~= nil and ty == nil then
         local st = uv.fs_stat(vim.fs.joinpath(path, name))
         ty = st and st.type or nil
      end
      return name, ty
   end
end

-- vim: ts=3 sts=3 sw=3 et
