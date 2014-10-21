#!/bin/bash

seq=$1
map=$2

awk -v seq=$seq -v map=$map '
    FILENAME == map {
        m[$1] = $2
    }
    FILENAME == seq {
        if( /^>/ ) {
            seqid = gensub(/>([^ ]+)/, "\\1", 1, $1)
            if( seqid in m ){
                sub(seqid, m[seqid], $0)
            }
        }
        print
    } 
' $map $seq | sed 's/|.*//'
