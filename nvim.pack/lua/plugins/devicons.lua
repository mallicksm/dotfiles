-- nvim-web-devicons -- icon + per-extension color provider used by lualine,
-- neo-tree, telescope, snacks, etc. Set up before any of those.
require('nvim-web-devicons').setup({
   override_by_extension = {
      ['f']    = { icon = '',  color = '#4285f4',                     name = 'f'    },
      ['tdf']  = { icon = "\u{eb65}", color = '#89e051',              name = 'tdf'  },
      ['cmm']  = { icon = '⚒️', color = '#89e051',                    name = 'cmm'  },
      ['qel']  = { icon = '󰛓',  color = '#e37933',                    name = 'qel'  },
      ['bash'] = { icon = "\u{f1183}", color = '#89e051', cterm_color = '113', name = 'bash' },
   },
})

-- vim: ts=3 sts=3 sw=3 et
