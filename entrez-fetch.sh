#!/bin/bash

db= ids= retmax=500 rettype= version=1.0.0

while getopts "hd:i:t:r:" opt; do
    case $opt in
        h)
            echo "entrez-fetch v$version"
            echo "  -d database name"
            echo "  -i ids (read from STDIN be default)"
            echo "  -r maximum number of records to retrieve (default=500)"
            exit 0 ;;
        d)
            db=$OPTARG
            if [[ "$db" =~ ' ' ]];then
                echo "database must be a single word" > /dev/stderr
                exit 1
            fi
            ;;
        i)
            ids=$(echo $OPTARG | tr ' ' ',') ;;
        t)
            rettype=$OPTARG ;;
        r)
            retmax=$OPTARG
            if [[ $retmax =~ '^[0-9]' ]]; then
                echo "retmax must be an integer" > /dev/stderr
                exit 1
            fi ;;
    esac 
done

if [[ $ids == '' ]]; then
    while read line; do
        ids=$ids",$line"
    done
    ids=$(echo $ids | sed 's/,$//')
fi

url="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?"
url=$url"db=$db&id=$ids&retmax=$retmax"
if [[ $rettype != '' ]]; then
    url=$url"&rettype=$rettype"
fi

wget -O /dev/stdout $url 2> /dev/null
