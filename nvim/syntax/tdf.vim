" Vim syntax file
" Language: Cadence TDF File
" Maintainer: Soummya Mallick
" Latest Revision: 2020-11-12

if exists("b:current_syntax")
  finish
endif

syntax keyword tdfKeyword INSTANCE STATE IF ELSE 
syntax keyword tdfKeyword instance state if else 
syntax keyword tdfAction GOTO LOAD DECREMENT INCREMENT START STOP TRIGGER ACQUIRE NO_ACQUIRE EXEC DISPLAY TX TRACE_TSM
syntax keyword tdfAction goto load decrement increment start stop trigger acquire no_acquire exec display tx trace_tsm
syntax keyword tdfVariables COUNTER1 COUNTER2
syntax keyword tdfVariables counter1 counter2
syntax keyword tdfOperator TRANSITION
syntax keyword tdfOperator transition
syntax match tdfComment    "//.*"
syntax match tdfNumber     "\d+"
syntax match tdfString     "\".*\""
syntax match tdfTclvar     "\$\S*(\=\w\+)\="
syntax match tdfFacs       "{.*}"
syntax match verilogNumber "\(\d\+\)\?'[sS]\?[bB]\s*[0-1_xXzZ?]\+"
syntax match verilogNumber "\(\d\+\)\?'[sS]\?[oO]\s*[0-7_xXzZ?]\+"
syntax match verilogNumber "\(\d\+\)\?'[sS]\?[dD]\s*[0-9_xXzZ?]\+"
syntax match verilogNumber "\(\d\+\)\?'[sS]\?[hH]\s*[0-9a-fA-F_xXzZ?]\+"
syntax match verilogNumber "\<[+-]\?[0-9_]\+\(\.[0-9_]*\)\?\(e[0-9_]*\)\?\>"
syntax match verilogNumber "\<\d[0-9_]*\(\.[0-9_]\+\)\=\([fpnum]\)\=s\>"

highlight default link tdfKeyword    Keyword
highlight default link tdfComment    Comment
highlight default link verilogNumber Number
highlight default link tdfAction     Function
highlight default link tdfVariables  Tag     
highlight default link tdfOperator   PreProc
highlight default link tdfString     String
highlight default link tdfTclvar     Underlined
highlight default link tdfFacs       TabLineSel
