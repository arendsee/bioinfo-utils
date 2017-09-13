#!/bin/bash
# DESCRIPTION
#     Adds exon phases to a gff3 file.
# EXON PHASE CALCULATION
#     According to the GFF spec, the 8th column of a GFF represents phase. This
#     field is required for all CDS entries. It represents the number of bases
#     that must be trimmed off an exon to reach the first complete codon.
# 
#     This script calculates phase in a different, intron-centric manner: 0 when
#     the intron inserts between codons, 1 when after first codon letter, and 2
#     when after 2nd codon letter.
#
#     GFF spec: https://github.com/The-Sequence-Ontology/Specifications/blob/master/gff3.md
#
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
