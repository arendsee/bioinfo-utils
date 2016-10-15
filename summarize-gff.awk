#!/bin/awk -f

BEGIN{ FS="\t"; OFS="\t" }

{ 
    gsub(/=[^;]+/, "", $9)
    a[$3" "$9]++
}

END { for(k in a) { print a[k],k } }
