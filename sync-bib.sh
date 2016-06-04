#!/usr/bin/env bash
set -u

usage (){
cat << EOF
USAGE: sync-bib.sh -d /path/to/bibtex/file > refs.bib

Recursively extract citations from tex or Rnw files and extract bibtex entries
from a local bibtex database. Missing entries DO NOT generate an error. Outputs
to STDOUT.

Requires: bibtool, parallel

Arguments:
  -d bibtex file (defaults to my own personal file, sorry)
EOF
exit 0
}

bibdb=~/Dropbox/notes/all-refs.bib
while getopts "hd:" opt; do
    case $opt in
        h)
            usage ;;
        d) 
            bibdb=$OPTARG ;;
    esac 
done

[[ -d $bibdb ]] || echo -e "Bibtex file $bibdb not found\n" && usage

find . -name '*.tex' -o -name '*.Rnw' |
    parallel 'tr -d " \t\n" < {}' |
    grep -Po '\\cite\{.*?\}' |
    sed -r 's/\\cite\{(.*)\}/\1/' |
    tr ',' '\n' |
    sort -u |
    parallel "bibtool -i $bibdb -X {}"
