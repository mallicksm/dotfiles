" https://github.com/liuchengxu/vim-which-key
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] } " On-demand lazy load

nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>

" Define prefix dictionary
let g:which_key_hspace = 200
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
let g:which_key_map['g'] = {
         \ 'name' : '+git' ,
         \ 'j' : ['<Plug>(signify-next-hunk)'    , 'Sign:  -> next hunk'],
         \ 'k' : ['<Plug>(signify-prev-hunk)'    , 'Sign:  -> prev hunk'],
         \ 't' : ['<C-w>gf'                      , 'Win:   -> gf Tab'],
         \ 's' : ['<C-w>f'                       , 'Win:   -> gf Split'],
         \ 'v' : [':vertical wincmd f'           , 'Win:   -> gf Vsplit'],
         \ 'd' : [':Gvdiffsplit'                 , 'Git:   -> Gvdiffsplit'],
         \ 'c' : [':GV'                          , 'Git:   -> All commits'],
         \ 'C' : [':GV!'                         , 'Git:   -> Buffer commits'],
         \ 'x' : {
            \ 'name' : '+extra',
            \ 'a' : [':Git add .'                   , 'Git:   -> add all'],
            \ 'A' : [':Git add %'                   , 'Git:   -> add current'],
            \ 'b' : [':Git blame'                   , 'Git:   -> blame'],
            \ 'c' : [':Git commit'                  , 'Git:   -> commit'],
            \ 'D' : [':Git diff'                    , 'Git:   -> diff'],
            \ 'G' : [':Git status'                  , 'Git:   -> status'],
            \ 'l' : [':Git log'                     , 'Git:   -> log'],
            \ 'p' : [':Git push'                    , 'Git:   -> push'],
            \ 'P' : [':Git pull'                    , 'Git:   -> pull'],
            \ 'r' : [':GRemove'                     , 'Git:   -> remove'],
            \ },
         \ }
let g:which_key_map['f'] = {
         \ 'name' : '+fzf',
         \ 'r' : [':Rg!'         , 'fzf: Rg:       -> ripgrep'],
         \ 'c' : [':Commits!'    , 'fzf: Commits:  -> All commits'],
         \ 'C' : [':BCommits!'   , 'fzf: BCommits: -> Buffer commits'],
         \ 'F' : [':Files!'      , 'fzf: Files:    -> All files'],
         \ 'f' : [':GFiles!'     , 'fzf: GFiles:   -> files'],
         \ 'm' : [':GFiles!?'    , 'fzf: GFiles:   -> modified files'],
         \ 'b' : [':Buffers!'    , 'fzf: Buffers:  -> open buffers'],
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
let g:which_key_map['w'] = {
         \ 'name' : '+windows',
         \ 'w' : ['<C-W>w'     , 'Win: -> other-window'],
         \ 'd' : ['<C-W>c'     , 'Win: -> delete-window'],
         \ 's' : ['<C-W>s'     , 'Win: -> split-window-below'],
         \ 'v' : ['<C-W>v'     , 'Win: -> split-window-right'],
         \ '=' : ['<C-W>='     , 'Win: -> balance-window'],
         \ 'l' : ['<C-W>5<'    , 'Win: -> expand-window-right'],
         \ 'h' : ['<C-W>5>'    , 'Win: -> expand-window-left'],
         \ 'k' : [':resize +5' , 'Win: -> expand-window-up'],
         \ 'j' : [':resize -5' , 'Win: -> expand-window-below'],
         \ }
let g:which_key_map['t'] = {
         \ 'name' : '+tabs',
         \ '1' : 'Tab: -> tab-1',
         \ '2' : 'Tab: -> tab-2',
         \ '3' : 'Tab: -> tab-3',
         \ '4' : 'Tab: -> tab-4',
         \ '5' : 'Tab: -> tab-5',
         \ 'c' : 'Tab: -> close-current-tab',
         \ 'n' : 'Tab: -> tab-new',
         \ 'o' : 'Tab: -> tab-only',
         \ 'e' : 'Tab: -> edit-in-tab',
         \ }
let g:which_key_map['b'] = {
         \ 'name' : '+buffers',
         \ '1' : 'Buf: -> buffer-1',
         \ '2' : 'Buf: -> buffer-2',
         \ '3' : 'Buf: -> buffer-3',
         \ '4' : 'Buf: -> buffer-4',
         \ '5' : 'Buf: -> buffer-5',
         \ 'p' : 'Buf: -> buffer-previous',
         \ 'n' : 'Buf: -> buffer-next',
         \ 'd' : 'Buf: -> buffer-delete',
         \ 'k' : 'Buf: -> buffer-kill',
         \ 'h' : 'Buf: -> buffer-home',
         \ }
let g:which_key_map['x'] = {
         \ 'name' : '+xTerm',
         \ 's' : 'xTerm: -> Horizontal',
         \ 'v' : 'xTerm: -> Vertical',
         \ 'f' : 'xTerm: -> Float',
         \ }
let g:which_key_map['r'] = {
         \ 'name' : '+register',
         \ 'p' : [':r !command ssh m1 pbpaste',                          'mac-paste'],
         \ 'P' : [':r !clip',                                            'unix-paste'],
         \ 'c' : [":call system('command ssh m1 pbcopy', getreg('\"'))", 'mac-copy'],
         \ }

autocmd! User vim-which-key call which_key#register('<Space>', 'g:which_key_map')
let $whichkey = '$RTP/config/whichkey.vim'
