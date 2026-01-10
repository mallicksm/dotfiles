" Semifore CSR Compiler DSL Syntax Highlighting
" Save as ~/.vim/syntax/semifore.vim

if exists("b:current_syntax")
  finish
endif

" ------------------------------------------------------------
" Tiered keywords (hierarchical via different highlight groups)
" ------------------------------------------------------------

" Tier 0: big structural constructs
syntax keyword semiforeTier0
      \ addressmap
      \ multi_intr_group
      \ userdefined

" Special-case: two-word construct "userdefined memory"
syntax match semiforeTier0Big "\v\<userdefined\>\s+\<memory\>"

" Tier 1: core CSR DSL blocks
syntax keyword semiforeTier1
      \ register property group

" Field: give it its own class (so it looks different than register/property)
syntax keyword semiforeField field

" Tier 2: interrupt DSL tokens
syntax keyword semiforeTier2
      \ interrupts interrupt_struct

" Other/misc tokens
syntax keyword semiforeMisc
      \ block default enum instance memory

" Optional: common property keys
syntax keyword semiforePropKey
      \ title description field_type reset_value output_port
      \ memory_word_count memory_width memory_error_port
      \ memory_read_access_port memory_ready_port

" ------------------------------------------------------------
" Comments
" ------------------------------------------------------------
syntax match  semiforeComment "//.*$"
syntax region semiforeComment start="/\*" end="\*/" keepend

" ------------------------------------------------------------
" Strings
" ------------------------------------------------------------
syntax region semiforeString start=+"+ skip=+\\\\\|\\"+ end=+"+ keepend

" ------------------------------------------------------------
" Ranges / indices: [31:0], [3], [40960]
" ------------------------------------------------------------
syntax match semiforeRange "\v\[\s*\d+\s*:\s*\d+\s*\]"
syntax match semiforeRange "\v\[\s*\d+\s*\]"

" ------------------------------------------------------------
" Verilog-style literals: 7'b0, 32'hDEAD, 1'd1
" ------------------------------------------------------------
syntax match semiforeNumber "\v\<\d+\s*'\s*[bdhoBDHO]\s*[0-9a-fA-F_xXzZ?]+\>"
syntax match semiforeNumber "\v\<\d+\>"

" ------------------------------------------------------------
" Attributes: (* ... *)
" ------------------------------------------------------------
syntax region semiforeAttr start="\V(*" end="\V*)" keepend

" ------------------------------------------------------------
" Operators / punctuation
" ------------------------------------------------------------
syntax match semiforeOperator "[:=,()]"
syntax match semiforeSemicolon ";"

" ------------------------------------------------------------
" Property key in "property <key> = ..." (make <key> pop)
" ------------------------------------------------------------
syntax match semiforePropertyKey "\v^\s*property\s+\zs[A-Za-z_]\w*" containedin=ALL

" ------------------------------------------------------------
" Name after closing brace or array: }name; or ]name;
" ------------------------------------------------------------
syntax match semiforeDeclName "\v\}\s*\zs[A-Za-z_]\w*" containedin=ALL
syntax match semiforeDeclName "\v\]\s*\zs[A-Za-z_]\w*" containedin=ALL

" ------------------------------------------------------------
" interrupt_struct'{  (quote-before-brace token)
" ------------------------------------------------------------
syntax match semiforeInterruptStructToken "\v\<interrupt_struct\>'\s*\{"

" ------------------------------------------------------------
" Highlight group links (colors come from your colorscheme)
" ------------------------------------------------------------

" Hierarchy / tiering
highlight default link semiforeTier0                PreProc
highlight default link semiforeTier0Big             PreProc
highlight default link semiforeTier1                Keyword
highlight default link semiforeTier2                Special
highlight default link semiforeMisc                 Type

" This is the key change you asked for:
" Make field look different from register/property.
highlight default link semiforeField                Identifier

" Keys / names
highlight default link semiforePropKey              Identifier
highlight default link semiforePropertyKey          Type
highlight default link semiforeDeclName             Function

" Values / misc
highlight default link semiforeRange                Number
highlight default link semiforeNumber               Number
highlight default link semiforeString               String
highlight default link semiforeAttr                 PreProc
highlight default link semiforeComment              Comment
highlight default link semiforeOperator             Operator
highlight default link semiforeSemicolon            Delimiter
highlight default link semiforeInterruptStructToken Special

let b:current_syntax = "semifore"
