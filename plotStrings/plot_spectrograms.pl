#!/usr/bin/perl
#
# Create SAC files for string spectrograms
# R.C. Stewart, 23/2/2022

use strict;
no  strict 'subs';
use warnings;
use DateTime;
use DateTime::Duration;
use POSIX qw/floor/;
use File::Slurp;
use Cwd;

# Get event list files
my $dirEventListFiles = '/home/seisan/projects/Seismicity/VT_strings/data/event_lists/0-new';
opendir( EFD, $dirEventListFiles ) or die "Can't open directory $dirEventListFiles: $!";
my @eventListFiles = grep{ /\.txt$/ } readdir( EFD );
closedir( EFD );

open( OUF, '>plot_spectrograms.out' ) or die "Can't open plot_spectrograms.out: $!";

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

    # Get seisan files in tmp
    chdir "tmp";

    my $cmd = join( '', 'cp ../../data/seisan_files/0-new/', $eventId, '/[12]* .' );
    system( $cmd );

    my $firstFileTime;
    # Get datim of first file
    my $firstFile = `ls [12]* | head -1`;
    if( $firstFile ne "" ){
        my @datimFirst = split /[-_]+/, $firstFile;
        my $hour = floor($datimFirst[3]/100);
        my $minute = $datimFirst[3] - $hour*100.0;
        my $day = $datimFirst[2]+0;
        my $month = $datimFirst[1]+0;
        my $year = $datimFirst[0]+0;
	    $firstFileTime = DateTime->new( 
			second => 0, 
			minute => $minute, 
			hour => $hour, 
			day => $day, 
			month => $month, 
			year => $year,
			nanosecond => 0,
			time_zone => 'UTC' );
    }

    # work out cut numbers
    my $minutesPreString = 10;
    my $minutesOfString = 210;
    if( $minutesDuration <= 10 ) {
        $minutesOfString = 10;
    } elsif( $minutesDuration <= 60 ) {
        $minutesOfString = 60;
    }
    my $secondsLead= $firstEventTime->subtract_datetime_absolute($firstFileTime)->in_units('nanoseconds') / 1e9;
    my $cutOne = $secondsLead - (60.0 * $minutesPreString);
    my $cutTwo = (2.0 * $secondsLead) + (60.0 * $minutesOfString);
    if( $minutesDuration <= 10 ) {
        $cutOne = $secondsLead - 60*1;
        $cutTwo = $secondsLead + 60*($minutesOfString+1);
    } elsif( $minutesDuration <= 60 ) {
        $cutOne = $secondsLead - 60*5;
        $cutTwo = $secondsLead + 60*($minutesOfString+5);
    }
	printf OUF "%13s  %16s  %16s  %16s  %6.2f  %6.1f  %6.1f\n",  $eventId, 
			join( ' ', $firstFileTime->ymd, $firstFileTime->hms ),
			join( ' ', $firstEventTime->ymd, $firstEventTime->hms ),
			join( ' ', $lastEventTime->ymd, $lastEventTime->hms ),
			$minutesDuration, 
            $cutOne, $cutTwo;

    $cmd = 'dirf [12]*';
    system( $cmd );

    $cmd = 'wavetool -wav_files filenr.lis -format SAC';
    system( $cmd );

    $cmd = 'find . ! -name "*MSS1*" ! -name "*MBLY*" ! -name "*MBLG*" ! -name "*MBFR*" ! -name "*MBBY*" -type f -delete';
    system( $cmd );

    # Loop round stations to process
    my @stations = qw( MSS1__SH_Z MBLY__BH_Z MBLY__HH_Z MBLG__BH_Z MBLG__HH_Z MBFR__BH_Z MBBY__BH_Z );
    for my $sta (@stations) {

	    opendir( SACFILES, '.' ) or die "Can't open '.': $!";
        my @sacFiles = grep{ /$sta/ } readdir( SACFILES );
	    closedir( SACFILES );
    
        if( scalar @sacFiles > 0 ) {

            open(SAC, "| sac ") or die "Error opening sac";
            print SAC "qdp off\n";
            print SAC "merge \*$sta\*SAC\n";
            print SAC "rmean\n";
            print SAC "highpass butter corner 1.0 npoles 4\n";
            print SAC "spectrogram cbar off ymax 50.0 sqrt\n";
            print SAC "saveimg sgram1.xpm\n";
            print SAC "quit\n";
            close(SAC);
            open(SAC, "| sac ") or die "Error opening sac";
            print SAC "merge \*$sta\*SAC\n";
            print SAC "rmean\n";
            print SAC "highpass butter corner 1.0 npoles 4\n";
            print SAC "cutim $cutOne $cutTwo\n";
            print SAC "write $eventId\.$sta\.SACZ\n";
            print SAC "spectrogram cbar off ymax 50.0 sqrt\n";
            print SAC "saveimg sgram2.xpm\n";
            print SAC "quit\n";
            close(SAC);

            $cmd = join( ' ', 'convert sgram1.xpm', join( '--', $eventId, join( '-', 'VT_string', $sta, '1Hz_hp-sgram_sqrt-1.png' ) ) );
            system( $cmd );
            $cmd = join( ' ', 'convert sgram2.xpm', join( '--', $eventId, join( '-', 'VT_string', $sta, '1Hz_hp-sgram_sqrt-2.png' ) ) );
            system( $cmd );

            `mv *.png ..`;
            `rm *.xpm`;

        }
    }

    open(SAC, "| sac ") or die "Error opening sac";
    print SAC "qdp off\n";
    print SAC "cut $cutOne $cutTwo\n";
    print SAC "read *SACZ\n";
    print SAC "rmean\n";
    print SAC "highpass butter corner 1.0 npoles 4\n";
    print SAC "p1\n";
    print SAC "saveimg wave1.xpm\n";
    print SAC "quit\n";
    close(SAC);
    
    $cmd = join( ' ', 'convert wave1.xpm', join( '--', $eventId, 'VT_string-1Hz_hp-waves.png'  ) );
    system( $cmd );
    `mv *.png ..`;
    `rm *.xpm`;

    `cp *SACZ ../../data/sac_files`;

    `rm *SAC`;
    `rm *SACZ`;
    chdir ".."; 

    #last;
    
}
close( OUF );
