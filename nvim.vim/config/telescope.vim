" https://github.com/nvim-telescope/telescope.nvim
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim'
nnoremap <C-p>      :lua require('telescope.builtin').git_files()<CR>

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
" nnoremap <Leader>pf :lua require('telescope.builtin').find_files()<CR>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
" nnoremap <leader>ps :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>
" nnoremap <leader>pw :lua require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }<CR>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
" nnoremap <leader>pb :lua require('telescope.builtin').buffers()<CR>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
" nnoremap <leader>vh :lua require('telescope.builtin').help_tags()<CR>
