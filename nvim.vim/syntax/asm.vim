" Vim syntax file
" Language: c
" Maintainer: Soummya Mallick
" Latest Revision: 2020-11-12
if exists("b:asm_syntax")
  finish
endif
syntax keyword Macros PROC ENDPROC VENTRY NELEM UNUSED_VARIABLE COMPILER_BARRIER CLI_EXTERN CLI_ALIASES CLI_HELP
highlight default link Macros Tag
syntax match myInclude "#include.*\|#ifdef.*\|#else\|#endif"
highlight default link myInclude String
match asmTodo /\(Note:\|Definition:\|Code Section:\)/
