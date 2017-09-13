## Bioinformatics utilities

### Parsing

 * `aa-code_3to1.sed` - substitute 3 letter amino acid abbreviations for
   1 letter abbrviations

 * `parse-dssp.sh` - extract secondary structure from PDB files

 * `exonphaser.sh` - add intron-centric phase to a GFF file

 * `rebase-gff.pl` - set all intervals in the GFF as offsets from the first interval 

 * `swap_general.sh` - substitute words (with optional pre- and suffixes) using
   a replacement map

 * `tozero.pl` - replace things nearly equal to zero with zero

### Job submission scripts

 * `autoslurm.sh` - wraps the given command in a slurm file and runs it

### Weird things I don't remember writing
 
 * `edirect-aliases.sh`

### Data

 * `gene-code.sh` - print the gene code as a human readable table

### Phylogenetics and taxonomy

 * `lineage2stratum.pl`
 * `sciname2taxid.sh`
 * `taxid2lineage.pl`
 * `taxid2sciname.pl`

### Blast databases

 The following monstrosities should be murdered and replaced with somethig sane.

 * `stratify-seqs.sh`
 * `phytable.sh`
 * `fasta2blast_taxidmap.sh`

### Statistics, munging, and visualization

 * `round.pl`
 * `rplot.R`
 * `sumtab.R`
 * `summarize-gff.awk`

### Database access

 * `entrez-tools` - filters for accessing entrez data

 * `rentrez-tools` - access entrez tools through an R package. To complete
   this, just wrap some of the functionality described
   [here](https://ropensci.org/tutorials/rentrez_tutorial.html), however, it is
   probably better to just directly use the R package.

 * `retrieve_uniprot_proteomes.py` -  get all proteomes beneath a given common tree node

 * `sra2srr.sh` - given an SRA id, find the related SRR ids

### Bibtex

 * `sync-bib.sh` - recursively extract citations from a tex (or Rnw) file

### Useless scripts

 * `gff2cds.pl` - use bedtools or bioconductor instead
 * `rename_fasta.sh` - use smof instead
