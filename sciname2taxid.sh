#! /bin/bash

# Filter to convert scientific names to taxon ids
# One name per line (spaces or underscores to separate words)

scinames=''
if [[ $# -gt 0 ]]; then
    scinames="$@" 
else
    while read line; do
        line=`echo $line | tr ' ' '_'`
        scinames="$scinames $line"
    done
fi

base='http://eutils.ncbi.nlm.nih.gov/entrez/eutils/'
for sciname in $scinames; do
    sciname=`echo $sciname | tr '_' '+'`
    wget -O - "$base/esearch.fcgi?db=taxonomy&term=$sciname" 2> /dev/null |
        xmlstarlet sel -t -v '/eSearchResult/IdList/Id'
    sleep 0.3s # To prevent NCBI from complaining
done
