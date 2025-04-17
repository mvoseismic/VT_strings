#!/usr/bin/perl
#
# Check helicorder files
# R.C. Stewart, 3/1/2022

use strict;
no  strict 'subs';
use warnings;
use DateTime;
use DateTime::Duration;
use POSIX qw/floor/;
use File::Slurp;
use Cwd;

# Get event list files
my $dirEventListFiles = '/home/seisan/projects/Seismicity/VT_strings/data/event_lists';
opendir( EFD, $dirEventListFiles ) or die "Can't open directory $dirEventListFiles: $!";
my @eventListFiles = grep{ /\.txt$/ } readdir( EFD );
closedir( EFD );

# Get heli plot files
my $dirHeli = '/home/seisan/projects/Seismicity/VT_strings/data/heli_plots';
opendir( EFD, $dirHeli ) or die "Can't open directory $dirHeli: $!";
my @heliFiles = grep{ /\.(gif|png)$/ } readdir( EFD );
closedir( EFD );
chomp @heliFiles;

# Process each event list file
foreach my $eventListFile (sort @eventListFiles) {

    my $nHeliGood = 0;

	# Get ID for event
	my ($eventId,$ext) = split /\./, $eventListFile;
    my $eventIdStart = substr( $eventId, 0, 8 );

    foreach my $heliFile (@heliFiles) {
        if( $heliFile =~ /^$eventId/ ) {
            $nHeliGood++;
        }
    }

	printf "%13s %8s %2d\n", $eventId, $eventIdStart, $nHeliGood;

}

