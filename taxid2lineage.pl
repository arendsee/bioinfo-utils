#!/usr/bin/perl

use strict;
use warnings;

my @in = @ARGV;

if(scalar @in == 0){
    @in = <STDIN>;

my $taxids = join ',', @in;
$taxids =~ s/\s//g;

my $base='http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
my @data = `wget -O - "$base/efetch.fcgi?db=taxonomy&id=$taxids" 2> /dev/null |
            xmlstarlet sel -t -m '/TaxaSet/Taxon' -v 'TaxId' -o "\t" -v 'Lineage' -n -b`;

my %lin = ();
foreach (@data){
    next if not /\S/;
    my($taxid, $lineage) = split("\t", $_);
    $lineage =~ s/;\s/;/g;
    $lineage =~ tr/ /_/;
    $lin{$taxid} = $lineage;
}

print exists $lin{$_} ? $lin{$_} : "NA\n" foreach (split ",", $taxids);
