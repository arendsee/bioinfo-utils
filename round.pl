#!/usr/bin/env perl

use Math::SigFigs qw(:all);

my $for = shift;
$for = $for ? qr/$for/ : '';
my $aft = shift;
$aft = $aft ? qr/$aft/ : '';

while(<>){
    $_ =~ s/($for)(\d+\.?\d*)($aft)/$1 . FormatSigFigs($2, 3) . $3/ge; 
    print $_;
}
