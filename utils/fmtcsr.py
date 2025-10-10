#!/usr/bin/env python3
import sys, re

indent = 0
IND = " " * 3

def normalize_spaces(line: str) -> str:
    # Collapse excessive spaces, but preserve those inside quotes and after backticks.
    # Leave lines starting with ` (include) untouched.
    if line.lstrip().startswith("`"):
        return line.rstrip()
    # Preserve leading comment spacing
    if re.match(r'^\s*//', line):
        return line.rstrip()
    # Light touch: collapse runs of spaces to one, except around brackets/semicolons
    s = re.sub(r'\s+', ' ', line.strip())
    s = re.sub(r'\s*([{};\[\]])\s*', r'\1', s)
    # Put a single space before '{' when it follows an identifier/keyword
    s = re.sub(r'([A-Za-z0-9_])\{', r'\1 {', s)
    # Restore space after keywords like "group", "register", "field", "property"
    s = re.sub(r'\b(group|register|field|property|addressmap|userdefined|memory)\s*{', r'\1 {', s)
    return s

out = []
for raw in sys.stdin:
    line = raw.rstrip("\n")
    stripped = line.strip()

    if stripped == "":
        out.append("")
        continue

    # Count closing braces first (outdent)
    close_count = stripped.count("}")
    open_count  = stripped.count("{")

    # If line starts with '}' reduce indent before printing
    lead_close = stripped.startswith("}")
    if lead_close:
        indent = max(0, indent - 1)

    # Normalize spacing cautiously
    s = normalize_spaces(line)

    # Special cases: keep field/register/property one-liners tidy
    # e.g. field { ... } [31:0] foo;
    s = re.sub(r'\s*;\s*$', ';', s)

    # Apply current indent
    out.append(f"{IND*indent}{s}".rstrip())

    # Adjust indent for any additional '{' beyond the leading one
    # If line contains '{' and didn?t start with '}', we already printed at current indent then increase.
    # Increase by number of '{' minus number of '}' that are not leading a line
    # But simplest: if line ends up with more '{' total than '}', bump by that diff.
    diff = open_count - close_count
    if not lead_close and diff > 0:
        indent += diff
    elif diff < 0 and not lead_close:
        # Handles lines like "} ual;" where we didn?t reduce at start
        indent = max(0, indent + diff)

print("\n".join(out))
