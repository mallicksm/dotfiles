#!/bin/bash
echo "Note: please export ARMV7=1 for v7 (v8 default)"
echo "   quit to exit"
if [[ $ARMV7 ]]; then
   ARCH="ARM-v7"
   CC=(suite_exec -q -t 'Arm Compiler 6' armclang --target=arm-arm-none-eabi -marm -mcpu=cortex-r5)
   LK=(suite_exec -q -t 'Arm Compiler 6' armlink --diag_suppress=L6305W)
   OBJDUMP=(aarch64-unknown-nto-qnx7.1.0-objdump)
else
   ARCH="ARM-v8"
   CC=(suite_exec -q -t 'Arm Compiler 6' armclang --target=aarch64-arm-none-eabi)
   LK=(suite_exec -q -t 'Arm Compiler 6' armlink --diag_suppress=L6305W)
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

