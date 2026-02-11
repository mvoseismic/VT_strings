% Create list of large VTs and strings for Karen for 6-monthly report

clear;
setup = setupGlobals();

delete( 'forKaren.txt' );

reFetch( setup );
Hypo = getHypo( setup );

datimNow = now;
thisYear = year(now);
if datimNow >= datenum( thisYear, 10, 1 )
    datimBegDef = datestr( datenum( thisYear, 4, 1 ), 24 );
    datimEndDef = datestr( datenum( thisYear, 10, 1 ), 24 );
else
    datimBegDef = datestr( datenum( thisYear-1, 10, 1 ), 24 );
    datimEndDef = datestr( datenum( thisYear, 4, 1 ), 24 );
end

[datimBeg, datimEnd] = askDates( datimBegDef, datimEndDef );
Hypo2 = hypoSubset( Hypo, 'LV', datimBeg, datimEnd );

minMag = 3.0;

datim = extractfield( Hypo2, 'datim' );
mag = extractfield( Hypo2, 'mag' );
isin_string = extractfield( Hypo2, 'isin_string' );

idWant = mag >= minMag & ~isin_string;
datim = datim( idWant );
mag = mag( idWant );
isin_string = isin_string( idWant );
nev = sum( idWant );

line1 = sprintf( "VTs and VT strings between %s and %s with Seismic", datestr( datimBeg, 24 ), datestr( datimEnd, 24 ) );
line1a = sprintf( "Moment greater than that for a single VT with magnitude %3.1f.", minMag );
line2 = 'Date        Time         max ML    Moment (TNm)    What';


iline = 0;
for iev = 1:nev

    mw = 0.6667 * mag(iev) + 1.15;
    moment = 10 ^ (1.5 * (mw + 6.07));
    moment = moment / 1.0e12;

    line = sprintf( "|%15.6f      |%20s        %3.1f        %8.2f    %s", datim(iev), datestr( datim(iev) ), mag(iev), moment, 'VT' );
    iline = iline +1;
    lines(iline) = line;

end

dataFile = fullfile( setup.DirMegaplotData, 'fetchedVTstringsPlus.mat' );
load( dataFile );
mw = 0.6667 * minMag + 1.15;
momentMin = 10 ^ (1.5 * (mw + 6.07));

datim = vtstrings.DatimBeg;
maxML = vtstrings.MaxML;
moment = vtstrings.Moment;

idWant = moment >= momentMin & datim >= datimBeg & datim <= datimEnd;
datim = datim( idWant );
maxML = maxML( idWant );
moment = moment( idWant );
nstr = sum( idWant );

for istr = 1:nstr

    line = sprintf( "|%15.6f      |%20s        %3.1f        %8.2f    %s", datim(istr), datestr( datim(istr) ), maxML(istr), moment(istr)/1.0e12, 'VT string' );
    iline = iline +1;
    lines(iline) = line;

end

lines = sort( lines );
lines = eraseBetween( lines, '|', '|' );
lines = replace( lines, '|', '' );

diary 'forKaren.txt';
disp( line1 );
disp( line1a );
disp( " " );
disp( line2 );
nlines = length( lines );
for iline = 1:nlines
    disp( lines(iline) );
end
diary off;
