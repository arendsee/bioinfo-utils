#!/bin/bash
# DESCRIPTION
#     Adds exon phases to a gff3 file.
# EXON PHASE CALCULATION
#     This script calculates phase the right way, not the way specified in the
#     GFF specifications. The phase corresponds to the intron insertion
#     point (0 when between codons, 1 when after first codon
#     letter, 2 when after 2nd codon letter).
# INPUT NOTE
#     This script assumes CDSs are in biological order (i.e. their starting
#     positions will be in reverse order when they are on the minus strand).
# EXAMPLE
#     $ exonphaser.sh < my.gff3 > phased.gff3

awk '
    BEGIN{OFS="\t"}
    $3 == "mRNA" {len = 0}
    $3 == "CDS" {$8 = len % 3; len += $5 - $4 + 1}
    $3 != "CDS" {$8 = "."}
    {print}
'
