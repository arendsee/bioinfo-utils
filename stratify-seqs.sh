#!/bin/bash

# This script prepares a series of blast databases containing representatives
# from the Arabidopsis thaliana phylostrata

# REQUIRES:
# - phytable
# - fasta2blast_taxid
# These are available from https://github.com/zbwrnz/bioinfo-utils

# INPUT:
# ARG1: focal species (e.g. Arabidopsis_thaliana)
# ARG2: include file (all the way to extension)
# ARG3: supplementary places to look, accepting only species from include file
focal_species=$1

include=''
while read line; do
    include=$include' '`ls $line`    
done < $2

allfiles=$include
while read line; do
    allfiles=$allfiles' '`ls $line`    
done < $3

base=$PWD/$focal_species-strata

if [[ -z $focal_species ]]; then
    echo "Please provide a focal species" > /dev/stderr
    exit
fi

if [[ -d "$base" ]]; then
    rm -Rf $base
fi
mkdir $base
cd $base

ENTREZ='http://eutils.ncbi.nlm.nih.gov/entrez/eutils/'

geninfo=GENINFO
echo -n 'Retrieving lineages from entrez ... '
echo $include | phytable > $geninfo
echo 'done'

flin=(`grep $focal_species $geninfo | awk '{print $3}' | tr ';' ' '`)
flin[${#flin[@]}]=`echo $focal_species | perl -pe 's/\S+?_//'`

# Make taxon to stratum list, e.g.
# cellular_organisms
# Eukaryota
# Viridiplantae
# ...
# Arabidopsis
echo ${flin[*]} | tr ' ' '\n' > ${focal_species}-lineage.txt

function make-dir {
    if [ -d $1 ]; then
        rm -Rf $1
    fi
    mkdir $1
}

echo "Synlinking stuff into this directory and building taxid map" > /dev/stderr

# Maps seqids to taxids (needed for making blast databases)
taxidmap="$PWD/taxidmap.txt"
echo -n '' > $taxidmap

older=${flin[0]}
for newer in ${flin[@]:1}; do
    echo -e "\t$older" > /dev/stderr
    # Those with common older stratum and differing younger
    reps=`grep "$older;" $geninfo | grep -v ";$newer" | awk '{print $2}'`
    # If there is at least one representative at this stratum
    if [ ${#reps} -ne 0 ]; then
        # If a folder already exists by strata name, shred it
        make-dir $older
        # Change reps to pattern, e.g. Zea_mays|Glycine_max
        reppat=`echo $reps | perl -pe 's/[,\s]/\|/g; s/\|$//'`
        # Find files that match this pattern
        for f in `echo $allfiles | grep -E "/($reppat)[^/]*$"`; do
            cp -fs $f $older
            fasta2blast_taxidmap $f >> $taxidmap
        done
    fi
    older=$newer
done

# Genus
genus=`echo $allfiles | grep -P '\/'${flin[-2]}'_(?!'${flin[-1]}')[^\/]*'`
echo -e "\t${flin[-2]}" > /dev/stderr
make-dir ${flin[-2]}
for g in $genus; do cp -s $g ${flin[-2]}/`basename $g`; done

# Species
species=`echo $allfiles | grep -P '\/'${flin[-2]}'_'${flin[-1]}'[^\/]*'`
echo -e "\t${flin[-2]}_${flin[-1]}" > /dev/stderr
make-dir ${flin[-2]}_${flin[-1]}
for g in $species; do cp -s $g ${flin[-2]}_${flin[-1]}/`basename $g`; done

echo "All Done" > /dev/stderr
