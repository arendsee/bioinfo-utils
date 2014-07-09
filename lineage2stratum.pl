#!/usr/bin/env perl

use warnings;
use strict;

my $focal_species = shift;
die "Please provide a focal species" if not $focal_species;
my @flin = @{&get_lineage($focal_species)};

while(<>){
    next unless /\S/;
    if(/^NA/){
        print "NA\tNA\n";
        next;
    }
    my @olin = @{&get_lineage($_)};
    my $stratum = 0;
    foreach (0..($#flin)){
        if($_ > $#olin or $_ > $#flin){
            $stratum++;
            last;
        }
        if($olin[$_] eq $flin[$_]){
            $stratum++;
        }
    }
    print "$stratum\t$flin[$stratum-1]\n";
}

sub get_lineage {
    my $in = shift;
    $in =~ s/^\s+|\s+$//g;
    if(not $in =~ /;/){
        if($in =~ /^[A-Z]/){
            $in = `echo $in | sciname2taxid`;
            chomp $in;
        }
        if($in =~ /^\d+$/){
            $in = `echo $in | taxid2lineage`;  
        }
    }

    $in =~ s/^\s+|\s+$//g;
    $in =~ s/;\s/;/g;
    $in =~ s/\s/_/g;

    my @lin = split(';', $in);
    return(\@lin)
}

=head1 NAME

B<lineage2stratum> - Calculates phylostratum given taxon lineages

=head1 SYNOPSIS

[lineages] | lineage2stratum> [focal species]

=head1 DESCRIPTION

This script works exclusively as a filter. The out species are piped in and compared to the focal species (the single argument).

=head1 INPUT

The out species input is a list of lineages (semicolon delimited, NCBI taxonomy standard), taxon ids, or species names. Likewise for the focal species.

=head1 EXAMPLES

 # This will retrieve the lineage for Mus_mus from entrez
 # This requires sciname2taxid and taxid2lineage be in the path
 $ cat lineages.txt | lineage2stratum Mus_mus
