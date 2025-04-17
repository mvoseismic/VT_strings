#!/usr/bin/perl

use strict;
no  strict 'subs';
use warnings;
use DateTime;
use DateTime::Duration;
use POSIX qw/floor/;
use File::Slurp;
use Cwd;

# Get event list files
my $dirEventListFiles = '/home/seisan//projects/Seismicity/VT_strings/data/event_lists';
opendir( EFD, $dirEventListFiles ) or die "Can't open directory $dirEventListFiles: $!";
my @eventListFiles = grep{ /\.txt$/ } readdir( EFD );
closedir( EFD );

@eventListFiles = sort @eventListFiles;
my $nEventListFiles = scalar @eventListFiles;


for(my $i = 0; $i <$nEventListFiles; $i++){

    # Get ID for event
    my ($eventId,$ext) = split /\./, $eventListFiles[$i];
    print "$i   $eventId\n";

}

print "String #: ";
my $nString = <STDIN>;
chomp $nString;

# Get ID for event
my ($eventId,$ext) = split /\./, $eventListFiles[$nString];
print "$nString   $eventId\n";

# Read and sort events from event list file
my $eventListFile = join( '/', $dirEventListFiles, $eventListFiles[$nString] );


open( my $fh, '<', $eventListFile ) or die "Can't open file $eventListFile: $!";
my @events = read_file( $eventListFile );
close( $fh );
@events = sort @events;

my $nEvents = scalar @events;
print "Events in file: $nEvents\n";


my $fileDo = '/home/seisan/tmp--DONT_USE/special3Montage/doit.sh';
open FH, '>', $fileDo or die $!;


print FH '#!/usr/bin/bash', "\n";

print FH 'rm *.png', "\n";


foreach my $event (@events ){
    my @chunks = split( ' ', $event );
    my $year = $chunks[0] + 0;
    my $month = $chunks[1] + 0;
    my $day = $chunks[2] + 0;
    my $hour = $chunks[3] + 0;
    my $minute = $chunks[4] + 0;
    my $second = floor( $chunks[5] + 0 );
    my $nanosecond = 1000000000 * ( ($chunks[5]+0) - $second );

    printf FH "getnPlotSpecial3 --datimtag 7 --date %4d-%02d-%02d --time %02d:%02d:%02d.%09d\n", $year, $month, $day, $hour, $minute, $second, $nanosecond;
    printf "getnPlotSpecial3 --datimtag 7 --date %4d-%02d-%02d --time %02d:%02d:%02d.%09d\n", $year, $month, $day, $hour, $minute, $second, $nanosecond;

}

print FH "magick montage *.png -tile x1 -geometry +10+1 $eventId--VT_string-special3montage.png\n";
print "magick montage *.png -tile x1 -geometry +10+1 $eventId--VT_string-special3montage.png\n";
close( FH );
`chmod +x $fileDo`;
