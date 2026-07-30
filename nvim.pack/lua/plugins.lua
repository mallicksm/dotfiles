-- ----------------------------------------------------------------------------
-- vim.pack: declare every plugin in one call, then setup() each one in order.
--
-- vim.pack semantics (Neovim 0.12+):
--   * `vim.pack.add({...})` clones missing repos to
--     `<stdpath('data')>/site/pack/core/opt/<name>` and prepends to runtimepath.
--   * It is SYNCHRONOUS and EAGER -- there is no built-in lazy loading. With
--     modern nvim + an SSD this is fast enough (~50-150ms for 40 plugins).
--   * `version` accepts a tag, branch name, or `vim.version.range('1')` for
--     semver. Defaults to 'main' (or 'master' if main doesn't exist).
--   * No dependency resolution: list every transitive dep yourself.
--   * No `keys = {...}` / `event = {...}` / `cmd = {...}` -- per-plugin
--     keymaps live in `lua/plugins/<name>.lua` next to setup().
--   * No `build = ...` hook -- we run post-install steps explicitly below for
--     fzf-native (`make`) and treesitter (parser install).
-- ----------------------------------------------------------------------------

-- NFS d_type workaround: MUST run before vim.pack.add() so lock_sync() sees
-- real directory types instead of nil and stops "reinstalling" already-cloned
-- plugins on every launch. See lua/pack_nfs_dtype_fix.lua for the full writeup.
require('pack_nfs_dtype_fix')

vim.pack.add({
   ----------------------------------------------------------------------------
   -- Core libraries (no setup() needed; pulled in by other plugins)
   ----------------------------------------------------------------------------
   { src = 'https://github.com/nvim-lua/plenary.nvim'        },
   { src = 'https://github.com/MunifTanjim/nui.nvim'         },
   -- nvim-web-devicons removed: mini.icons replaces it AND calls
   -- mock_nvim_web_devicons() so callers that `require('nvim-web-devicons')`
   -- (neo-tree, lualine, snacks, render-markdown) still resolve transparently.
   { src = 'https://github.com/tpope/vim-repeat'             },
   { src = 'https://github.com/nvim-neotest/nvim-nio'        },

   ----------------------------------------------------------------------------
   -- Colorscheme / UI baseline
   ----------------------------------------------------------------------------
   { src = 'https://github.com/ellisonleao/gruvbox.nvim'     },
   { src = 'https://github.com/echasnovski/mini.nvim'        },
   { src = 'https://github.com/nvim-lualine/lualine.nvim'    },
   { src = 'https://github.com/folke/snacks.nvim'            },
   -- which-key removed: mini.clue (in plugins/mini.lua) handles the same
   -- group-label popups. Evict the on-disk pack with
   --   :lua vim.pack.del{'which-key.nvim'}
   { src = 'https://github.com/folke/noice.nvim'             },
   -- nvim-notify removed: snacks.notifier is the notification backend now.
   -- Evict with :lua vim.pack.del{'nvim-notify'}.

   ----------------------------------------------------------------------------
   -- Markdown rendering
   ----------------------------------------------------------------------------
   { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },
   -- (markview removed; render-markdown is the sole previewer. Toggle via <leader>vP)

   ----------------------------------------------------------------------------
   -- Git stack
   ----------------------------------------------------------------------------
   { src = 'https://github.com/lewis6991/gitsigns.nvim'      },
   { src = 'https://github.com/NeogitOrg/neogit'             },
   { src = 'https://github.com/sindrets/diffview.nvim'       },

   ----------------------------------------------------------------------------
   -- Navigation / movement / search
   ----------------------------------------------------------------------------
   { src = 'https://github.com/folke/flash.nvim'             },
   { src = 'https://github.com/hamidi-dev/kaleidosearch.nvim' },
   { src = 'https://github.com/ThePrimeagen/harpoon',           version = 'harpoon2' },
   { src = 'https://github.com/chentoast/marks.nvim'         },
   -- (mbbill/undotree removed -- replaced by nvim 0.12 built-in
   -- $VIMRUNTIME/pack/dist/opt/nvim.undotree, wired up in plugins/undotree.lua)
   -- neo-tree removed: snacks.explorer (<leader>ee in plugins/snacks.lua) is
   -- the file browser now. Evict the on-disk pack with
   --   :lua vim.pack.del{'neo-tree.nvim'}
   -- telescope + ui-select + fzf-native + live-grep-args removed: snacks.picker
   -- + snacks.input (in plugins/snacks.lua) cover the same use cases. Evict with
   --   :lua vim.pack.del{'telescope.nvim','telescope-ui-select.nvim',
   --                     'telescope-fzf-native.nvim','telescope-live-grep-args.nvim'}

   ----------------------------------------------------------------------------
   -- LSP / completion / format / lint / debug
   ----------------------------------------------------------------------------
   { src = 'https://github.com/mason-org/mason.nvim'         },
   { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
   { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
   { src = 'https://github.com/neovim/nvim-lspconfig'        },
   -- fidget removed: noice.nvim renders LSP progress via lsp.progress (on by
   -- default). Run :lua vim.pack.del{'fidget.nvim'} to evict the cached pack.
   { src = 'https://github.com/folke/lazydev.nvim'           },
   { src = 'https://github.com/saghen/blink.cmp',               version = vim.version.range('1') },
   { src = 'https://github.com/stevearc/conform.nvim'        },
   { src = 'https://github.com/mfussenegger/nvim-lint'       },
   { src = 'https://github.com/mfussenegger/nvim-dap'        },
   { src = 'https://github.com/rcarriga/nvim-dap-ui'         },
   { src = 'https://github.com/theHamsta/nvim-dap-virtual-text' },

   ----------------------------------------------------------------------------
   -- Treesitter + Verilog/SystemVerilog syntax
   ----------------------------------------------------------------------------
   { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
   { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects' },
   { src = 'https://github.com/vhda/verilog_systemverilog.vim' },
}, {
   -- confirm = false silences the "These plugins will be installed:" popup
   -- that fires on every launch when vim.pack's in-session registry thinks
   -- some plugins need installation (often a leftover from an interrupted
   -- first-launch). The actual clone/verify still happens; just no prompt.
   -- To explicitly update everything: :lua vim.pack.update()
   confirm = false,
})

-- ----------------------------------------------------------------------------
-- Post-install build steps (lazy.nvim's `build = '...'` equivalent).
-- These are idempotent: they only run if the artifact is missing.
-- ----------------------------------------------------------------------------
-- (telescope-fzf-native build step removed along with the telescope stack.)

-- ----------------------------------------------------------------------------
-- Per-plugin setup, split into TWO phases.
--
-- WHY: vim.pack has no lazy-loading, so require()ing every plugin's setup() in
-- init.lua ran the whole ~340ms toolchain BEFORE VimEnter fired -- and the
-- dashboard only opens on VimEnter. Result: nvim's built-in intro sat on screen
-- for ~1s, then the dashboard painted over it (the "default starter -> my
-- starter" flash). lazy.nvim avoids this by giving snacks priority=1000; vim.pack
-- has no such knob, so we defer the heavy setups ourselves.
--
-- The vim.pack.add({...}) above is UNCHANGED -- every plugin is still added to
-- runtimepath at startup (add is only ~24ms and keeps :packadd-free access +
-- an accurate dashboard plugin count). We only defer the expensive setup()
-- CALLS (lspconfig/mason ~68ms, debugging ~27, completions ~18, treesitter,
-- render-markdown, formatting, linting) to just after the first UI paint.
--
-- PHASE 1 setup -- runs now. ORDER MATTERS:
--   1. colorscheme -- so subsequent setups can read theme colors
--   2. mini        -- mini.icons.mock_nvim_web_devicons() must run BEFORE any
--                     plugin that require('nvim-web-devicons') (lualine, snacks)
-- The rest are independent; grouped by role.
-- ----------------------------------------------------------------------------
require('plugins.colorscheme')
require('plugins.mini')          -- includes mini.icons + mock_nvim_web_devicons

require('plugins.lualine')
require('plugins.snacks')        -- dashboard: paints as soon as VimEnter fires
-- plugins.which-key removed; mini.clue (in plugins/mini.lua) takes over.
require('plugins.noice')

require('plugins.gitsigns')
require('plugins.neogit')
require('plugins.diffview')      -- after neogit so our setup() wins

require('plugins.flash')
require('plugins.kaleidosearch')
require('plugins.harpoon')
require('plugins.marks')
require('plugins.undotree')
-- plugins.neo-tree removed; snacks.explorer (<leader>ee) is the file browser now.
-- plugins.telescope removed;  snacks.picker keymaps live in plugins/snacks.lua

require('plugins.verilog')       -- vim.g.verilog_syntax_fold_lst (vimscript syntax)

-- ----------------------------------------------------------------------------
-- PHASE 2 setup -- deferred toolchain (LSP / completion / format / lint / dap /
-- treesitter / render-markdown). Loaded after the first paint. Intra-group
-- order still matters:
--   * treesitter BEFORE render-markdown (parsers)
--   * blink.cmp (completions) BEFORE lspconfig (capabilities)
-- ----------------------------------------------------------------------------
local function load_deferred()
   if vim.g._pack_deferred_loaded then return end
   vim.g._pack_deferred_loaded = true

   require('plugins.treesitter')
   require('plugins.render-markdown')
   require('plugins.completions')   -- blink.cmp -- before lspconfig
   require('plugins.lspconfig')     -- mason + mason-lspconfig + lspconfig
   require('plugins.formatting')
   require('plugins.linting')
   require('plugins.debugging')

   -- Attach the freshly-loaded LSP + treesitter to any REAL file that was
   -- already opened before deferral ran (the `vi file` path). Their FileType
   -- handlers were only just registered -- after this buffer's original
   -- FileType fired -- so re-fire it per loaded buffer to trigger
   -- vim.treesitter.start() and the LSP FileType launch.
   for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf)
         and vim.bo[buf].buftype == ''
         and vim.bo[buf].filetype ~= '' then
         vim.api.nvim_exec_autocmds('FileType', { buffer = buf, modeline = false })
      end
   end
end

-- Trigger on VimEnter (startup done -> dashboard/first buffer about to paint),
-- deferred one event-loop tick via vim.schedule so the paint happens FIRST.
-- once=true + the vim.g guard make this idempotent.
vim.api.nvim_create_autocmd('VimEnter', {
   once     = true,
   callback = function() vim.schedule(load_deferred) end,
})

-- vim: ts=3 sts=3 sw=3 et
