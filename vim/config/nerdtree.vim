" https://github.com/preservim/nerdtree
Plug 'scrooloose/nerdtree' |
         \ Plug 'ryanoasis/vim-devicons' |
         \ Plug 'Xuyuanp/nerdtree-git-plugin'
"Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'johnstef99/vim-nerdtree-syntax-highlight'
nnoremap <expr> <leader>e g:NERDTree.IsOpen() ? ':NERDTreeClose<CR>' : @% == '' ? ':NERDTree<CR>' : ':NERDTreeFind<CR>'
let g:NERDTreeWinSize=35
let g:NERDTreeShowBookmarks=1
let NERDTreeIgnore=['\.d$', '\.o$']
let NERDTreeBookmarksSort=1
let NERDTreeShowLineNumbers=1
let NERDTreeAutoDeleteBuffer=1
let NERDTreeMinimalUI = 1
let NERDTreeSortOrder= ['\/$', '.*README.*', 'Makefile', '\.mk', '\.sh', '[[extension]]']
let NERDTreeMapOpenVSplit    = 'v'
let NERDTreeMapOpenSplit     = 's'
let NERDTreeMapPreviewVSplit = 'gv'
let NERDTreeMapPreviewSplit  = 'gs'

augroup NERDTreeCustom
   autocmd!
   autocmd VimEnter * call NERDTreeAddKeyMap({
            \ 'key': 'yy',
            \ 'callback': 'NERDTreeYankFullPath',
            \ 'quickhelpText': 'put full path of current node into the default register' })
   autocmd VimEnter * :Reload
augroup end

function! NERDTreeYankFullPath()
   let n = g:NERDTreeFileNode.GetSelected()
   if n != {}
      call setreg('"', n.path.str())
   endif
   call nerdtree#echo("Node full path yanked!")
endfunction

function! FullRefresh()
   :e!
   :NERDTreeRefreshRoot
   :NERDTreeFind
   call webdevicons#refresh()
endfunction

"-------------------------------------------------------------------------------
" nerdtree-git-plugin
let g:NERDTreeGitStatusShowClean = 0 " shows ✔ when clean

"-------------------------------------------------------------------------------
" vim-nerdtree-syntax-highlight
" Disable unmatched folder and file icons having the same color as their labels
let g:WebDevIconsDisableDefaultFolderSymbolColorFromNERDTreeDir = 1
let g:WebDevIconsDisableDefaultFileSymbolColorFromNERDTreeFile = 1

" Highlight full name (not only icons).
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1

let s:brown       = "905532"
let s:aqua        = "3AFFDB"
let s:blue        = "689FB6"
let s:darkBlue    = "44788E"
let s:purple      = "834F79"
let s:lightPurple = "834F79"
let s:red         = "AE403F"
let s:beige       = "F5C06F"
let s:yellow      = "F09F17"
let s:orange      = "D4843E"
let s:darkOrange  = "F16529"
let s:pink        = "CB6F6F"
let s:salmon      = "EE6E73"
let s:green       = "8FAA54"
let s:lightGreen  = "31B53E"
let s:white       = "FFFFFF"
let s:rspec_red   = 'FE405F'
let s:git_orange  = 'F54D27'

let g:NERDTreeExtensionHighlightColor = {} " this line is needed to avoid error
let g:NERDTreeExtensionHighlightColor['qel'] = s:aqua
let g:NERDTreeExtensionHighlightColor['tcl'] = s:aqua
let g:NERDTreeExtensionHighlightColor['tdf'] = s:lightGreen
let g:NERDTreeExtensionHighlightColor['v'] = s:blue
let g:NERDTreeExtensionHighlightColor['sv'] = s:blue
let g:NERDTreeExtensionHighlightColor['vhd'] = s:blue
let g:NERDTreeExtensionHighlightColor['cpp'] = s:blue
let g:NERDTreeExtensionHighlightColor['c'] = s:blue
let g:NERDTreeExtensionHighlightColor['asm'] = s:blue
let g:NERDTreeExtensionHighlightColor['S'] = s:blue
let g:NERDTreeExtensionHighlightColor['svh'] = s:salmon
let g:NERDTreeExtensionHighlightColor['vh'] = s:salmon
let g:NERDTreeExtensionHighlightColor['h'] = s:salmon
let g:NERDTreeExtensionHighlightColor['f'] = s:pink
let g:NERDTreeExtensionHighlightColor['svcf'] = s:rspec_red
let g:NERDTreeExtensionHighlightColor['log'] = s:brown
let g:NERDTreeExtensionHighlightColor['msg'] = s:brown
let g:NERDTreeExtensionHighlightColor['out'] = s:brown
let g:NERDTreeExtensionHighlightColor['sh'] = s:lightGreen
let g:NERDTreeExtensionHighlightColor['mk'] = s:rspec_red
let g:NERDTreePatternMatchHighlightColor = {}                        " this line is needed to avoid error
let g:NERDTreePatternMatchHighlightColor['Makefile.*'] = s:rspec_red " sets the color for file pattern Makefile.*
let g:NERDTreePatternMatchHighlightColor['.*README.*'] = s:git_orange

let g:WebDevIconsDefaultFolderSymbolColor = s:beige " sets the color for folders that did not match any rule
let g:WebDevIconsDefaultFileSymbolColor = s:blue    " sets the color for files that did not match any rule
let $nerdtree = '$RTP/config/nerdtree.vim'
