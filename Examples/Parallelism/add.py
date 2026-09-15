#!/usr/bin/env python3

# Add together the numbers stored in each of the files given as arguments and
# print the result.  Used as the "reduce" step of the sum-of-squares workflow.

import sys

total = 0

for filename in sys.argv[1:]:
    with open(filename) as f_in:
        total += int(f_in.read().strip())

print(total)
