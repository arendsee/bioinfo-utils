#!/usr/bin/perl

# Adapted from Federico Giorgi (https://www.biostars.org/p/46281/)

use strict;
use warnings;
use Bio::Seq;
use Bio::SeqIO;
use Bio::DB::Fasta;

my $fasta_filename = $ARGV[0];
my $gff_filename = $ARGV[1];

### First, index the genome
my $db = Bio::DB::Fasta->new($fasta_filename);

my $outfile_base = $gff_filename;
$outfile_base =~ s/\.gff.?$//;

$| = 1;    # Flush output
my $outfile_cds = Bio::SeqIO->new( -format => 'fasta', -file => ">$outfile_base.cds.fasta" );
my $outfile_pep = Bio::SeqIO->new( -format => 'fasta', -file => ">$outfile_base.pep.fasta" );

### Second, parse the GFF3
my @mRNA;
my $mRNA_name;
my $frame;
my $type;
open GFF, "<$gff_filename" or die $!;
while ( my $line = <GFF> ) {
    chomp $line;
    my @array = split( "\t", $line );
    # Skip if the line is not 9 columns in length, i.e. is not a data row
    next if scalar @array != 9;
    $type = $array[2];
    if ( $type eq 'mRNA') {
        # If there is a mRNA in memory, write it
        if(scalar @mRNA > 0){
            &record_mRNA();
        }
        &initialize_mRNA(@array);
    }
    elsif ( $type eq 'CDS' ) {
        # Add the array: [seqid, start, stop]
        push( @mRNA, [$array[0], $array[3], $array[4]] );
    }
}
close GFF;

sub record_mRNA {
    # Collect CDSs and extract sequence of the previous mRNA
    my $mRNA_seq;
    @mRNA = sort { $a->[1] > $b->[1] } @mRNA;
    foreach my $coord (@mRNA) {
        $mRNA_seq .= $db->seq( $coord->[0], $coord->[1] => $coord->[2] );
    }

    my $output_nucleotide = Bio::Seq->new(
        -seq        => $mRNA_seq,
        -id         => $mRNA_name,
        -display_id => $mRNA_name,
        -alphabet   => 'dna',
    );
    if ($frame eq '-') {
        $output_nucleotide = $output_nucleotide->revcom();
    }
    my $output_protein = $output_nucleotide->translate();
    $outfile_cds->write_seq($output_nucleotide);
    $outfile_pep->write_seq($output_protein);

    @mRNA = (); # Empty the mRNA
}

sub initialize_mRNA {
    my @array = @_;
    my @attrs = split( ";", $array[8] );
    $attrs[0] =~ s/ID=//;
    $mRNA_name = $attrs[0];
    $frame = $array[6];
}
