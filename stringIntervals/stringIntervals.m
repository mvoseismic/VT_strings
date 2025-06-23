clear;
close all;

sourceStrings = 'real';
%sourceStrings = 'random';
sourceStrings = 'randomPlus';
dateLimit = 0;
%dateLimit = datenum( 2015, 6, 1 );
momentLimit = 0;
momentLimit = 0.015e15;
diffMethod = 1;
%diffMethod = 2;

edges = 0:2:250;

if strcmp( sourceStrings, 'real' )

    tit = "All strings";

    setup = setupGlobals();
    reFetch( setup );

    data_file = fullfile( setup.DirMegaplotData, 'fetchedVTstringsPlus.mat' );
    load( data_file );
    idWant = strcmpi( vtstrings.What, "VT string" );
    vtstrings = vtstrings( idWant, : );
    datim = vtstrings.DatimBeg;
    data = vtstrings.Moment;
    nStrings = length( datim );

    if dateLimit > 0
        idWant1 = datim >= dateLimit;
        tit = sprintf( "%s after %s", tit, datestr( dateLimit ) );
    else
        idWant1 = ones( nStrings, 1 );
    end

    if momentLimit > 0
        idWant2 = data >= momentLimit;
        tit = sprintf( "%s, Mo > %7.2e", tit, momentLimit );
    else
        idWant2 = ones( nStrings, 1 );
    end

    idWant = idWant1 & idWant2;
    datimStrings = datim( idWant );
    nStrings = length( datimStrings );
    tit = sprintf( "%s (%d)", tit, nStrings );

elseif strcmp( sourceStrings, 'random' )

    nStrings = 500;
    lengthData = 6350;
    datimStrings = sort( rand( nStrings, 1) * lengthData );
    tit = sprintf( "Random strings (%d)", nStrings );

elseif strcmp( sourceStrings, 'randomPlus' )

    nStrings = 450;
    lengthData = 6350;
    datimStrings = sort( rand( nStrings, 1) * lengthData );
    datimStringsPlus = 1000:20:4920;
    datimStrings = [ datimStrings; datimStringsPlus' ];
    datimStrings = sort( datimStrings );
    nStrings = length( datimStrings );
    tit = sprintf( "Random strings plus regular (%d)", nStrings );

end

lengthData = datimStrings(end) - datimStrings(1);

if diffMethod == 1

    datimInt = diff( datimStrings );


else

    datimInt = [];
    for iStr = 1:nStrings-1
        tInt = datimStrings(iStr+1:end) - datimStrings(iStr);
        datimInt = [ datimInt; tInt ];
    end

    edges = 30 * edges;

end

nDiffs = length( datimInt );
fprintf( " %d strings, %6.1f days, %d intervals\n", nStrings, lengthData, nDiffs );



figure;
figure_size('e',1200);

histogram( datimInt, edges );
title( tit );
xlim( [edges(1) edges(end)] );
xlabel( 'Time between strings (days)' );
ylabel( 'Number of strings' );

saveas( gcf, 'fig--stringIntervals.png' );
