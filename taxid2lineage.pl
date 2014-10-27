#!/usr/bin/perl

use strict;
use warnings;

my @in = @ARGV;

if(scalar @in == 0){
    @in = <STDIN>;
}

my $taxids = join ',', @in;
$taxids =~ s/\s//g;

my $base='http://eutils.ncbi.nlm.nih.gov/entrez/eutils';


my $del = ',,,';
my @data = `wget -qO - "$base/efetch.fcgi?db=taxonomy&id=$taxids" |
    xmlstarlet sel -t -m 'TaxaSet/Taxon' -v 'TaxId' -o $del -v 'Lineage' -o $del -v 'ScientificName' -n`;

my %lin = ();
foreach (@data){
    next if not /\S/;
    my($taxid, $lineage, $sciname) = split($del, $_);
    $lineage = "$lineage; $sciname";
    $lineage =~ s/;\s/;/g;
    $lineage =~ tr/ /_/;
    $lin{$taxid} = $lineage;
}

print exists $lin{$_} ? $lin{$_} : "NA\n" foreach (split ",", $taxids);
