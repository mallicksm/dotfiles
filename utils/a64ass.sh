#!/bin/bash

while true; do
    read -p ">> " input
    if [[ $input == "quit" ]]; then
        break
    fi
    echo "$input" > temp.s
    suite_exec -q -t 'Arm Compiler 6' armclang --target=aarch64-arm-none-eabi -c -o temp.o temp.s
    if [ $? -eq 0 ]; then
        suite_exec -q -t 'Arm Compiler 6' armlink --diag_suppress=L6305W -o temp temp.o
        if [ $? -eq 0 ]; then
            aarch64-unknown-nto-qnx7.1.0-objdump -d temp | grep '8[0-9]*:' | sed 's/.*:\s*//'
        fi
    fi
done
rm temp.s temp.o temp

