#!/bin/bash

# Arguments:
# -d database name
# -t search terms
# -r maximum number of results to retrieve (default = 500)

db= eterm= retmax=500 version=0.0.1

while getopts "hd:t:r:" opt; do
    case $opt in
        h)
            echo "entrez-search $version"
            echo "-d database name"
            echo "-t search terms"
            echo "-r maximum number of records to retrieve (default=500)"
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
