#!/bin/bash

# INPUT - list of taxid ids
# OUTPUT - list of lineages in same order

taxids=''
if [[ $# -gt 0 ]]; then
    taxids="$@" 
else
    while read line; do
        taxids="$taxids $line"
    done
fi

taxids=`echo $taxids | perl -pe 's/^\s*//' | tr ' ' ','`

base='http://eutils.ncbi.nlm.nih.gov/entrez/eutils/'
wget -O - "$base/efetch.fcgi?db=taxonomy&id=$taxids" 2> /dev/null |
    xmlstarlet sel -t -v '/TaxaSet/Taxon/Lineage' -n |
    perl -pe 's/;\s/;/g; tr/ /_/'
