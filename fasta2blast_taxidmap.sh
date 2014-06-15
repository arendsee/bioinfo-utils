#!/bin/bash

# INPUT - file names with species name preceding first dot, e.g. Zea_mays.mito.faa
# OUTPUT - a taxid map with following format

filenames=''
if [[ $# -gt 0 ]]; then
    filenames="$@" 
else
    while read line; do
        filenames="$filenames $line"
    done
fi

base='http://eutils.ncbi.nlm.nih.gov/entrez/eutils/'
for f in $filenames; do
    sciname=`basename "$f" | perl -pe 's/([^.]+).*/$1/' | tr '_' '+'`
    taxid=`wget -O - "$base/esearch.fcgi?db=taxonomy&term=$sciname" 2> /dev/null |
        xmlstarlet sel -t -v '/eSearchResult/IdList/Id'`
    sleep 0.3s # To prevent NCBI from complaining
    while read header; do
        echo -e "$header\t$taxid"
    done < <(grep '>' $f) |
        # This may be overly simplistic. It seems that ncbi-blast just grabs
        # the first "word", but I may be wrong.
        perl -pe 's/^>(\S+).*?(\d+)$/$1\t$2/'
done
