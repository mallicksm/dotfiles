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

vim.pack.add({
   ----------------------------------------------------------------------------
   -- Core libraries (no setup() needed; pulled in by other plugins)
   ----------------------------------------------------------------------------
   { src = 'https://github.com/nvim-lua/plenary.nvim'        },
   { src = 'https://github.com/MunifTanjim/nui.nvim'         },
   { src = 'https://github.com/nvim-tree/nvim-web-devicons'  },
   { src = 'https://github.com/kkharji/sqlite.lua'           },
   { src = 'https://github.com/tpope/vim-repeat'             },
   { src = 'https://github.com/nvim-neotest/nvim-nio'        },

   ----------------------------------------------------------------------------
   -- Colorscheme / UI baseline
   ----------------------------------------------------------------------------
   { src = 'https://github.com/ellisonleao/gruvbox.nvim'     },
   { src = 'https://github.com/echasnovski/mini.nvim'        },
   { src = 'https://github.com/nvim-lualine/lualine.nvim'    },
   { src = 'https://github.com/folke/snacks.nvim'            },
   { src = 'https://github.com/folke/which-key.nvim'         },
   { src = 'https://github.com/folke/noice.nvim'             },
   { src = 'https://github.com/rcarriga/nvim-notify'         },
   { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' },

   ----------------------------------------------------------------------------
   -- Markdown rendering (two; pick at runtime via :MdViewer)
   ----------------------------------------------------------------------------
   { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },
   { src = 'https://github.com/OXY2DEV/markview.nvim'        },

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
   { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim',    version = 'v3.x' },
   { src = 'https://github.com/nvim-telescope/telescope.nvim' },
   { src = 'https://github.com/nvim-telescope/telescope-ui-select.nvim' },
   { src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim' },
   { src = 'https://github.com/danielfalk/smart-open.nvim',     version = '0.2.x' },

   ----------------------------------------------------------------------------
   -- LSP / completion / format / lint / debug
   ----------------------------------------------------------------------------
   { src = 'https://github.com/mason-org/mason.nvim'         },
   { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
   { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
   { src = 'https://github.com/neovim/nvim-lspconfig'        },
   { src = 'https://github.com/j-hui/fidget.nvim'            },
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

-- telescope-fzf-native: needs `make` to compile libfzf.so.
local fzf_dir = vim.fn.stdpath('data') .. '/site/pack/core/opt/telescope-fzf-native.nvim'
if vim.uv.fs_stat(fzf_dir) and not vim.uv.fs_stat(fzf_dir .. '/build/libfzf.so') then
   vim.notify('[pack] building telescope-fzf-native (one-time)...', vim.log.levels.INFO)
   vim.fn.system({ 'make', '-C', fzf_dir })
   if vim.v.shell_error ~= 0 then
      vim.notify('[pack] fzf-native build failed; check `make` is on PATH', vim.log.levels.ERROR)
   end
end

-- ----------------------------------------------------------------------------
-- Per-plugin setup. ORDER MATTERS for a few:
--   1. colorscheme  -- so subsequent setups can read theme colors
--   2. mini         -- wires base autocmds + mini.basics
--   3. devicons     -- needed by lualine, neo-tree (set up before them)
--   4. blink.cmp    -- lspconfig pulls capabilities from it (must precede LSP)
--   5. treesitter   -- render-markdown reads parsers (must precede it)
-- The rest are independent; alphabetical by plugin name within their group.
-- ----------------------------------------------------------------------------

require('plugins.colorscheme')
require('plugins.mini')
require('plugins.devicons')

require('plugins.lualine')
require('plugins.snacks')
require('plugins.which-key')
require('plugins.noice')
require('plugins.indentline')

require('plugins.treesitter')
require('plugins.render-markdown')
require('plugins.markview')

require('plugins.gitsigns')
require('plugins.neogit')
require('plugins.diffview')      -- after neogit so our setup() wins

require('plugins.flash')
require('plugins.kaleidosearch')
require('plugins.harpoon')
require('plugins.marks')
require('plugins.undotree')
require('plugins.neo-tree')
require('plugins.telescope')
require('plugins.smart-open')

require('plugins.completions')   -- blink.cmp -- before lspconfig
require('plugins.lspconfig')      -- mason + mason-lspconfig + lspconfig
require('plugins.formatting')
require('plugins.linting')
require('plugins.debugging')

require('plugins.verilog')        -- vim.g.verilog_syntax_fold_lst

-- vim: ts=3 sts=3 sw=3 et
