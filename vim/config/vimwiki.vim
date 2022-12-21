" https://github.com/vimwiki/vimwiki
" https://github.com/michal-h21/vimwiki-sync
Plug 'vimwiki/vimwiki'
Plug 'michal-h21/vimwiki-sync'

nmap <leader>Vi  <Plug>VimwikiIndex
nmap <leader>VI  <Plug>VimwikiUISelect
nmap <leader>VX  <Plug>VimwikiDeleteFile
nmap <leader>VR  <Plug>VimwikiRenameFile
nmap <leader>VDi <Plug>VimwikiDiaryIndex
nmap <leader>VDn <Plug>VimwikiMakeDiaryNote
nmap <leader>VDt <Plug>VimwikiMakeTomorrowDiaryNote
nmap <leader>VDy <Plug>VimwikiMakeYesterdayDiaryNote

let g:vimwiki_automatic_nested_syntaxes = 1
let g:vimwiki_dir_link = 'index'
let g:vimwiki_links_space_char = '_'
   " Vimwiki lists
let wiki_1 = {}
let wiki_1.path = '~/vimwiki/work/'
let wiki_1.index = 'index'
let wiki_1.nested_syntaxes = {'python': 'python', 'c': 'cpp'}
let wiki_1.auto_toc = 1
"let wiki_1.auto_export = 1     "export html

let wiki_2 = {}
let wiki_2.path = '~/vimwiki/personal/'
let wiki_2.index = 'index'
let wiki_2.nested_syntaxes = {'python': 'python', 'c': 'cpp'}
let wiki_2.auto_toc = 1
"let wiki_2.auto_export = 1     "export html
let g:vimwiki_list = [wiki_1, wiki_2]

function! VimwikiLinkHandler(link)
   " Use Vim to open external files with the 'vfile:' scheme.  E.g.:
   "   1) [[vfile:~/Code/PythonProject/abc123.py]]
   "   2) [[vfile:./|Wiki Home]]
   let link = a:link
   if link =~# '^vfile:'
      let link = link[1:]
   else
      return 0
   endif
   let link_infos = vimwiki#base#resolve_link(link)
   if link_infos.filename == ''
      echomsg 'Vimwiki Error: Unable to resolve link!'
      return 0
   else
      execute '! gio open ' . fnameescape(link_infos.filename)
      return 1
   endif
endfunction
augroup vimwikiSetting
   autocmd!
   autocmd VimEnter * call vimwiki#vars#init()
augroup end
let g:vimwiki_sync_branch = "master"
let g:vimwiki_hl_headers = 1
let g:vimwiki_listsyms = '✗○◐●✓'
let g:vimwiki_map_prefix = '<F13>'   "disable all maps
let $vimwiki = '$RTP/config/vimwiki.vim'
