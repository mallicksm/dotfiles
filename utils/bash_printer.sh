function printer() {
   pdfprint() {
      # pdf print
      echo "Executing pdfprint..."
      for file in "${files[@]}"; do
         outfile=$(basename $file).pdf
         enscript -E --color $file -2rjGo - | ps2pdf - $outfile
         echo "Created: $outfile"
      done
   }

   liveprint() {
      # live print
      echo "Executing liveprint..."
      for file in "${files[@]}"; do
         enscript -E --color $file -2rjGo - | ps2pdf - $outfile
         lp -o fit-to-page $outfile
         rm $outfile
      done
   }

   # Function to display script usage
   usage() {
      echo "Usage: printer [-p|--print] file1 [file2 ...]"
      echo "   -p, --print:      Execute live print to default printer"
   }

   # Check if there are no arguments or only the -p/--print option provided
   if [ $# -eq 0 ] || [ "$1" = "-h" ]; then
      usage
      return
   fi

   # Flag to check if any valid files exist
   found_files=false
   live_print=false
   files=()

   # Execute pdfprint for each file passed as an argument
   for file in "$@"; do
      if [ "$file" = "-p" ] || [ "$file" = "--print" ]; then
         live_print=true
         continue # Remove the -p or --print option from the argument list
      fi
      if [ -e "$file" ]; then
         files+=($file)
         found_files=true
      else
         echo "File '$file' does not exist."
         usage
         return
      fi
   done

   # Print usage if no files were found
   if [ "$found_files" = false ]; then
      usage
      return
   fi

   # Check if the option is -p or --print and execute liveprint if present
   if [ "$live_print" = false ]; then
      pdfprint "$files"
   else 
      liveprint "$files"
   fi
}
