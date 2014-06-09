#! /bin/bash

# Filter to convert scientific names to taxon ids
# One name per line (spaces or underscores to separate words)

base='http://eutils.ncbi.nlm.nih.gov/entrez/eutils/'
while read line; do
    sciname=`echo $line | tr '_' '+'`
    wget -O - "$base/esearch.fcgi?db=taxonomy&term=$sciname" 2> /dev/null |
        xmlstarlet sel -t -v '/eSearchResult/IdList/Id'
    sleep 0.3s # To prevent NCBI from complaining
done
