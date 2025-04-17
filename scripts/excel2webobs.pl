#!/usr/bin/perl
#
# Creates prose suitable for webobs from VT string spreadsheet
# R.C. Stewart, 22/03/2022

use 5.016;
use strict;
use warnings;
use Spreadsheet::Read qw(ReadData);
use DateTime::Format::Excel;
  
my $book_data = ReadData( '/home/seisan/projects/SeismicityDiary/SeismicityDiary.xlsx' );

# Fetching all file content
my @rowsmulti = Spreadsheet::Read::rows($book_data->[1]);
foreach my $m (1 .. scalar @rowsmulti) {
    my $dateExcel = $rowsmulti[$m-1][1];
    my $datimFirst;
    if( $dateExcel > 0 ) {
        my $datetime = DateTime::Format::Excel->parse_datetime( $dateExcel );
        $datimFirst = $datetime->strftime('%Y-%m-%d %H:%M:%S');
    } else {
        $datimFirst = '';
    }
    my $what = $rowsmulti[$m-1][11];
    my $duration = $rowsmulti[$m-1][2] + 0;
    my $nSeisan = $rowsmulti[$m-1][3] + 0;
    my $nLocated = $rowsmulti[$m-1][4] + 0;
    my $nTotal = $rowsmulti[$m-1][6] + 0;
    my $maxMl = $rowsmulti[$m-1][7];
    if( defined $maxMl ) {
        $maxMl = $maxMl + 0;
    } else {
        $maxMl = -999.0;
    }

    if( $what eq 'VT string' ) {
        printf "%s started at %s UTC. Duration %.1f minutes. %d triggered, %d located events. Total of %d events identified from continuous data. Maximum ML %3.1f. \n\n", 
            $what, $datimFirst, $duration, $nSeisan, $nLocated, $nTotal, $maxMl;
    }
}
