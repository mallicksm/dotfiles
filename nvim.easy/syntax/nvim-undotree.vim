" Vim syntax file
" Language:    nvim 0.12+ built-in undotree window
" Maintainer:  Soummya Mallick
"
" The plugin at $VIMRUNTIME/pack/dist/opt/nvim.undotree/lua/undotree.lua draws
" plain ASCII like:
"   * 0    (origin)
"   | * 1    (10:32:11)
"   |\ \
"   | * 2    (5 seconds ago)
" and only adds a Comment region for "(...)". This file layers colors on
" every glyph so the tree reads at a glance.

if exists("b:current_syntax")
   finish
endif

syn case match

" --- Trunk vertical line. Dim so it doesn't compete with nodes/branches.
syn match nvimUndotreeTrunk    /|/

" --- Branch glyphs (\ and /). Orange-ish to make forks pop.
syn match nvimUndotreeBranch   /[\\\/]/

" --- Node marker -- one * per undo state.
syn match nvimUndotreeNode     /\*/

" --- Sequence number that immediately precedes "    (timestamp)".
"     \zs/\ze trim the surrounding whitespace so only the digits highlight.
syn match nvimUndotreeSeq      /\<\d\+\>\ze\s\+(/

" --- Timestamp / "origin" inside parens. The built-in adds an identical
"     region at runtime; declaring it here too makes the highlight survive
"     the FileType-driven syntax reload, and keeps every glyph rule
"     suppressed inside the parens (contains=NONE).
syn region nvimUndotreeTime    start=/(/ end=/)/ oneline contains=NONE

hi def link nvimUndotreeTrunk    Comment
hi def link nvimUndotreeBranch   Special
hi def link nvimUndotreeNode     String
hi def link nvimUndotreeSeq      Number
hi def link nvimUndotreeTime     Comment

let b:current_syntax = "nvim-undotree"
" vim: ts=3 sts=3 sw=3 et
