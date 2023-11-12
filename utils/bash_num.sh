function num {
   input="$@"
   if [[ ($input =~ ^(-h|help)$) || ($input == "") ]]; then
      echo "Usage:"
      echo "   ${FUNCNAME[0]} [1234|0xdeadbeef|2#1101|'0xab<<2'] - quote <<|>>"
      echo "   ${FUNCNAME[0]} [-h|help]                          - this message"
      return
   fi
   input=$(($input))
   printne "WHITE"   "dec: $input\n"
   printne "GREEN"   "hex: 0x"; print_sequence "$(printf "%X\n" $input)" 8
   printne "MAGENTA" "bin: 2#"; print_sequence "$(echo "obase=2; $input" | bc)" 4
}
