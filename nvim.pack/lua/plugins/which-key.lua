-- which-key -- popup describing what's bound under a leader / prefix key.
require('which-key').setup({
   icons = { mappings = true, keys = {} },
   spec = {
      { '<leader>d', group = '[D]ap', icon = { icon = '󰃤', color = 'red' } },
      { '<leader>g', group = '[G]it', icon = { cat = 'filetype', name = 'git', color = 'green' } },
      { '<leader>gb', '<cmd>Gitsigns toggle_current_line_blame<cr>', desc = '[G]it: toggle current line [b]lame', icon = { icon = '󰍡', color = 'grey' } },
      { '<leader>p', group = 'ls[p]', icon = { icon = '󰒋', color = 'blue' } }, -- LSP: pd=type def, ps=workspace symbols, pr=rename, pa=code action, po=outline, pv=virt-text-toggle, pD=all-diag-toggle, pi=inlay-hints-toggle, pf=format, pl=lint
      { '<leader>t', group = '[t]elescope', icon = { icon = '󰍉', color = 'azure' } }, -- <leader>t{f,g,b,d} -- see plugins/{telescope,smart-open}.lua
      { '<leader>s', group = '[S]earch (kaleido)', icon = { icon = '󰫖', color = 'purple' } },
      { '<leader>H', group = '[H]arpoon', icon = { icon = '󰀢', color = 'blue' } }, -- <leader>H{a,n,p,m,l} -- see plugins/harpoon.lua
      { '<leader>v', group = '[V]im', icon = { icon = '󰈈', color = 'azure' } }, -- option toggles + :registers/:marks/:messages/etc -- see keymaps.lua
      { '<leader>V', group = '[V]im tools', icon = { icon = '󰈉', color = 'cyan' } }, -- <leader>Vb = neo-tree buffer panel, <leader>Vu = undotree, <leader>Vm = render-markdown, <leader>Vf = format-on-save toggle
      { '<leader>Vn', group = '[V]n -> [N]oice', icon = { icon = '󰂞', color = 'yellow' } }, -- <leader>Vnc=clear, <leader>Vnt=toggle (vM = view-all-messages, under [V]im group)
      { 's', group = '[S]urround (mini)', icon = { icon = '󰅪', color = 'purple' } }, -- upstream defaults; see plugins/mini.lua
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
