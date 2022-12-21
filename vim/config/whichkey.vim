" https://github.com/liuchengxu/vim-which-key
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] } " On-demand lazy load

nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>

" Define prefix dictionary
let g:which_key_hspace = 200
let g:which_key_map = {
         \ 'name': '+root-menu',
         \ 'R' : 'FullRefresh',
         \ 'q' : 'which_key_ignore',
         \ 'D' : [':SignifyDiff', 'Git Diff'],
         \ 'C' : 'cd to %',
         \ 'e' : 'which_key_ignore',
         \ 'h' : 'which_key_ignore',
         \ 'j' : 'which_key_ignore',
         \ 'k' : 'which_key_ignore',
         \ 'l' : 'which_key_ignore',
         \ ' ' : 'easymotion [f,w]',
         \ 'G' : [':FloatermNew --width=0.60 --height=0.8 --title=gdb gdb -tui' , 'App: GDB'],
         \ 'E' : [':FloatermNew --title=explorer bash -i -c ,f | exit 0'        , 'App: Explorer'],
         \ 'P' : [':FloatermNew --title=python python'                          , 'App: Python'],
         \ }
let g:which_key_map['r'] = {
         \ 'name' : '+register',
         \ 'p' : [':r !command ssh m1 pbpaste',                          'mac-paste'],
         \ 'P' : [':r !clip',                                            'unix-paste'],
         \ 'c' : [":call system('command ssh m1 pbcopy', getreg('\"'))", 'mac-copy'],
         \ }
let g:which_key_map['v'] = {
         \ 'name' : '+vim',
         \ '=' : 'vim Format',
         \ 'i' : 'toggle indentLine',
         \ 'l' : 'toggle listchars',
         \ 'w' : 'wrap lines',
         \ 'u' : [':UndotreeToggle' , 'Toggle UndoTree'],
         \ 'n' : [':call NukeRegs()', 'Nuke Registers'],
         \ }
let g:which_key_map['w'] = {
         \ 'name' : '+windows',
         \ 'w' : ['<C-W>w'     , 'other-window'],
         \ 'd' : ['<C-W>c'     , 'delete-window'],
         \ 's' : ['<C-W>s'     , 'split-window-below'],
         \ 'v' : ['<C-W>v'     , 'split-window-right'],
         \ '=' : ['<C-W>='     , 'balance-window'],
         \ 'l' : ['<C-W>5<'    , 'expand-window-right'],
         \ 'h' : ['<C-W>5>'    , 'expand-window-left'],
         \ 'k' : [':resize +5' , 'expand-window-up'],
         \ 'j' : [':resize -5' , 'expand-window-below'],
         \ '?' : ['Windows'    , 'fzf-window'],
         \ }
let g:which_key_map['t'] = {
         \ 'name' : '+tabs',
         \ '1' : 'tab-1',
         \ '2' : 'tab-2',
         \ '3' : 'tab-3',
         \ '4' : 'tab-4',
         \ '5' : 'tab-5',
         \ 'c' : 'close-current-tab',
         \ 'n' : 'tab-new',
         \ 'o' : 'tab-only',
         \ 'e' : 'edit-in-tab',
         \ }
let g:which_key_map['x'] = {
         \ 'name' : '+xTerm',
         \ 's' : 'split-horizontal',
         \ 'v' : 'split-vertical',
         \ }
let g:which_key_map['b'] = {
         \ 'name' : '+buffers',
         \ '1' : 'buffer-1',
         \ '2' : 'buffer-2',
         \ '3' : 'buffer-3',
         \ '4' : 'buffer-4',
         \ '5' : 'buffer-5',
         \ 'p' : 'buffer-previous',
         \ 'n' : 'buffer-next',
         \ 'd' : 'buffer-delete',
         \ 'k' : 'buffer-kill',
         \ 'h' : 'buffer-home',
         \ '?' : ['Buffers', 'fzf-buffer'],
         \ }
let g:which_key_map['g'] = {
         \ 'name' : '+git' ,
         \ 't' : ['<C-w>gf'                      , 'gf Tab'],
         \ 's' : ['<C-w>f'                       , 'gf Split'],
         \ 'v' : [':vertical wincmd f'           , 'gf Vsplit'],
         \ 'f' : ['gf'                           , 'which_key_ignore'],
         \ 'b' : [':e#'                          , 'which_key_ignore'],
         \ 'j' : ['<Plug>(signify-next-hunk)'    , 'next hunk'],
         \ 'k' : ['<Plug>(signify-prev-hunk)'    , 'prev hunk'],
         \ 'x' : {
            \ 'name' : '+extra',
            \ 'a' : [':Git add .'                   , 'add all'],
            \ 'A' : [':Git add %'                   , 'add current'],
            \ 'b' : [':Git blame'                   , 'blame'],
            \ 'c' : [':Git commit'                  , 'commit'],
            \ 'd' : [':Git diff'                    , 'diff'],
            \ 'D' : [':Gvdiffsplit'                 , 'diff split'],
            \ 'G' : [':Git status'                  , 'status'],
            \ 'l' : [':Git log'                     , 'log'],
            \ 'p' : [':Git push'                    , 'push'],
            \ 'P' : [':Git pull'                    , 'pull'],
            \ 'r' : [':GRemove'                     , 'remove'],
            \ 'v' : [':GV'                          , 'view commits'],
            \ 'V' : [':GV!'                         , 'view buffer commits'],
            \ },
         \ }
let g:which_key_map['f'] = {
         \ 'name' : '+fzf',
         \ 'r' : [':Rg'          , 'ripgrep Rg'],
         \ 'c' : [':BCommits'    , 'commits-buffer'],
         \ 'C' : [':Commits'     , 'commits-all'],
         \ ';' : [':Commands'    , 'commands'],
         \ '/' : [':History/'    , 'history-search'],
         \ 'h' : [':History'     , 'history-file'],
         \ 'H' : [':History:'    , 'history-command'],
         \ 'm' : [':Marks'       , 'marks'] ,
         \ 'o' : {
            \ 'name' : '+open',
            \ 'b' : [':Buffers'     , 'open buffers'],
            \ 'w' : [':Windows'     , 'open windows'],
            \ },
         \ 'f' : {
            \ 'name' : '+files',
            \ 'f' : [':FZF'         , 'files'],
            \ 'g' : [':GFiles'      , 'git files'],
            \ 'm' : [':GFiles?'     , 'modified git files'],
            \ },
         \ 'x' : {
            \ 'name' : '+extra',
            \ 'l' : [':Lines'       , 'lines-all'] ,
            \ 'L' : [':BLines'      , 'lines-current-buffer'],
            \ 't' : [':BTags'       , 'buffer tags'],
            \ 'T' : [':Tags'        , 'project tags'],
            \ 'h' : [':Helptags'    , 'help tags'] ,
            \ 'c' : [':Colors'      , 'color schemes'],
            \ 'F' : [':Filetypes'   , 'file types'],
            \ 'm' : [':Maps'        , 'normal maps'] ,
            \ },
         \ }
let g:which_key_map['V'] = {
         \ 'name' : '+vimwiki',
         \ 'i' : 'VimWiki Index',
         \ 'I' : 'VimWiki Index Root select',
         \ 'X' : 'VimWiki Delete file',
         \ 'R' : 'VimWiki Rename file',
         \ 'D' : {
            \ 'name' : '+vimwikiDiary',
            \ 'i' : 'VimWikiDiary Index',
            \ 'n' : 'VimWikiDiary Note',
            \ 't' : 'VimWikiDiary Tomorrow',
            \ 'y' : 'VimWikiDiary Yesterday',
            \ },
         \ }

autocmd! User vim-which-key call which_key#register('<Space>', 'g:which_key_map')
let $whichkey = '$RTP/config/whichkey.vim'
