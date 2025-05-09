#!/bin/bash
## Script to sort planar average files into a consistent order

## Usage: sortpoints <infile>

grep --invert-match '  0.000000E+00  0.000000E+00  0.000000E+00  0.000000E+00' $1 > temp
sort -k2,2n -k1,1n temp > $1.sorted
