#!/usr/bin/env perl
#
# Draws one figure for MSS1 per string in spreadsheet
#
# Run using:
# $ ../scripts//excel2webobs.pl | grep '^VT' | ./vtst2getnp1.pl

use strict;
use warnings;


my $outputFile="doit.sh";

open my $fho, '>', $outputFile or die $!;




my $bash = `which bash`;
chomp $bash;
print $fho "#!$bash\n";

while (my $line = <>) {

    chomp $line;

    #print $line, "\n";

    my @chunks = split /\s/, $line;
    my $dateEvent = $chunks[4];
    my $timeEvent = $chunks[5];
    my $durEvent = $chunks[8];
    my $durText = "";

    #    if ($durEvent <= 4) {
    #    $durText = "--dur 5m --pre 1m";
    #} elsif ($durEvent <= 18) {
    #    $durText = "--dur 20m --pre 2m";
    #} elsif ($durEvent <= 54) {
    #    $durText = "--dur 60m --pre 6m";
    #} else {
    #    $durText = "--dur 180m --pre 18m";
    #}

    $durText = "--dur 270m --pre 27m";
    print $fho "getnPlot --hpfilt 5.0 --source mseed --date $dateEvent --time $timeEvent $durText --tag VT_string --kind stringthing --shape xxxxlong\n";
    $durText = "--dur 22m --pre 2m";
    print $fho "getnPlot --hpfilt 5.0 --source mseed --date $dateEvent --time $timeEvent $durText --tag VT_string --kind stringthing --shape xxxxlong\n";

}

close($fho);


system( 'chmod +x doit.sh' );
