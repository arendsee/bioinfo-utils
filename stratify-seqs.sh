#!/bin/bash
set -u

# This script prepares a series of blast databases containing representatives
# from the Arabidopsis thaliana phylostrata

# REQUIRES:
# - phytable.sh
# - fasta2blast_taxidmap.sh
# These are available from https://github.com/zbwrnz/bioinfo-utils

# INPUT:
# ARG1: focal species (e.g. Arabidopsis_thaliana)
# ARG2: include file (all the way to extension)
# ARG3: supplementary places to look, accepting only species from include file
#       For example, if you have a folder full of organelle genomes but only
#       want to include them if a nuclear genome also exists.
focal_species=$1

include=''
[[ -r $2 ]] || ( echo "Cannot open $2"; exit 1 )
while read line; do
    include=$include' '`ls $line`    
done < $2

allfiles=$include
[[ -r $3 ]] || ( echo "Cannot open $3"; exit 1 )
while read line; do
    allfiles=$allfiles' '`ls $line`    
done < $3

if [[ -z $focal_species ]]; then
    echo "Please provide a focal species" > /dev/stderr
    exit
fi

base=$PWD/"$focal_species"-strata
if [[ -d "$base" ]]; then
    rm -Rf $base
fi
mkdir $base
cd $base

ENTREZ='http://eutils.ncbi.nlm.nih.gov/entrez/eutils/'

geninfo=geninfo.tab
echo -n 'Retrieving lineages from entrez ... '
echo $include | phytable > $geninfo
echo 'done'

flin=(`grep "$focal_species" $geninfo | awk '{print $3}' | tr ';' ' '`)
flin[${#flin[@]}]=`echo "$focal_species" | perl -pe 's/\S+?_//'`

# Make taxon to stratum list, e.g.
# cellular_organisms
# Eukaryota
# Viridiplantae
# ...
# Arabidopsis
echo ${flin[*]} | tr ' ' '\n' > "${focal_species}"-lineage.txt

function make-dir {
    if [ -d $1 ]; then
        rm -Rf $1
    fi
    mkdir $1
}

echo "Symlinking stuff into this directory" > /dev/stderr

# Maps seqids to taxids (needed for making blast databases)
# taxidmap=taxidmap.tab
# echo -n '' > $taxidmap

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
        for f in `ls $allfiles | grep -E "/($reppat)[^/]*$"`; do
            cp -fs $f $older
            # fasta2blast_taxidmap $f >> $taxidmap
            echo `md5sum $f | perl -pe 's|\S*/||'` `smof wc < "$f"` >> $older/MANIFEST
        done
    fi
    older=$newer
done

genus_name=${flin[-2]}
species_name=${flin[-1]}

# Genus
genus=`ls $allfiles | grep -P '\/'$genus_name'_(?!'$species_name')[^\/]*'`
echo -e "\t$genus_name" > /dev/stderr
make-dir $genus_name
for g in $genus; do
    cp -s $g $base/$genus_name/`basename $g`
    echo `md5sum $g | perl -pe 's|\S*/||'` `smof wc < "$g"` >> $genus_name/MANIFEST
done
 
# Species
species=`ls $allfiles | grep -P '\/'${genus_name}_${species_name}'[^\/]*'`
echo -e "\t${genus_name}_${species_name}" > /dev/stderr
species_dir=${genus_name}_${species_name}
make-dir $species_name
for g in $species; do
    cp -s $g $base/$species_name/`basename $g`
    echo `md5sum $g | perl -pe 's|\S*/||'` `smof wc < "$g"` >> $species_name/MANIFEST
done

echo "All Done" > /dev/stderr
