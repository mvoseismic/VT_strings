% Gives info from string event lists.
%
% Version 1.0
% R.C. Stewart, 4-Apr-2022

clear;
setup = setupGlobals();

% Read VT string spreadsheet
vtStrings = read_string_spreadsheet(setup);

% Only use wanted lines
%idWanted1 = contains( string( vtStrings.What ), 'string' );
%idWanted2 = string( vtStrings.Id ) ~= "";
%idWanted = idWanted1 & idWanted2;
%stringId = stringId( idWanted );
vtStrings = get_string_subset( vtStrings, 'VT string' );
stringId = string( vtStrings.Id );

% Directories
dirEventLists = '../data/event_lists';

nstrings = length( stringId );
stringDuration = NaN( nstrings, 1 );
stringMaxGapPercent = NaN( nstrings, 1 );
stringMaxGap = NaN( nstrings, 1 );
stringEventRate = NaN( nstrings, 1 );

for istring = 1:nstrings

    fileEventList = fullfile( dirEventLists, strcat( stringId(istring), '.txt' ) );
%    EVS = readtable( fileEventList, 'Format','%f %f %f %f %f %f %s' );
    EVS = readtable( fileEventList, 'NumHeaderLines', 0 );
    evDatim = datenum(EVS.Var1,EVS.Var2,EVS.Var3,EVS.Var4,EVS.Var5,EVS.Var6);
    evTime = evDatim - evDatim(1);
    evTime = evTime * 24 * 60;

    nEvents = length( evDatim );
    durMinutes = evTime(end) - evTime(1);
    stringDuration(istring) = durMinutes;
    maxGapMinutes = max( diff( evTime ) );
    stringMaxGap(istring) = maxGapMinutes;
    maxGapPercent = round( 100 * maxGapMinutes/durMinutes );
    stringMaxGapPercent(istring) = maxGapPercent;
    eventRate = nEvents / durMinutes;
    stringEventRate(istring) = eventRate;

    if maxGapPercent > 85
        tooMuch = '*';
    else
        tooMuch = ' ';
    end
    
    fprintf( "%s %3d %6.2f %6.2f %6.2f %3d%s\n", ...
        stringId(istring), nEvents, durMinutes, eventRate, ...
        maxGapMinutes, maxGapPercent, tooMuch );

end

stringMaxGapPercentSubset = stringMaxGapPercent( stringMaxGap <= 50.0 );

figure;

subplot(2,1,1);
edges = 0:2:130;
histogram( stringMaxGap, edges );
title( 'Time in minutes' );
xlabel( 'Maximum gap (minutes)' );
ylabel( 'N' );

subplot(2,1,2);
edges = 0:2:100;
histogram( stringMaxGapPercent, edges );
title( 'Percentage of string length' );
xlabel( 'Maximum gap (percent)' );
ylabel( 'N' );
hold on;
histogram( stringMaxGapPercentSubset, edges );

plotOverTitle( 'Histograms of maximum gap in each string' );
