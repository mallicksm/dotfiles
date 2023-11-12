function xch() {
    if [[ $# -eq 0 || $1 == "-h" || $1 == "--help" ]]; then
        echo "Usage: xch <file_pattern> <sed_pattern>"
        echo "   Apply sed pattern to files matching the specified file pattern."
        echo "   Example: xch *.txt s/foo/bar/g"
        return
    fi
    
    patterns=("$@")
    sed_pattern="${patterns[-1]}"
    unset 'patterns[${#patterns[@]}-1]'
    
    # Find matching files recursively and loop over them
    for pattern in "${patterns[@]}"; do
        find . -type f -name "$pattern" | while read -r file; do
            # Create a temporary file to store the modified version
            temp_file=$(mktemp)
            
            # Apply the sed command and save the output to the temporary file
            sed_output=$(sed "$sed_pattern" "$file" > "$temp_file" 2>&1)
            
            # Compare the original file with the temporary file and count the different lines
            num_differences=$(diff -u "$file" "$temp_file" | grep -E '^\+' | wc -l)
            
            if [[ $num_differences -gt 0 ]]; then
                # Changes were made
                mv "$temp_file" "$file"  # Replace the original file with the modified version
                echo "Applied sed pattern '$sed_pattern' to '$file' ($(($num_differences-1)) different lines)"
            else
                # No changes were made
                rm "$temp_file"  # Remove the temporary file
            fi
        done
    done
}
