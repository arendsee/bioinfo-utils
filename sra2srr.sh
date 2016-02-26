#!/bin/bash

# =============================================================================
# EXAMPLE:
# $ sra2srr SRA169702
# SRR1363422
# SRR1363423
# SRR1363420
# SRR1363421
# SRR1363419
# SRR1363418
# SRR1363417
# SRR1363416
# SRR1363415
# SRR1363414
# SRR1363413
# SRR1363412
#
# NOTE: This also maps ERA to ERR
#
# DEPENDENCIES:
#  * xmlstarlet
#  * wget
#
# AUTHOR:
#  Zebulun Arendsee (zbwrnz@gmail.com; github.com/zbwrnz)
# =============================================================================

set -u

eusrc() {
    db=$1
    term=$2
    retmax=${3-500}
    src_url="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
    url="$src_url?db=$db&term=$term&retmax=$retmax&usehistory=y"
    out=$(wget -qO /dev/stdout $url | 
          xmlstarlet sel --template      \
            --match '/eSearchResult'     \
                --value-of 'WebEnv' --nl \
                --value-of 'QueryKey'    \
            --break 2> /dev/null)
    webenv=$(echo $out | awk '{print $1}')
    query_key=$(echo $out | awk '{print $2}')
    printf "db=%s&WebEnv=%s 1 %s %s" $db $webenv $query_key $retmax
}

eufet() {
    read opts first_key nkeys retmax
    base="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
    for k in `seq $first_key $nkeys`; do
        loopopts="retmax=$retmax&query_key=$k"
        cmd="$base?$opts&$loopopts"
        wget -qO /dev/stdout "$cmd"
    done
}

for sra in $@
do
    eusrc sra $sra | eufet |
        xmlstarlet sel --template \
            --match 'EXPERIMENT_PACKAGE_SET/EXPERIMENT_PACKAGE/RUN_SET/RUN/IDENTIFIERS' \
                --output "${sra}" --output $'\t' \
                --value-of 'PRIMARY_ID' --nl \
            --break
done
