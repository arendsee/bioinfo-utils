#!/usr/bin/perl

use warnings;
use strict;

my $base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
my $taxidvar = join (',', <STDIN>);
my @lineage = `wget -O - -o /dev/null "$base/efetch.fcgi?db=taxonomy&id=$taxidvar"`;
foreach (@lineage){
   if(/<Lineage>(.*?)<\/Lineage>/){
        my $lineage = $1;
        $lineage =~ s/;\s+/;/g;
        $lineage =~ s/\s/_/g;
        print "$lineage\n";
   }
}
