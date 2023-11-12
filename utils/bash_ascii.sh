function ascii() {
   arg=$(echo "$1" | tr '[:upper:]' '[:lower:]')

   echo "ASCII Table:"
   echo "------------"
   printf "%-10s %-10s %-15s\n" "Decimal" "Hex" "Character"
   echo "--------------------------------"

   for ((i=0; i<=127; i++))
   do
      hex=$(printf "%02x" "$i")
      if (( i < 33 || i == 127 )); then
         case $i in
            0) char="NULL: '\\0' Null";;
            1) char="Start of Heading";;
            2) char="Start of Text";;
            3) char="End of Text";;
            4) char="End of Transmission";;
            5) char="Enquiry";;
            6) char="Acknowledge";;
            7) char="Bell";;
            8) char="BS: '\\b' Backspace";;
            9) char="TAB: '\\t' Horizontal Tab";;
            10) char="LF: '\\n' Line Feed";;
            11) char="Vertical Tab";;
            12) char="FF: '\\f' Form Feed";;
            13) char="CR: '\\r' Carriage Return";;
            14) char="Shift Out";;
            15) char="Shift In";;
            16) char="Data Link Escape";;
            17) char="Device Control 1";;
            18) char="Device Control 2";;
            19) char="Device Control 3";;
            20) char="Device Control 4";;
            21) char="Negative Acknowledge";;
            22) char="Synchronous Idle";;
            23) char="End of Transmission Block";;
            24) char="Cancel";;
            25) char="End of Medium";;
            26) char="Substitute";;
            27) char="Escape";;
            28) char="File Separator";;
            29) char="Group Separator";;
            30) char="Record Separator";;
            31) char="Unit Separator";;
            32) char="SPC: ' ' Space";;
            127) char="DEL: Delete";;
         esac
      else
         char=$(printf "\\x$(printf %x $i)")
      fi

      if [[ -z "$arg" ]] || [[ "$arg" == "$i" ]] || [[ "$arg" == "0x$hex" ]] || [[ $(echo "$char" | tr '[:upper:]' '[:lower:]') == *$(echo "$arg" | tr '[:upper:]' '[:lower:]')* ]]; then
         printf "%-10s %-10s %-15s\n" "$i" "0x$hex" "$char"
      fi
   done
}
