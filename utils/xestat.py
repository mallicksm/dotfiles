#!/usr/bin/env python3

import os
import re

# Define the target patterns to search for and their corresponding substitution texts
# In this example, we capture the entire word.
target_patterns = [
   (r"Design utilization: (\S+)", "Design utilization is {}"),
   (r"Maximum emulator operating speed is (\S+) kHz.", "Maximum emulator operating speed is {} kHz."),
   (r"This design is scheduled in (\S+) steps", "This design is scheduled in {} steps"),
]

# Define the maximum depth to search for the file
max_depth = 1

# Function to search for the patterns in a file
def search_patterns_in_file(file_path, target_patterns):
   found_matches = []

   try:
      with open(file_path, 'r') as file:
         content = file.read()
         for pattern, substitution in target_patterns:
            matches = re.findall(pattern, content)
            if matches:
               for match in matches:
                  found_matches.append((substitution.format(match)))

   except Exception as e:
      pass

   return found_matches

# Search for the file in the current directory and its subdirectories
for root, dirs, files in os.walk(".", topdown=True):
   # Limit the search to a depth of 1
   if root.count(os.sep) - 1 > max_depth:
      continue
   if "xeCompile.log" in files:
      file_path = os.path.join(root, "xeCompile.log")
      found_matches = search_patterns_in_file(file_path, target_patterns)
      if found_matches:
         print(f"Matches found in {file_path}:")
         for match in found_matches:
            print(match)

if not found_matches:
   print("No matches found in 'xeCompile.log' within the specified depth.")

