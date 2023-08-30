" https://github.com/liuchengxu/vim-which-key
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] } " On-demand lazy load

nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>

" Define prefix dictionary
let g:which_key_hspace = 20
let g:which_key_map = {
         \ 'name': '+root-menu',
         \ 'R' : 'FullRefresh',
         \ 'd' : [':SignifyDiff', 'Git Diff'],
         \ 'K' : 'Man under cursor',
         \ 'C' : 'cd to %',
         \ '<Down>' : 'Autopairs -Disable/Enable',
         \ '<Right>' : 'Autopairs -Jump to next closed pair',
         \ 'G' : [':FloatermNew --width=0.60 --height=0.8 --title=gdb gdb -tui' , 'App: GDB'],
         \ 'P' : [':FloatermNew --title=python python'                          , 'App: Python'],
         \ 'q' : 'which_key_ignore',
         \ 'e' : 'which_key_ignore',
         \ 'h' : 'which_key_ignore',
         \ 'j' : 'which_key_ignore',
         \ 'k' : 'which_key_ignore',
         \ 'l' : 'which_key_ignore',
         \ 'o' : 'which_key_ignore',
         \ }
let g:which_key_map['v'] = {
         \ 'name' : '+vim',
         \ '=' : 'vim Format',
         \ 'i' : 'toggle indentLine',
         \ 'l' : 'toggle listchars',
         \ 'w' : 'wrap lines',
         \ 'u' : [':UndotreeToggle'    , 'Toggle UndoTree'],
         \ 'n' : [':call NukeRegs()'   , 'Nuke Registers'],
         \ }
let g:which_key_map['f'] = {
         \ 'name' : '+file-browser',
         \ 'r' : [':Rg!'                , 'fzf: Rg:       -> ripgrep'],
         \ 'f' : [':Files!'             , 'fzf: Files:    -> All files'],
         \ 'e' : [':GFiles!'            , 'fzf: GFiles:   -> files'],
         \ 'm' : [':GFiles!?'           , 'fzf: GFiles:   -> modified files'],
         \ 'b' : [':Buffers!'           , 'fzf: Buffers:  -> open buffers'],
         \ 't' : ['<C-w>gf'             , 'Win:   -> gf Tab'],
         \ 's' : ['<C-w>f'              , 'Win:   -> gf Split'],
         \ 'v' : [':vertical wincmd f'  , 'Win:   -> gf Vsplit'],
         \ 'x' : {
            \ 'name' : '+extra',
            \ 'w' : [':Windows'     , 'fzf: Windows:   -> open windows'],
            \ ';' : [':Commands'    , 'fzf: Commands:  -> commands'],
            \ '/' : [':History/'    , 'fzf: History:   -> history-search'],
            \ 'h' : [':History'     , 'fzf: History:   -> history-file'],
            \ 'H' : [':History:'    , 'fzf: History:   -> history-command'],
            \ 'l' : [':Lines'       , 'fzf: Lines:     -> lines-all'] ,
            \ 'L' : [':BLines'      , 'fzf: BLines:    -> lines-current-buffer'],
            \ 'T' : [':Tags'        , 'fzf: Tags:      -> project tags'],
            \ 't' : [':Helptags'    , 'fzf: Helptags:  -> help tags'] ,
            \ 'c' : [':Colors'      , 'fzf: Colors:    -> color schemes'],
            \ 'F' : [':Filetypes'   , 'fzf: Filetypes: -> file types'],
            \ 'm' : [':Maps'        , 'fzf: Maps:      -> normal maps'] ,
            \ },
         \ }
let g:which_key_map['g'] = {
         \ 'name' : '+git' ,
         \ 'c' : [':Commits!'                    , 'fzf: Commits:  -> All commits'],
         \ 'C' : [':BCommits!'                   , 'fzf: BCommits: -> Buffer commits'],
         \ 'j' : ['<Plug>(signify-next-hunk)'    , 'Sign:  -> next hunk'],
         \ 'k' : ['<Plug>(signify-prev-hunk)'    , 'Sign:  -> prev hunk'],
         \ 'x' : {
            \ 'name' : '+extra',
            \ 'd' : [':Gvdiffsplit'                 , 'Git:   -> Gvdiffsplit'],
            \ 'c' : [':GV'                          , 'Git:   -> All commits'],
            \ 'C' : [':GV!'                         , 'Git:   -> Buffer commits'],
            \ },
         \ }
let g:which_key_map['t'] = {
         \ 'name' : '+Terminal',
         \ 's' : 'xTerm: -> Horizontal',
         \ 'v' : 'xTerm: -> Vertical',
         \ 'f' : 'xTerm: -> Float',
         \ }
let g:which_key_map['w'] = {
         \ 'name' : '+windows',
         \ 'q' : ['<C-W>c'     , 'Win: -> close-current-window'],
         \ 'x' : ['<C-W>q'     , 'Win: -> kill-current-window'],
         \ 's' : ['<C-W>s'     , 'Win: -> split-window-below'],
         \ 'v' : ['<C-W>v'     , 'Win: -> split-window-right'],
         \ '=' : ['<C-W>='     , 'Win: -> balance-window'],
         \ 'l' : ['<C-W>5<'    , 'Win: -> resize-window-right'],
         \ 'h' : ['<C-W>5>'    , 'Win: -> resize-window-left'],
         \ 'k' : [':resize +5' , 'Win: -> resize-window-up'],
         \ 'j' : [':resize -5' , 'Win: -> resize-window-below'],
         \ }
" see $HOME/dotfiles/vim/config/sensible.vim for definitions
let g:which_key_map['t'] = {
         \ 'name' : '+tabs',
         \ 'c' : 'Tab: -> tab-new',
         \ 'h' : 'Tab: -> tab-previous',
         \ 'l' : 'Tab: -> tab-next',
         \ 'q' : 'Tab: -> tab-close',
         \ 'x' : 'Tab: -> tab-kill',
         \ '1' : 'Tab: -> tab-1',
         \ '2' : 'Tab: -> tab-2',
         \ '3' : 'Tab: -> tab-3',
         \ '4' : 'Tab: -> tab-4',
         \ '5' : 'Tab: -> tab-5',
         \ 'o' : 'Tab: -> tab-only',
         \ 'e' : 'Tab: -> edit-in-tab',
         \ }
" see $HOME/dotfiles/vim/config/sensible.vim for definitions
let g:which_key_map['b'] = {
         \ 'name' : '+buffers',
         \ 'h' : 'Buf: -> buffer-previous',
         \ 'l' : 'Buf: -> buffer-next',
         \ 'q' : 'Buf: -> buffer-close',
         \ 'x' : 'Buf: -> buffer-kill',
         \ '1' : 'Buf: -> buffer-1',
         \ '2' : 'Buf: -> buffer-2',
         \ '3' : 'Buf: -> buffer-3',
         \ '4' : 'Buf: -> buffer-4',
         \ '5' : 'Buf: -> buffer-5',
         \ }
let g:which_key_map['r'] = {
         \ 'name' : '+register',
         \ 'p' : [':r !command ssh m1 pbpaste',                          'mac-paste'],
         \ 'P' : [':r !clip',                                            'unix-paste'],
         \ 'c' : [":call system('command ssh m1 pbcopy', getreg('\"'))", 'mac-copy'],
         \ }

autocmd! User vim-which-key call which_key#register('<Space>', 'g:which_key_map')
let $whichkey = '$RTP/config/whichkey.vim'
