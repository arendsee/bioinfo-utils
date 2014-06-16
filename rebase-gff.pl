#!/usr/bin/perl

use strict;
use warnings;

my $s=0;

while(<>){
    chomp $_;
    my @F = split("\t", $_);
    if($. == 1){
        $s=$F[3]-1;
    }
    $F[3] -= $s;
    $F[4] -= $s;
    print join("\t", @F), "\n";
}

=pod

=head1 NAME

rebase-gff.pl

=head1 SYNOPSIS

 <gff stream> | rebase-gff.pl | <gff rebased>

=head1 DESCRIPTION

This filter reads from a gff file and sets the first start location to 1.

=head1 EXAMPLE

 $ cat myfile.gff3
 Chr3    .    gene   12349047    12349832    .    +    .    .
 Chr3    .    CDS    12349461    12349478    .    +    .    .
 Chr3    .    CDS    12349565    12349726    .    +    .    .
 $ cat myfile.gff3 | rebase-gff.pl
 Chr3	.	gene	1	786	.	+	.	.
 Chr3	.	CDS	415	432	.	+	.	.
 Chr3	.	CDS	519	680	.	+	.	.

=cut
