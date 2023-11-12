function dis() {
   input="$@"
   ARM_COMPILER=$(suite_exec --help|grep '^Arm Compiler.*6')
   export ARMLMD_LICENSE_FILE=8224@license01
   export ARM_PRODUCT_DEF=/opt/tools/arm/developmentstudio-2020.1-1/sw/ARMCompiler5.06u7/sw/mappings/gold.elmap

   echo "quit to exit"
   if [[ $input =~ ^(-h|help)$ ]]; then
      echo "Usage:"
      echo "   ${FUNCNAME[0]} -v7  - armv7 compiler"
      echo "   ${FUNCNAME[0]} -h|help"
      echo "quit to exit"
      return
   fi
   if [[ $input =~ ^(-v7)$ ]]; then
      ARCH="ARM-v7"
      CC=(suite_exec -q -t "$ARM_COMPILER" armclang --target=arm-arm-none-eabi -marm -mcpu=cortex-r5)
      LK=(suite_exec -q -t "$ARM_COMPILER" armlink --diag_suppress=L6305W)
      OBJDUMP=(aarch64-unknown-nto-qnx7.1.0-objdump)
   else
      ARCH="ARM-v8"
      CC=(suite_exec -q -t "$ARM_COMPILER" armclang --target=aarch64-arm-none-eabi)
      LK=(suite_exec -q -t "$ARM_COMPILER" armlink --diag_suppress=L6305W)
      OBJDUMP=(aarch64-unknown-nto-qnx7.1.0-objdump)
   fi
   while true; do
      read -p "$ARCH >> " input
      if [[ $input == "quit" ]]; then
         break
      fi
      echo "$input" > temp.s
      "${CC[@]}" -c -o temp.o temp.s
      if [ $? -eq 0 ]; then
          "${LK[@]}" -o temp temp.o
         if [ $? -eq 0 ]; then
            "${OBJDUMP[@]}" -d temp | grep '8[0-9]*:' | sed 's/.*:\s*//'
         fi
      fi
   done
   rm temp.s temp.o temp 2>/dev/null
}

