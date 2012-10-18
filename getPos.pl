#!/usr/bin/env perl

use strict;
use warnings;

use IO::File;

my $raw_file = $ARGV[0];

unless (-e $raw_file) {
    die "Could not locate raw file: $raw_file";
}

my $fh;
if ($raw_file =~ m/zip$/) {
    $fh = IO::File->new("zcat $ARGV[0]|");
} else {
    $fh = IO::File->new($ARGV[0]);
}

my $ref_path = $ARGV[1];


while (my $line = $fh->getline) {
    chomp $line;
    if (substr($line, 0, 1) eq '#') {
        next;
    }
    my ($rsid, $chr, $pos, $alleles) = split /\t/, $line;
    #change mitochondrial MT to M
    $chr = ($chr eq "MT") ? "chrM" : "chr$chr";
    my $faidx_string = "samtools faidx $ref_path $chr:$pos-$pos";

    my @result = `$faidx_string`;

    my $ref = $result[1];
    chomp $ref;
    print "$chr\t$pos\t$rsid\t$ref\n";
}
$fh->close;
