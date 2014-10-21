#!/usr/bin/env perl

# Examples
# ./tozero.pl <<< "asdf0.0001asdas1.09f"
# ./tozero.pl 0.001 <<< "asdf0.0001asdas1.09f"
# ./tozero.pl 0.001 asdf <<< "asdf0.0001asdas1.09f"
# ./tozero.pl 5 '' f <<< "asdf0.0001asdas1.09f"

my $min = shift;
$min = $min ? $min : 0.001;
my $for = shift;
$for = $for ? $for : '';
my $aft = shift;
$aft = $aft ? $aft : '';

print "$min|$for|$aft|\n";

while(<>){
    $_ =~ s/($for)(\d\.?\d+)($aft)/$1 . ($2 < $min ? 0 : $3) . $aft/ge; 
    print $_, "\n";
}
