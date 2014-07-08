#!/usr/bin/env perl

use warnings;
use strict;

my @flin = @{&get_lineage(shift)};

while(<>){
    next unless /\S/;
    my @olin = @{&get_lineage($_)};
    my $stratum = 0;
    foreach (0..($#flin)){
        if($olin[$stratum] eq $flin[$stratum]){
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

    die "Couldn't get focal lineage" if not $in =~ /;/;

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
 $ cat lineages.txt | lineage2stratum Mus_mus
