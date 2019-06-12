#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)
fna = Biostrings::readDNAStringSet(args[1])
faa = Biostrings::translate(fna, if.fuzzy.codon="solve")
Biostrings::writeXStringSet(faa, filepath="/dev/stdout")
