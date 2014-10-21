#!/usr/bin/env perl

use Math::SigFigs qw(:all);

my $for = shift;
$for = $for ? $for : '';
my $aft = shift;
$aft = $aft ? $aft : '';

while(<>){
    $_ =~ s/$for(\d+\.?\d*)$aft/$for . FormatSigFigs($1, 3) . $aft/ge; 
    print $_;
}
