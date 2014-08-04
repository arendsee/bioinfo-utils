#!/bin/bash

retmax=20
while getopts "d:t:r:" opt; do
    case $opt in
        d)
            db=$OPTARG
            if [[ "$db" =~ ' ' ]];then
                echo "database must be a single word" > /dev/stderr
                exit 1
            fi
            ;;
        t)
            eterm=$(echo $OPTARG | tr ' ' '+') ;;
        r)
            retmax=$OPTARG
            if [[ $retmax =~ '^[0-9]' ]]; then
                echo "retmax must be an integer" > /dev/stderr
                exit 1
            fi ;;
    esac
done

url="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?"
url=$url"db=$db&term=$eterm&retmax=$retmax"

wget -O /dev/stdout $url 2> /dev/null |
    xmlstarlet sel -t -m '/eSearchResult/IdList' -v 'Id' -n |
    sed '/^$/d'
