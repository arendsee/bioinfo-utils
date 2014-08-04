#!/bin/bash

sterms= retmax=10

while getopts "t:r:" opt; do
    case $opt in
        t)
            sterms=$OPTARG ;;
        r)
            retmax=$OPTARG
            if [[ $retmax =~ '^[0-9]' ]]; then
                echo "retmax must be an integer" > /dev/stderr
                exit 1
            fi ;;
    esac 
done

entrez-search -d pubmed -t $sterms -r $retmax |
    entrez-fetch -d pubmed -t xml |
    xmlstarlet sel -t \
                   -m 'PubmedArticleSet/PubmedArticle/MedlineCitation/Article' \
                   -o "Title: " -v 'ArticleTitle' \
                   -n \
                   -o "Year: " -v 'ArticleDate/Year' \
                   -n \
                   -o "Authors: " \
                   -m 'AuthorList/Author' \
                   -v 'LastName' -o ' ' \
                   -b \
                   -n \
                   -o "Abstract: " \
                   -v 'Abstract' \
                   -n
