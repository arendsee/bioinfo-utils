#!/bin/bash

prefix='' suffix='' map=
map=$1
prefix=$2
suffix=$3

[[ ! -r $map ]] && echo "USAGE: prog <map> [<prefix> [<suffix>]]" >&2 && exit 1

awk -v map=$map -v p=$prefix -v s=$suffix '
    FILENAME == map {
        m[$1] = $2
    }
    FILENAME != map {
        for (k in m){
            gsub(p k s, p m[k] s, $0)
        }
        print
    }
' $map <(cat)
