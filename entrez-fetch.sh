#!/bin/bash

db= ids= retmax=500 rettype=

while getopts "d:i:t:r:" opt; do
    case $opt in
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
