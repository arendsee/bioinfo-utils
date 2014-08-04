#!/bin/bash

dbfrom= dbto= ids= retmax=500 version=1.0.0 idmap=0 parse=0

while getopts "hr:i:t:f:up" opt; do
    case $opt in
        h)
            echo "entrez-link v$version"
            echo "  -r NUM maximum number of records to retrieve (default=500)"
            echo "  -i NUM ids (read from STDIN be default)"
            echo "  -f STR from database name"
            echo "  -t STR to database name"
            echo "  -u     map one fromdb id to n todb ids"
            echo "  -p     parse the xml output"
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
            idmap=1 ;;
        p)
            parse=1 ;;
    esac 
done

if [[ $ids == '' ]]; then
    while read line; do
        ids=$ids",$line"
    done
    ids=$(echo $ids | sed 's/,$//; s/^,//')
fi

if [[ $idmap == 1 ]]; then
    ids=$(echo $ids | sed 's/,/\&id=/g')
fi

url="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?"
url=$url"dbfrom=$dbfrom&db=$dbto&id=$ids&retmax=$retmax"

function _ret {
    wget -O /dev/stdout $url 2> /dev/null
}

if [[ $parse == 1 ]]; then
    if [[ $idmap == 1 ]]; then
        _ret | xmlstarlet sel -t \
                              -m '/eLinkResult/LinkSet' \
                              -v 'IdList/Id' \
                              -o $'\t' \
                              -m 'LinkSetDb/Link' \
                              -v 'Id' \
                              -o ',' \
                              -b \
                              -n |
        awk '{i=$1; gsub(",", "\n"i"\t", $0); print}'
    else
        _ret | xmlstarlet sel -t \
                              -m 'eLinkResult/LinkSet/LinkSetDb/Link' \
                              -v 'Id' \
                              -n
    fi
else
    _ret
fi
