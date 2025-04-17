#!/usr/bin/perl
#
# Check all files
# R.C. Stewart, 24/2/2022

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

# Get mseed files
my $dirMseed = '/home/seisan/projects/Seismicity/VT_strings/data/mseed_files';
opendir( EFD, $dirMseed ) or die "Can't open directory $dirMseed: $!";
my @mseedFiles = grep{ /\.mseed$/ } readdir( EFD );
closedir( EFD );
chomp @mseedFiles;

# Get polarity files
my $dirPolarity = '/home/seisan/projects/Seismicity/VT_strings/data/polarities';
opendir( EFD, $dirPolarity ) or die "Can't open directory $dirPolarity: $!";
my @polFiles = grep{ /\.txt$/ } readdir( EFD );
closedir( EFD );
chomp @polFiles;

# Get sac files
my $dirSac = '/home/seisan/projects/Seismicity/VT_strings/data/sac_files';
opendir( EFD, $dirSac ) or die "Can't open directory $dirSac: $!";
my @sacFiles = grep{ /\.SACZ$/ } readdir( EFD );
closedir( EFD );
chomp @sacFiles;

# Get all plotfiles
my $dirPlots = '/home/seisan/projects/Seismicity/VT_strings/data/all_plots';
opendir( EFD, $dirPlots ) or die "Can't open directory $dirPlots: $!";
my @plotFiles = grep{ /\.(gif|png)$/ } readdir( EFD );
closedir( EFD );
chomp @plotFiles;

# Get all cumEnvDetrend data files
my $dirCED = '/home/seisan/projects/Seismicity/VT_strings/data/cumEnvDetrend';
opendir( EFD, $dirCED ) or die "Can't open directory $dirPlots: $!";
my @cedFiles = grep{ /\.mat$/ } readdir( EFD );
closedir( EFD );
chomp @cedFiles;

# Process each event list file
foreach my $eventListFile (sort @eventListFiles) {

    my $nHeli = 0;
    my $nMseed = 0;
    my $nPol = 0;
    my $nSac = 0;
    my $nPlot = 0;
    my $nCed = 0;
    my $nCedp = 0;

	# Get ID for event
	my ($eventId,$ext) = split /\./, $eventListFile;
    my $eventIdStart = substr( $eventId, 0, 8 );

    foreach my $heliFile (@heliFiles) {
        if( $heliFile =~ /^$eventId/ ) {
            $nHeli++;
        }
    }
    foreach my $mseedFile (@mseedFiles) {
        if( $mseedFile =~ /^$eventId/ ) {
            $nMseed++;
        }
    }
    foreach my $polFile (@polFiles) {
        if( $polFile =~ /^$eventId/ ) {
            $nPol++;
        }
    }
    foreach my $sacFile (@sacFiles) {
        if( $sacFile =~ /^$eventId/ ) {
            $nSac++;
        }
    }
    foreach my $plotFile (@plotFiles) {
        if( $plotFile =~ /^$eventId/ ) {
            $nPlot++;
        }
    }
    foreach my $cedFile (@cedFiles) {
        if( $cedFile =~ /^$eventId/ ) {
            $nCed++;
        }
    }

    # Get seisan and msd files
    my $nSeisan = 0;
    my $nMsd = 0;
    my $dirSeisan = join( '/', '/home/seisan/projects/Seismicity/VT_strings/data/seisan_files', $eventId );
    if( -e $dirSeisan ) {
        opendir( EFD, $dirSeisan ) or die "Can't open directory $dirSeisan: $!";
        my @seisanFiles = grep{ /[0-9]$/ } readdir( EFD );
        closedir( EFD );
        chomp @seisanFiles;
        $nSeisan = scalar @seisanFiles;
        opendir( EFD, $dirSeisan ) or die "Can't open directory $dirSeisan: $!";
        @seisanFiles = grep{ /\.msd$/ } readdir( EFD );
        closedir( EFD );
        chomp @seisanFiles;
        $nMsd = scalar @seisanFiles;
    }


	printf "%13s  %2d helis  %2d plots  %2d mseed  %2d sac  %2d seisan  %2d msd  %2d polarity  %2d cedmat  %2d cedplots\n", $eventId, $nHeli, $nPlot, $nMseed, $nSac, $nSeisan, $nMsd, $nPol, $nCed, $nCedp;

}

