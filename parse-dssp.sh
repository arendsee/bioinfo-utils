#!/bin/bash
set -u

# Input: a PDB file
# Output: TAB-delimited line containing secondary structure counts
#   1. structure id - taken from the PDB filename
#   2. beta-strand count
#   3. alpha-helix count
#   4. total residue count
# Recommended usage:
# ls *.pdb | parallel parse-dssp.sh {} > ss.tab

dssp -i $1 |
    sed -n '/#/,$ p' |
    sed '1d' |
    cut -b17 |
    sort | uniq -c |
    awk -v name=$(basename $1 | sed 's/\.pdb//') '
        BEGIN{
            OFS="\t"
            E = 0
            H = 0
            N = 0
        }
        {N += $1}
        $2 ~ /[BE]/ {E += $1}
        $2 ~ /[GHI]/ {H += $1}
        END{print name, E, H, N}'
