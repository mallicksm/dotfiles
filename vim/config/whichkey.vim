" https://github.com/liuchengxu/vim-which-key
Plug 'liuchengxu/vim-which-key'
nnoremap <silent> <localleader> :<c-u>WhichKey ','<CR>
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>

" Define prefix dictionary
let g:which_key_hspace = 20
let g:space_prefix_dict = {
         \ 'name': '+root-menu',
         \ 'K' : 'Man under cursor',
         \ '<Down>' : 'Autopairs -Disable/Enable',
         \ '<Right>' : 'Autopairs -Jump to next closed pair',
         \ 'G' : ['GdbFloat'    , 'App: GDB'     ],
         \ 'P' : ['PythonFloat' , 'App: Python'  ],
         \ 'x' : [':qall!'      , 'kill-all'     ],
         \ 'h' : [':wincmd h'   , 'left-window'  ],
         \ 'j' : [':wincmd j'   , 'down-window'  ],
         \ 'k' : [':wincmd k'   , 'up-window'    ],
         \ 'l' : [':wincmd l'   , 'right-window' ],
         \ 'e' : 'Nerdtree Explorer',
         \ }
let g:space_prefix_dict['v'] = {
         \ 'name' : '+vim',
         \ '=' : ['gg=G<C-o><C-o>'     , 'vim Format'       ],
         \ 'i' : [':IndentLinesToggle' , 'toggle indentLine'],
         \ 'l' : [':set list!'         , 'toggle listchars' ],
         \ 'w' : [':set wrap!'         , 'wrap lines'       ],
         \ 'u' : [':UndotreeToggle'    , 'Toggle UndoTree'  ],
         \ 'n' : [':call NukeRegs()'   , 'Nuke Registers'   ],
         \ }
let g:space_prefix_dict['f'] = {
         \ 'name' : '+file-browser',
         \ 'r' : [':Rg!'                , 'fzf: Rg:       -> ripgrep'       ],
         \ 'f' : [':Files!'             , 'fzf: Files:    -> All files'     ],
         \ 'e' : [':GFiles!'            , 'fzf: GFiles:   -> files'         ],
         \ 'm' : [':GFiles!?'           , 'fzf: GFiles:   -> modified files'],
         \ 'b' : [':Buffers!'           , 'fzf: Buffers:  -> open buffers'  ],
         \ 't' : ['<C-w>gf'             , 'Win:   -> gf Tab'                ],
         \ 's' : ['<C-w>f'              , 'Win:   -> gf Split'              ],
         \ 'v' : [':vertical wincmd f'  , 'Win:   -> gf Vsplit'             ],
         \ 'x' : {
            \ 'name' : '+extra',
            \ 'w' : [':Windows'     , 'fzf: Windows:   -> open windows'        ],
            \ ';' : [':Commands'    , 'fzf: Commands:  -> commands'            ],
            \ '/' : [':History/'    , 'fzf: History:   -> history-search'      ],
            \ 'h' : [':History'     , 'fzf: History:   -> history-file'        ],
            \ 'H' : [':History:'    , 'fzf: History:   -> history-command'     ],
            \ 'l' : [':Lines'       , 'fzf: Lines:     -> lines-all'           ],
            \ 'L' : [':BLines'      , 'fzf: BLines:    -> lines-current-buffer'],
            \ 'T' : [':Tags'        , 'fzf: Tags:      -> project tags'        ],
            \ 't' : [':Helptags'    , 'fzf: Helptags:  -> help tags'           ],
            \ 'c' : [':Colors'      , 'fzf: Colors:    -> color schemes'       ],
            \ 'F' : [':Filetypes'   , 'fzf: Filetypes: -> file types'          ],
            \ 'm' : [':Maps'        , 'fzf: Maps:      -> normal maps'         ],
            \ },
         \ }
let g:space_prefix_dict['g'] = {
         \ 'name' : '+git' ,
         \ 'c' : [':Commits!'                    , 'fzf: Commits:  -> All commits'   ],
         \ 'C' : [':BCommits!'                   , 'fzf: BCommits: -> Buffer commits'],
         \ 'j' : ['<Plug>(signify-next-hunk)'    , 'Sign:  -> next hunk'             ],
         \ 'k' : ['<Plug>(signify-prev-hunk)'    , 'Sign:  -> prev hunk'             ],
         \ 'x' : {
            \ 'name' : '+extra',
            \ 'd' : [':Gvdiffsplit'                 , 'Git:   -> Gvdiffsplit'   ],
            \ 'c' : [':GV'                          , 'Git:   -> All commits'   ],
            \ 'C' : [':GV!'                         , 'Git:   -> Buffer commits'],
            \ },
         \ }
let g:space_prefix_dict['T'] = {
         \ 'name' : '+Terminal',
         \ 's' : 'xTerm: -> Horizontal',
         \ 'v' : 'xTerm: -> Vertical',
         \ 'f' : 'xTerm: -> Float',
         \ }
let g:space_prefix_dict['w'] = {
         \ 'name' : '+windows',
         \ 'q' : ['<C-W>c'     , 'Win: -> close-current-window'],
         \ 'x' : ['<C-W>q'     , 'Win: -> kill-current-window' ],
         \ 's' : ['<C-W>s'     , 'Win: -> split-window-below'  ],
         \ 'v' : ['<C-W>v'     , 'Win: -> split-window-right'  ],
         \ '=' : ['<C-W>='     , 'Win: -> balance-window'      ],
         \ 'l' : ['<C-W>5<'    , 'Win: -> resize-window-right' ],
         \ 'h' : ['<C-W>5>'    , 'Win: -> resize-window-left'  ],
         \ 'k' : [':resize +5' , 'Win: -> resize-window-up'    ],
         \ 'j' : [':resize -5' , 'Win: -> resize-window-below' ],
         \ }
let g:space_prefix_dict['t'] = {
         \ 'name' : '+tabs',
         \ 'c' : [':tabnew'    , 'Tab: -> tab-new'     ],
         \ 'h' : [':tabprev'   , 'Tab: -> tab-previous'],
         \ 'l' : [':tabnext'   , 'Tab: -> tab-next'    ],
         \ 'q' : [':tabclose'  , 'Tab: -> tab-close'   ],
         \ 'x' : [':tabclose!' , 'Tab: -> tab-kill'    ],
         \ '1' : [':tabnext 1' , 'Tab: -> tab-1'       ],
         \ '2' : [':tabnext 2' , 'Tab: -> tab-2'       ],
         \ '3' : [':tabnext 3' , 'Tab: -> tab-3'       ],
         \ '4' : [':tabnext 4' , 'Tab: -> tab-4'       ],
         \ '5' : [':tabnext 5' , 'Tab: -> tab-5'       ],
         \ 'o' : [':tabonly'   , 'Tab: -> tab-only'    ],
         \ }
let g:space_prefix_dict['b'] = {
         \ 'name' : '+buffers',
         \ 'h' : [':bprevious' , 'Buf: -> buffer-previous'],
         \ 'l' : [':bnext'     , 'Buf: -> buffer-next'    ],
         \ 'q' : [':bdelete'   , 'Buf: -> buffer-close'   ],
         \ 'x' : [':bdelete!'  , 'Buf: -> buffer-kill'    ],
         \ '1' : [':buffer1'   , 'Buf: -> buffer-1'       ],
         \ '2' : [':buffer2'   , 'Buf: -> buffer-2'       ],
         \ '3' : [':buffer3'   , 'Buf: -> buffer-3'       ],
         \ '4' : [':buffer4'   , 'Buf: -> buffer-4'       ],
         \ '5' : [':buffer5'   , 'Buf: -> buffer-5'       ],
         \ }
let g:space_prefix_dict['r'] = {
         \ 'name' : '+register',
         \ 'p' : ['MacPaste'              , 'mac-paste'      ],
         \ 'P' : [':r !clip'              , 'unix-paste'     ],
         \ 'c' : ['MacCopy'               , 'mac-copy'       ],
         \ 'C' : ['<Plug>OSCYankOperator' , 'Yank to buffer' ],
         \ }
let g:space_prefix_dict['X'] = {
         \ 'name' : '+extras',
         \ }

let g:comma_prefix_dict = {
         \ 'name': '+comma-menu',
         \ ',' : 'EasyMotion',
         \ 'C' : [':call CdToFile()'            , 'cd to %'               ],
         \ 'R' : [':call FullRefresh()'         , 'FullRefresh'           ],
         \ 'd' : [':SignifyDiff'                , 'Git Diff'              ],
         \ 'h' : [':call ConvertNumberBase(16)' , 'Convert to hex'        ],
         \ 'b' : [':call ConvertNumberBase(2)'  , 'Convert to bin'        ],
         \ 'f' : [':Filename'                   , 'Current full filename' ],
         \ }

augroup WhichKey
   autocmd!
   autocmd VimEnter * call which_key#register('<Space>', 'g:space_prefix_dict')
   autocmd VimEnter * call which_key#register(','      , 'g:comma_prefix_dict')
augroup end
let $whichkey = '$RTP/config/whichkey.vim'
