-- which-key -- popup describing what's bound under a leader / prefix key.
require('which-key').setup({
   icons = { mappings = true, keys = {} },
   spec = {
      { '<leader>d', group = '[D]ap'                 },
      { '<leader>g', group = '[G]it'                 },
      { '<leader>n', group = '[N]oice'               },
      { '<leader>T', group = '[T]oggle'              },
      { '<leader>t', group = '[t]elescope'           }, -- <leader>t{f,g,b,d} -- see plugins/{telescope,smart-open}.lua
      { '<leader>m', group = '[M]ore tools (fmt/lnt)' },
      { '<leader>c', group = '[C]ode action'         },
      { '<leader>s', group = '[S]earch (kaleido)'    },
      { '<leader>r', group = '[R]ename'              },
      { '<leader>w', group = '[W]orkspace symbol'    },
      -- (<leader>o group emptied; oo and ou both moved to <leader>v* family)
      { '<leader>H', group = '[H]arpoon'             }, -- <leader>H{a,n,p,m,l} -- see plugins/harpoon.lua
      { '<leader>v', group = '[V]im introspect'      }, -- <leader>v{r,m,M,j,c,h,b,H} -- see keymaps.lua
      { 's',         group = '[S]urround (mini)'     }, -- upstream defaults; see plugins/mini.lua
      { '<Esc>',     hidden = true },
      { '<leader>h', hidden = true },
      { '<leader>l', hidden = true },
      { '<leader>j', hidden = true },
      { '<leader>k', hidden = true },
      { 'gc',        hidden = true },
      { '<leader>e', hidden = true },
      { '<leader>q', hidden = true },
      { '<leader>x', hidden = true },
      { '<leader>K', hidden = true },
   },
})

-- vim: ts=3 sts=3 sw=3 et
