#!/usr/bin/env perl

# Examples
# ./tozero.pl <<< "asdf0.0001asdas1.09f"
# ./tozero.pl 0.001 <<< "asdf0.0001asdas1.09f"
# ./tozero.pl 0.001 asdf <<< "asdf0.0001asdas1.09f"
# ./tozero.pl 5 '' f <<< "asdf0.0001asdas1.09f"

my $min = shift;
$min = $min ? $min : 0.001;
my $for = shift;
$for = $for ? qr/$for/ : '';
my $aft = shift;
$aft = $aft ? qr/$aft/ : '';

while(<>){
    $_ =~ s/($for)(\d\.?\d+)($aft)/$1 . ($2 < $min ? 0 : $2) . $3/ge; 
    print $_;
}
