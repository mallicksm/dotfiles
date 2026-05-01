" Vim syntax file
" Language:    GCC/LD linker map file (-Wl,-Map=foo.map output)
" Maintainer:  Soummya Mallick

if exists("b:current_syntax")
   finish
endif

syn case match

" --- Big section banners ---
syn match mapBanner   /^Archive member included.*$/
syn match mapBanner   /^Allocating common symbols$/
syn match mapBanner   /^Common symbol\s\+size\s\+file$/
syn match mapBanner   /^Discarded input sections$/
syn match mapBanner   /^Memory Configuration$/
syn match mapBanner   /^Linker script and memory map$/
syn match mapBanner   /^Cross Reference Table$/

" --- Memory configuration table column header ---
syn match mapTableHdr /^Name\s\+Origin\s\+Length\s\+Attributes\s*$/

" --- Hex addresses & sizes (0x...) ---
syn match mapHex      /\<0x\x\+\>/

" --- Section names: .text, .data, .text.startup, .rodata.str1.1, etc. ---
syn match mapSection  /\.\h[A-Za-z0-9_.]*/

" --- Memory region attributes at EOL: r/w/x/a/i/l/! (e.g. "xr", "rwx") ---
syn match mapMemAttr  /\s\zs[rwxail!]\{1,5}\ze\s*$/

" --- Object / archive references ---
syn match mapObject   /\f\+\.o\>/
syn match mapArchive  /\f\+\.a([^)]\+)/
syn match mapLib      /\<lib\h[A-Za-z0-9_+-]*\.\%(a\|so\%(\.\d\+\)*\)\>/

" --- LD-script wildcard input-section spec, e.g. *(.text*) ---
syn match mapWildcard /\*(\s*[^)]*)/

" --- LD-script keywords occasionally embedded in the map ---
syn keyword mapKeyword LOAD START END OUTPUT OUTPUT_FORMAT OUTPUT_ARCH
syn keyword mapKeyword INPUT GROUP SECTIONS MEMORY PROVIDE PROVIDE_HIDDEN
syn keyword mapKeyword KEEP ENTRY ASSERT AT ALIGN BLOCK FILL
syn keyword mapKeyword BYTE SHORT LONG QUAD SQUAD ORIGIN LENGTH
syn keyword mapCommon  COMMON

" --- Embedded /* */ comments (from inlined LD-script fragments) ---
syn region mapComment  start=/\/\*/ end=/\*\// contains=NONE

hi def link mapBanner    Title
hi def link mapTableHdr  Underlined
hi def link mapHex       Number
hi def link mapSection   Type
hi def link mapMemAttr   Statement
hi def link mapObject    Identifier
hi def link mapArchive   Identifier
hi def link mapLib       Identifier
hi def link mapWildcard  Special
hi def link mapKeyword   Keyword
hi def link mapCommon    Special
hi def link mapComment   Comment

let b:current_syntax = "map"
" vim: ts=3 sts=3 sw=3 et
