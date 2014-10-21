#!/usr/bin/env perl

my $min = shift;
$min = $min ? $min : 8;
my $for = shift;
$for = $for ? $for : '';
my $aft = shift;
$aft = $aft ? $aft : '';

while(<>){
    $_ =~ s/$for(\d\.?\d+)$aft/$for . $1 < $min ? 0 : $1 . $aft/ge; 
    print $_, "\n";
}
