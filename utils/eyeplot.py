#!/usr/bin/env python3
import sys
import re
import matplotlib.pyplot as plt

def filter_data(data, pattern):
    filtered_data = [];
    for row in data:
        if re.search(pattern, f"{int(row[0])},{int(row[1])}"):
            filtered_data.append(row)
    return filtered_data

if len(sys.argv) < 2:
    print("Usage: python script_name.py [-b pattern] <input_file>")
    sys.exit(1)

input_file = sys.argv[-1]
filter_pattern = None

if len(sys.argv) == 4 and sys.argv[1] == "-b":
    filter_pattern = sys.argv[2];

data = []
# Read data from file
with open(input_file, "r") as file:
    for line in file:
        values = line.strip().split(',')

        if len(values) == 7 and all(val.replace('.', '', 1).isdigit() for val in values):
            try:
                row = list(map(float, values))
                data.append(row)
            except ValueError:
                pass  # Skip lines that can't be converted to floats

if filter_pattern:
    data = filter_data(data, filter_pattern)

# Separate data based on unique values in column 1 and 2
separated_data = {}
for row in data:
    key = (row[0], row[1])
    if key not in separated_data:
        separated_data[key] = {'column3': [], 'column6': [], 'column7': []}
    separated_data[key]['column3'].append(row[2])
    separated_data[key]['column6'].append(row[5])
    separated_data[key]['column7'].append(row[6])

plt.figure(figsize=(20, 12))

# Plot each combination of column 1 and 2 on the same graph
for key, values in separated_data.items():
    plt.plot(values['column3'], values['column6'], marker='.', label=f"Slice={int(key[0])} Bit={int(key[1])}")
    plt.plot(values['column3'], values['column7'], marker='.')

plt.xlabel("VREF")
plt.ylabel("Values (ps)")
plt.title(f"LPDDR Eye diagram plot {input_file}")
plt.legend()

plt.tight_layout()
plt.show()

