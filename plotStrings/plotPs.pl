#!/usr/bin/perl
#
# Create plots of P waves for all events in a string
# R.C. Stewart, 18/1/2023

use strict;
no  strict 'subs';
use warnings;
use DateTime;
use DateTime::Duration;
use POSIX qw/floor strftime round/;
use File::Slurp;
use Cwd;

# Get event list files
my $dirEventListFiles = '/home/seisan/projects/Seismicity/VT_strings/data/event_lists/0-new';
opendir( EFD, $dirEventListFiles ) or die "Can't open directory $dirEventListFiles: $!";
my @eventListFiles = grep{ /\.txt$/ } readdir( EFD );
closedir( EFD );

# Process each event list file
foreach my $eventListFile (sort @eventListFiles) {

	# Get ID for event
	my ($eventId,$ext) = split /\./, $eventListFile;
	print "$eventId\n";

	# Read and sort events from event list file
	$eventListFile = join( '/', $dirEventListFiles, $eventListFile );

	open( my $fh, '<', $eventListFile ) or die "Can't open file $eventListFile: $!";
	my @events = read_file( $eventListFile );
	close( $fh );
	@events = sort @events;

    # Process each event
    foreach my $event (sort @events) {
	    my @chunks = split( ' ', $event );
	    my $year = $chunks[0] + 0;
	    my $month = $chunks[1] + 0;
	    my $day = $chunks[2] + 0;
	    my $hour = $chunks[3] + 0;
	    my $minute = $chunks[4] + 0;
	    my $second = floor( $chunks[5] + 0 );
	    my $nanosecond = 1000000000 * ( ($chunks[5]+0) - $second );

	    my $eventDatim = DateTime->new( 
			    second => $second, 
			    minute => $minute, 
			    hour => $hour, 
			    day => $day, 
			    month => $month, 
			    year => $year,
			    nanosecond => int( $nanosecond ),
			    time_zone => 'UTC' );

        my $eventDate = $eventDatim->strftime('%F');
        my $eventTime = join( '.', $eventDatim->strftime('%T'), sprintf('%1d',round($nanosecond/100000000)) );

        my $cmd = join( ' ', '/home/seisan/bin/getnPlot.py --date', $eventDate, '--time', $eventTime, '--pre 1 --dur 2 --shape thin --tag VT_string_event' );
        print "\n", $cmd, "\n\n";
        system( $cmd );

        $cmd = join( ' ', '/home/seisan/bin/getnPlot.py --source mseed --date', $eventDate, '--time', $eventTime, '--pre 2 --dur 8 --shape thin --tag VT_string_event' );
        print "\n", $cmd, "\n\n";
        ##system( $cmd );

    }

    my $nevents = scalar( @events );
    my $rows = floor( $nevents/10 ) + 1;
    my $tile = sprintf( '10x%d', $rows );

    #my $cmd = join( ' ', 'montage *2s1.png -tile', $tile, '-geometry +1+1', join( '', $eventId, '--VT_string-P_arrivals-2s.png' ) ); 
    my $cmd = join( ' ', 'magick montage *2s1.png -tile', $tile, '-geometry +1+1', join( '', $eventId, '--VT_string-P_arrivals-2s.png' ) ); 
    print "\n", $cmd, "\n\n";
    system( $cmd );

    $cmd = join( ' ', 'magick montage *8s2.png -tile', $tile, '-geometry +1+1', join( '', $eventId, '--VT_string-P_arrivals-8s.png' ) ); 
    #print "\n", $cmd, "\n\n";
    #system( $cmd );

    `mv *.png /home/seisan/projects/Seismicity/VT_strings/data/polarities/plots/`;

}


