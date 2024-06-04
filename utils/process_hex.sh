#!/bin/bash

# Input and output file names
input_file="blank.hex"
output_file="output.txt"

# Clear the output file if it already exists
> $output_file

# Initialize an array to store lines
lines=()

# Read the file line by line into an array
while IFS= read -r line; do
    lines+=("$line")
done < "$input_file"

# Process the lines in pairs
for ((i = 0; i < ${#lines[@]}; i += 2)); do
    if (( i + 1 < ${#lines[@]} )); then
        # Combine two lines into one output line with zero padding
        combined_line="0000000000000000${lines[i]:6:2}${lines[i]:4:2}${lines[i]:2:2}${lines[i]:0:2}${lines[i+1]:6:2}${lines[i+1]:4:2}${lines[i+1]:2:2}${lines[i+1]:0:2}"
    else
        # Handle the case where there is an odd number of lines (last line with padding)
        combined_line="0000000000000000${lines[i]:6:2}${lines[i]:4:2}${lines[i]:2:2}${lines[i]:0:2}00000000"
    fi
    echo "$combined_line" >> $output_file
done

# Add the final fixed line to the output file
echo "0000000000000000FFFFFFFFFFFFFFFF" >> $output_file

