#!/bin/bash

# INPUT
#  list of filenames (<Genus>_<species>*)
#  read from STDIN
# OUTPUT
#  white space delimited file with columns: (taxid, sciname, lineage)
#  written to STDOUT
# USAGE
#  ls <genome files> | phytable > phyinfo.txt
# NOTE
#  Errors are silent. If the species associated with a file cannot be found,
#  the program will not complain. You will have to check yourself.
# REQUIRES
#  starlet

# Get scientific names for each genome from the filenames
scinames=''
while read line; do
    for f in $line; do
        scinames="$scinames "`basename $f | \
            grep -E '[A-Z][a-z]+_[a-z]+' | \
            perl -pe 's/^([A-Z][a-z]+_[a-z]+).*/\1/' | \
            tr '_' '+'`
    done
done

scinames=`echo $scinames | tr ' ' '\n' | sort -u | tr '\n' ' '`

# Retrieve the taxon ids for each species from entrez 
ENTREZ='http://eutils.ncbi.nlm.nih.gov/entrez/eutils/'

taxids=''
for sciname in $scinames; do
    taxids="$taxids "`wget -O - \
        "$ENTREZ/esearch.fcgi?db=taxonomy&term=$sciname" 2> /dev/null | \
        xmlstarlet sel -t -m '/eSearchResult/IdList' -v Id -o ','`
    sleep .3s # To avoid getting my IP blocked by NCBI
done

# Remove terminal comma, remove blanks
taxids=`echo $taxids | perl -pe 's/,$//' | perl -pe 's/, ,/,/'`

# Retrieve the phylogenetic lineage of each taxid from entrez
wget -O - "$ENTREZ/efetch.fcgi?db=taxonomy&id=$taxids"  2> /dev/null | \
    xmlstarlet sel \
        -t -m 'TaxaSet/Taxon' \
        -v TaxId -o '|' \
        -v ScientificName -o ',' \
            -m 'OtherNames/Synonym' \
            -v "text()" -o ',' -b \
        -o '|' \
        -v Lineage -n | \
        # Remove spaces in lineage
        perl -pe 's/;\s/;/g' |
        # Substitute underscores spaces in names
        tr ' ' '_' |
        # Change delimiter to tab
        tr '|' '\t' |
        # Remove terminal commas
        perl -pe 's/,(\s)/$1/g'
