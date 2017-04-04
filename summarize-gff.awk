#!/bin/awk -f

# input: a gff file
# output: | count | type | tags
# For example:
#   525934   CDS    ID;Parent;pacid
#   58234    mRNA   ID;Name;pacid;Parent
#   48606    gene   ID;Name;ancestorIdentifier
#   30413    mRNA   ID;Name;pacid;longest;Parent
#   7438     gene   ID;Name

BEGIN{ FS="\t"; OFS="\t" }

{ 
    gsub(/=[^;]+/, "", $9)
    a[$3" "$9]++
}

END { for(k in a) { print a[k],k } }
