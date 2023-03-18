" Vim syntax file
" Language: c
" Maintainer: Soummya Mallick
" Latest Revision: 2020-11-12
if exists("b:c_syntax")
  finish
endif
syntax keyword xv6type uint8 uint16 uint32 uint64 pte_t pde_t
highlight default link xv6type Type
