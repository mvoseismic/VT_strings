% Read VT strings spreadsheet and info files and gives stats
% 
% RCS 2023-09-15
%

clear;
setup = setupGlobals();

dateLimits = [ datenum( 2014,4,1,0,0,0) ceil( now ) ];

diary vtstringStats.txt;

fprintf( '%s\n\n\n', datestr( now ) );

% Read info from VT_strings spreadsheet
vtStrings = read_string_spreadsheet( setup );
tmp = vtStrings.Id;
id = string( tmp );
tmp = vtStrings.DatimFirst;
datim = datenum( tmp );
duration = vtStrings.Duration;
ntrig = vtStrings.NumSeisan;
nloc = vtStrings.NumLocated;
ntotal = vtStrings.NumTotal;
maxml = vtStrings.MaxMl;
tmp = vtStrings.SurfaceActivity;
surface = char( tmp );
tmp = vtStrings.DatimLast;
datimEnd = datenum( tmp );
tmp = vtStrings.What;
what = string( tmp );
tmp = vtStrings.RepeatingEvents;
repeating = string( tmp );
tmp = vtStrings.Form;
form = string( tmp );
tmp = vtStrings.Purity;
purity = string( tmp );
nStrings = length( datim );

% Get counts of each what
[whatUnique,ia,ic] = unique(what);
whatCounts = accumarray(ic,1);
[whatTemp,I] = sort( upper(whatUnique) );
whatUniqueSorted = whatUnique(I);
whatCountsSorted = whatCounts(I);
nWhatUnique = length( whatUniqueSorted );
idEmpty = strcmp( whatUniqueSorted, "" );
whatUniqueSorted(idEmpty) = "Unclassified";

fprintf( '%-30s   %4d\n', 'Total stringy things', nStrings );
for iwu = 1:nWhatUnique
    fprintf( '%-30s   %4d\n', whatUniqueSorted(iwu), whatCountsSorted(iwu) );
end
fprintf( '\n\n' );



% Stats for VT strings and stuff

formatHeading = '%-40s   %-12s     %-12s     %-12s     %-12s     %-12s\n';
formatBody =    '%-40s  %4d             %4d             %4d             %4d             %4d\n';
formatBody1 =    '%-40s  %4d\n';
formatBodyPercent = '%-40s  %4d (%2d%%)       %4d (%2d%%)       %4d (%2d%%)       %4d (%2d%%)       %4d (%2d%%)\n';
formatBodyPercent1 = '%-40s  %4d (%2d%%)\n';

idVtString = strcmp( what, "VT string" );
nVtString = sum( idVtString );
idMiniVtString = strcmp( what, "mini VT string" );
nMiniVtString = sum( idMiniVtString );
idVtDoublet = strcmp( what, "VT doublet" );
nVtDoublet = sum( idVtDoublet );
idVtTriplet = strcmp( what, "VT triplet" );
nVtTriplet = sum( idVtTriplet );
idVtAll = idVtString | idMiniVtString | idVtDoublet | idVtTriplet;
nVtAll = sum( idVtAll );

ids = [ idVtAll idVtString idMiniVtString idVtDoublet idVtTriplet ];

fprintf( formatHeading, 'VT things', 'All', 'Strings', 'Mini-strings', 'Doublets', 'Triplets' );
fprintf( formatBody, 'number', nVtAll, nVtString, nMiniVtString, nVtDoublet, nVtTriplet );
fprintf( '\n' );


% Associated with surface activity
nSurface = sum( surface(idVtAll) == 'y' );
nSurfaceMaybe = sum( surface(idVtAll) == '?' );
fprintf( formatBodyPercent1, 'Associated with surface activity:', nSurface, round(100*nSurface/nVtAll) );
fprintf( formatBodyPercent1, 'Maybe associated with surface activity:', nSurfaceMaybe, round(100*nSurfaceMaybe/nVtAll) );
fprintf( '\n' );


% Repeating events
for iThing = 1:5
    repeatingEvents = upper(repeating(ids(:,iThing)));
    nTested(iThing) = sum( ~strcmp( repeatingEvents, '' ) );
    nRepeating(iThing) = sum( strcmp( repeatingEvents, 'Y' ) );
    nSomeRepeating(iThing) = sum( strcmp( repeatingEvents, 'S' ) );
end
fprintf( formatBody, 'Tested for repeating events:', nTested );
nRepeatingPercent = round( 100 * ( nRepeating ./ nTested ) );
fprintf( formatBodyPercent, 'Have repeating events:', ...
    nRepeating(1), nRepeatingPercent(1), ...
    nRepeating(2), nRepeatingPercent(2), ...
    nRepeating(3), nRepeatingPercent(3), ...
    nRepeating(4), nRepeatingPercent(4), ...
    nRepeating(5), nRepeatingPercent(5) );
nSomeRepeatingPercent = round( 100 * ( nSomeRepeating ./ nTested ) );
fprintf( formatBodyPercent, 'Have some repeating events:', ...
    nSomeRepeating(1), nSomeRepeatingPercent(1), ...
    nSomeRepeating(2), nSomeRepeatingPercent(2), ...
    nSomeRepeating(3), nSomeRepeatingPercent(3), ...
    nSomeRepeating(4), nSomeRepeatingPercent(4), ...
    nSomeRepeating(5), nSomeRepeatingPercent(5) );    
fprintf( '\n' );


% Form
for iThing = 1:5
    formEvents = upper(form(ids(:,iThing)));
    repeatingEvents = upper(repeating(ids(:,iThing)));
    nTested(iThing) = sum( ~strcmp( formEvents, '' ) );
    nBeg(iThing) = sum( strcmp( formEvents, 'B' ) );
    nEnd(iThing) = sum( strcmp( formEvents, 'E' ) );
    nBegRepeat(iThing) = sum( and( strcmp( formEvents, 'B'), strcmp( repeatingEvents, 'Y' ) ) );
end
fprintf( formatBody, 'Tested for form:', nTested );
nBegPercent = round( 100 * ( nBeg ./ nTested ) );
fprintf( formatBodyPercent, 'Largest event first:', ...
    nBeg(1), nBegPercent(1), ...
    nBeg(2), nBegPercent(2), ...
    nBeg(3), nBegPercent(3), ...
    nBeg(4), nBegPercent(4), ...
    nBeg(5), nBegPercent(5) );
nEndPercent = round( 100 * ( nEnd ./ nTested ) );
fprintf( formatBodyPercent, 'Largest event last:', ...
    nEnd(1), nEndPercent(1), ...
    nEnd(2), nEndPercent(2), ...
    nEnd(3), nEndPercent(3), ...
    nEnd(4), nEndPercent(4), ...
    nEnd(5), nEndPercent(5) );   
nBegRepeatPercent = round( 100 * ( nBegRepeat ./ nBeg ) );
fprintf( '\n' );
fprintf( formatBody, 'Test largest first:', nBeg );
fprintf( formatBodyPercent, 'Repeating events:', ...
    nBegRepeat(1), nBegRepeatPercent(1), ...
    nBegRepeat(2), nBegRepeatPercent(2), ...
    nBegRepeat(3), nBegRepeatPercent(3), ...
    nBegRepeat(4), nBegRepeatPercent(4), ...
    nBegRepeat(5), nBegRepeatPercent(5) );
fprintf( '\n' );


% Purity
for iThing = 1:5
    purityEvents = upper(purity(ids(:,iThing)));
    nTested(iThing) = sum( ~strcmp( purityEvents, '' ) );
    nVtOnly(iThing) = sum( strcmp( purityEvents, 'V' ) );
    nRf(iThing) = sum( contains( purityEvents, 'R' ) );
    nRfMaybe(iThing) = sum( contains( purityEvents, 'R?' ) );
    nRfDef(iThing) = nRf(iThing) - nRfMaybe(iThing);
    nLp(iThing) = sum( contains( purityEvents, 'L' ) );
    nLpMaybe(iThing) = sum( contains( purityEvents, 'L?' ) );
    nLpDef(iThing) = nLp(iThing) - nLpMaybe(iThing);
    nHy(iThing) = sum( contains( purityEvents, 'H' ) );
    nHyMaybe(iThing) = sum( contains( purityEvents, 'H?' ) );
    nHyDef(iThing) = nHy(iThing) - nHyMaybe(iThing);
    nContaminated(iThing) = nRf(iThing) + nLp(iThing) + nHy(iThing);
    nContaminatedMaybe(iThing) = nRfMaybe(iThing) + nLpMaybe(iThing) + nHyMaybe(iThing);
end
fprintf( formatBody, 'Tested for non-VTs:', nTested );
nVtOnlyPercent = round( 100 * ( nVtOnly ./ nTested ) );
fprintf( formatBodyPercent, 'Contains only VTs:', ...
    nVtOnly(1), nVtOnlyPercent(1), ...
    nVtOnly(2), nVtOnlyPercent(2), ...
    nVtOnly(3), nVtOnlyPercent(3), ...
    nVtOnly(4), nVtOnlyPercent(4), ...
    nVtOnly(5), nVtOnlyPercent(5) );
nRfDefPercent = round( 100 * ( nRfDef ./ nTested ) );
fprintf( formatBodyPercent, 'Contains rockfalls:', ...
    nRfDef(1), nRfDefPercent(1), ...
    nRfDef(2), nRfDefPercent(2), ...
    nRfDef(3), nRfDefPercent(3), ...
    nRfDef(4), nRfDefPercent(4), ...
    nRfDef(5), nRfDefPercent(5) );
nRfMaybePercent = round( 100 * ( nRfMaybe ./ nTested ) );
fprintf( formatBodyPercent, 'Maybe contains rockfalls:', ...
    nRfMaybe(1), nRfMaybePercent(1), ...
    nRfMaybe(2), nRfMaybePercent(2), ...
    nRfMaybe(3), nRfMaybePercent(3), ...
    nRfMaybe(4), nRfMaybePercent(4), ...
    nRfMaybe(5), nRfMaybePercent(5) );
nLpDefPercent = round( 100 * ( nLpDef ./ nTested ) );
fprintf( formatBodyPercent, 'Contains LPs:', ...
    nLpDef(1), nLpDefPercent(1), ...
    nLpDef(2), nLpDefPercent(2), ...
    nLpDef(3), nLpDefPercent(3), ...
    nLpDef(4), nLpDefPercent(4), ...
    nLpDef(5), nLpDefPercent(5) );
nLpMaybePercent = round( 100 * ( nLpMaybe ./ nTested ) );
fprintf( formatBodyPercent, 'Maybe contains LPs:', ...
    nLpMaybe(1), nLpMaybePercent(1), ...
    nLpMaybe(2), nLpMaybePercent(2), ...
    nLpMaybe(3), nLpMaybePercent(3), ...
    nLpMaybe(4), nLpMaybePercent(4), ...
    nLpMaybe(5), nLpMaybePercent(5) );
nHyDefPercent = round( 100 * ( nHyDef ./ nTested ) );
fprintf( formatBodyPercent, 'Contains hybrids:', ...
    nHyDef(1), nHyDefPercent(1), ...
    nHyDef(2), nHyDefPercent(2), ...
    nHyDef(3), nHyDefPercent(3), ...
    nHyDef(4), nHyDefPercent(4), ...
    nHyDef(5), nHyDefPercent(5) );
nHyMaybePercent = round( 100 * ( nHyMaybe ./ nTested ) );
fprintf( formatBodyPercent, 'Maybe contains hybrids:', ...
    nHyMaybe(1), nHyMaybePercent(1), ...
    nHyMaybe(2), nHyMaybePercent(2), ...
    nHyMaybe(3), nHyMaybePercent(3), ...
    nHyMaybe(4), nHyMaybePercent(4), ...
    nHyMaybe(5), nHyMaybePercent(5) );
fprintf( '\n\n' );

% VT strings

fprintf( formatBody1, 'VT strings:', nVtString );
fprintf( '\n' );

nSurface = sum( surface(idVtString) == 'y' );
nSurfaceMaybe = sum( surface(idVtString) == '?' );
fprintf( formatBodyPercent1, 'Associated with surface activity:', nSurface, round(100*nSurface/nVtString) );
fprintf( formatBodyPercent1, 'Maybe associated with surface activity:', nSurfaceMaybe, round(100*nSurfaceMaybe/nVtString) );
fprintf( '\n' );

nTested = sum( ~strcmp( repeating(idVtString), '' ) );
nRepeating = sum( strcmpi( repeating(idVtString), 'Y' ) );
nSomeRepeating = sum( strcmpi( repeating(idVtString), 'S' ) );
fprintf( formatBody1, 'Tested for repetition:', nTested );
fprintf( formatBodyPercent1, 'Have repeating events:', nRepeating, round(100*nRepeating/nTested) );
fprintf( formatBodyPercent1, 'Have some repeating events:', nSomeRepeating, round(100*nSomeRepeating/nTested) );
fprintf( '\n' );

nTested = sum( ~strcmp( form(idVtString), '' ) );
nBeg = sum( strcmpi( form(idVtString), 'B' ) );
nEnd = sum( strcmpi( form(idVtString), 'E' ) );
nBegRepeating = sum( and( strcmpi( form(idVtString), 'B' ),  strcmpi( repeating(idVtString), 'Y' ) ) );
fprintf( formatBody1, 'Tested for form:', nTested );
fprintf( formatBodyPercent1, 'Largest event first:', nBeg, round(100*nBeg/nTested) );
fprintf( formatBodyPercent1, 'Largest event last:', nEnd, round(100*nEnd/nTested) );
fprintf( '\n' );

fprintf( formatBody1, 'Largest first, tested for repeating:', nBeg );
fprintf( formatBodyPercent1, 'Largest first, repeating:', nBegRepeating, round(100*nBegRepeating/nBeg) );
fprintf( '\n' );

nTested = sum( ~strcmp( purity(idVtString), '' ) );
nVtOnly = sum( strcmpi( purity(idVtString), 'V' ) );
nRf = sum( contains( purity(idVtString), 'r' ) );
nRfMaybe = sum( contains( purity(idVtString), 'r?' ) );
nRfDef = nRf - nRfMaybe;
nLp = sum( contains( purity(idVtString), 'l' ) );
nLpMaybe = sum( contains( purity(idVtString), 'l?' ) );
nLpDef = nLp - nLpMaybe;
nHy = sum( contains( purity(idVtString), 'h' ) );
nHyMaybe = sum( contains( purity(idVtString), 'h?' ) );
nHyDef = nHy - nHyMaybe;
fprintf( formatBody1, 'Tested for non-VTs:', nTested );
fprintf( formatBodyPercent1, 'Contains only VTs:', nVtOnly, round(100*nVtOnly/nTested) );
fprintf( formatBodyPercent1, 'Contains rockfalls:', nRfDef, round(100*nRfDef/nTested) );
fprintf( formatBodyPercent1, 'Maybe contains rockfalls:', nRfMaybe, round(100*nRfMaybe/nTested) );
fprintf( formatBodyPercent1, 'Contains LPs:', nLpDef, round(100*nLpDef/nTested) );
fprintf( formatBodyPercent1, 'Maybe contains LPs:', nLpMaybe, round(100*nLpMaybe/nTested) );
fprintf( formatBodyPercent1, 'Contains hybrids:', nHyDef, round(100*nHyDef/nTested) );
fprintf( formatBodyPercent1, 'Maybe contains hybrids:', nHyMaybe, round(100*nHyMaybe/nTested) );


% Repeating events and duration of string
figure;
figure_size( 's' );
edges = 0:10:400;
subplot( 2, 1, 1 );
stringDurations = duration( idVtString );
histogram( stringDurations, edges );
xlabel( 'Duration (minutes)' );
ylabel( '#' );
title( 'All VT Strings' );
subplot( 2, 1, 2 );
idRepeating = and( idVtString, strcmpi( repeating, 'Y' ) );
stringDurations = duration( idRepeating );
histogram( stringDurations, edges );
xlabel( 'Duration (minutes)' );
ylabel( '#' );
title( 'VT Strings With Repeating Events' );
plotOverTitle( 'Distribution of VT String Duration' );
fileSave = 'fig---VT_string_duration_repeating_events.png';
saveas( gcf, fileSave );

diary off;
