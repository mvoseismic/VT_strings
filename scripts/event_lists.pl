#!/usr/bin/perl
#
# Statistics from event files
# R.C. Stewart, 8/12/2021

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

# Process each event list file
foreach my $eventListFile (sort @eventListFiles) {

	# Get ID for event
	my ($eventId,$ext) = split /\./, $eventListFile;
	#print "$eventId\n";

	# Read and sort events from event list file
	$eventListFile = join( '/', $dirEventListFiles, $eventListFile );

	open( my $fh, '<', $eventListFile ) or die "Can't open file $eventListFile: $!";
	my @events = read_file( $eventListFile );
	close( $fh );
	@events = sort @events;
    my $nEvents = scalar( @events );

	# Get time of first event
	my @chunks = split( ' ', $events[0] );
	my $year = $chunks[0] + 0;
	my $month = $chunks[1] + 0;
	my $day = $chunks[2] + 0;
	my $hour = $chunks[3] + 0;
	my $minute = $chunks[4] + 0;
	my $second = floor( $chunks[5] + 0 );
	my $nanosecond = 1000000000 * ( ($chunks[5]+0) - $second );

	my $firstEventTime = DateTime->new( 
			second => $second, 
			minute => $minute, 
			hour => $hour, 
			day => $day, 
			month => $month, 
			year => $year,
			nanosecond => int( $nanosecond ),
			time_zone => 'UTC' );

	# Get time of last event
	@chunks = split( ' ', $events[-1] );
	$year = $chunks[0] + 0;
	$month = $chunks[1] + 0;
	$day = $chunks[2] + 0;
	$hour = $chunks[3] + 0;
	$minute = $chunks[4] + 0;
	$second = floor( $chunks[5] + 0 );
	$nanosecond = 1000000000 * ( ($chunks[5]+0) - $second );

	my $lastEventTime = DateTime->new( 
			second => $second, 
			minute => $minute, 
			hour => $hour, 
			day => $day, 
			month => $month, 
			year => $year,
			nanosecond => int( $nanosecond ),
			time_zone => 'UTC' );


	my $secondsDuration = $lastEventTime->subtract_datetime_absolute($firstEventTime)->in_units('nanoseconds') / 1e9;
	my $minutesDuration = $secondsDuration / 60.0;


	printf "%13s  %16s  %16s  %6.2f  %3d\n",  $eventId, 
			join( ' ', $firstEventTime->ymd, $firstEventTime->hms ),
			join( ' ', $lastEventTime->ymd, $lastEventTime->hms ),
			$minutesDuration, $nEvents;

}

