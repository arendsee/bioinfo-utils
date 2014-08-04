#!/bin/bash

dbfrom= dbto= ids= retmax=500 version=1.0.0 one2one=0

while getopts "hr:i:t:f:u" opt; do
    case $opt in
        h)
            echo "entrez-link v$version"
            echo "  -r NUM maximum number of records to retrieve (default=500)"
            echo "  -i NUM ids (read from STDIN be default)"
            echo "  -f STR from database name"
            echo "  -t STR to database name"
            echo "  -u     map ids one-to-one"
            exit 0 ;;
        r)
            retmax=$OPTARG
            if [[ $retmax =~ '^[0-9]' ]]; then
                echo "retmax must be an integer" > /dev/stderr
                exit 1
            fi ;;
        i)
            ids=$(echo $OPTARG | tr ' ' ',') ;;
        f)
            dbfrom=$OPTARG
            if [[ "$dbfrom" =~ ' ' ]];then
                echo "database must be a single word" > /dev/stderr
                exit 1
            fi
            ;;
        t)
            dbto=$OPTARG
            if [[ "$dbto" =~ ' ' ]];then
                echo "database must be a single word" > /dev/stderr
                exit 1
            fi
            ;;
        u)
            one2one=1 ;;
    esac 
done

if [[ $ids == '' ]]; then
    while read line; do
        ids=$ids",$line"
    done
    ids=$(echo $ids | sed 's/,$//; s/^,//')
fi

if [[ $one2one == 1 ]]; then
    ids=$(echo $ids | sed 's/,/\&id=/g')
fi

url="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?"
url=$url"dbfrom=$dbfrom&db=$dbto&id=$ids&retmax=$retmax"

wget -O /dev/stdout $url 2> /dev/null
