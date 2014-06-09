#! /usr/bin/perl

# Filter to convert scientific names to taxon ids
# One name per line (spaces or underscores to separate words)

use strict;
use warnings;

my $base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
while(<>){
     my $sciname = $_;
     $sciname =~ tr/_/ /;
     my $taxid = `wget -O - -o /dev/null "$base/esearch.fcgi?db=taxonomy&term=$sciname"`;
     $taxid =~ s/[^\S]//g;
     $taxid =~ s/.*?<Id>(\d+)<\/Id>.*/$1\n/;
     select undef,undef,undef,0.3;
     print $taxid;
}
