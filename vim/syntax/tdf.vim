" Vim syntax file
" Language: Cadence TDF File
" Maintainer: Soummya Mallick
" Latest Revision: 2020-11-12

if exists("b:current_syntax")
  finish
endif

syntax keyword tdfInstance INSTANCE instance Instance
syntax keyword tdfStateMachine STATE IF ELSE 
syntax keyword tdfStateMachine state if else 
syntax keyword tdfStateMachine State If Else 
syntax keyword tdfCounters COUNTER1 COUNTER2 ENABLE1 ENABLE2
syntax keyword tdfCounters counter1 counter2 enable1 enable2
syntax keyword tdfAction GOTO LOAD DECREMENT INCREMENT START STOP TRIGGER ACQUIRE NO_ACQUIRE EXEC DISPLAY TX TRACE_TSM
syntax keyword tdfAction goto load decrement increment start stop trigger acquire no_acquire exec display tx trace_tsm
syntax keyword tdfAction Goto Load Decrement Increment Start Stop Trigger Acquire No_acquire Exec Display Tx Trace_tsm
syntax keyword tdfOperator TRANSITION COUNT
syntax keyword tdfOperator transition count
syntax match tdfComment    "//.*"
syntax match tdfComment    "/\*.*\*/"
syntax match tdfString     "\".*\""
syntax match tdfTclvar     "\$\S*(\=\w\+)\="
syntax match tdfFacs       "{.*}"
syntax match verilogNumber "\(\d\+\)\?'[sS]\?[bB]\s*[0-1_xXzZ?]\+"
syntax match verilogNumber "\(\d\+\)\?'[sS]\?[oO]\s*[0-7_xXzZ?]\+"
syntax match verilogNumber "\(\d\+\)\?'[sS]\?[dD]\s*[0-9_xXzZ?]\+"
syntax match verilogNumber "\(\d\+\)\?'[sS]\?[hH]\s*[0-9a-fA-F_xXzZ?]\+"
syntax match verilogNumber "\<[+-]\?[0-9_]\+\(\.[0-9_]*\)\?\(e[0-9_]*\)\?\>"
syntax match verilogNumber "\<\d[0-9_]*\(\.[0-9_]\+\)\=\([fpnum]\)\=s\>"

highlight default link tdfInstance      Function
highlight default link tdfStateMachine  Keyword
highlight default link tdfCounters      Type
highlight default link tdfAction        Tag
highlight default link tdfOperator      PreProc
highlight default link tdfComment       Comment
highlight default link tdfString        String
highlight default link tdfTclvar        Underlined
highlight default link tdfFacs          Statement
highlight default link verilogNumber    Number
