% Plot of VT string cumulative event amplitudes
%
% RCS 2024-01-16
%

clear;

tic

%warning('off','all');

setColours;
setup = setupGlobals();
dirStringData = fullfile( setup.DirHome, "projects/Seismicity/VT_strings/data" );

% Filter
fc = 1.0;

% Read info from VT_strings spreadsheet
vtStrings = read_string_spreadsheet( setup );
tmp = vtStrings.Id;
id = string( tmp );
tmp = vtStrings.What;
what = string( tmp );
tmp = vtStrings.DatimFirst;
datimBeg = datenum( tmp );
duration = vtStrings.Duration;

idWant = strcmp( what, "VT string" );
id = id(idWant);
datimBeg = datimBeg(idWant);
duration = duration(idWant);
nstrings = length( duration );

dirEventLists = fullfile( setup.DirSeismicity, 'VT_strings/data/event_lists' );

timePre = 5.0/(60*24);
ampWindowMax = 5.0/(60*60*24);


figure;
figure_size( 's' );
tiledlayout( 2, 2 );

for ista = 1:4
    switch ista
        case 1
            sta = "MSS1";
        case 2
            sta = "MBLG";
        case 3
            sta = "MBLY";
        case 4
            sta = "MBRY";
    end

    nexttile;
    hold on;

    for istring = 1:nstrings

        % Read info from event list file
        fileEventList = strcat( id(istring), '.txt' );
        fileEventList = fullfile( dirEventLists, fileEventList );

        if isfile( fileEventList )
            events = readtable( fileEventList, 'NumHeaderLines', 0, 'ReadVariableNames', 0, 'ExpectedNumVariables',7);
        else
            fprintf( "%13s event file does not exist\n" , id(istring));
            continue
        end

        datimEvents = datenum( events.Var1, events.Var2, events.Var3, events.Var4, events.Var5, events.Var6 );
        datimEvent1 = datimEvents(1);

        ampWindow = diff( datimEvents );
        ampWindow( ampWindow > ampWindowMax) = ampWindowMax;
        ampWindow = [ ampWindow; ampWindowMax ];


        % mseed file
        fileMseed = sprintf( "%s.mseed", id(istring) );
        fileMseed = fullfile( dirStringData, "mseed_files", fileMseed );
        if ~isfile(fileMseed)
            fprintf( "%13s mseed file does not exist\n", id(istring) );
            continue
        end

        % Read mseed file
        signalStruct = ReadMSEEDFast( fileMseed );

        % Find channel
        ichannel = 0;
        for icha = 1:length( signalStruct )
            if strcmp(signalStruct(icha).station, sta )
                ichannel = icha;
            end
        end

        if ichannel == 0
            fprintf( "%13s no %s data\n", id(istring), sta );
            continue
        end

        % Get data
        fc = signalStruct(ichannel).sampleRate;
        data = signalStruct(ichannel).data;
        datim = signalStruct(ichannel).matlabTimeVector;

        datimBegPlot = datimEvent1 - timePre;
        datimEndPlot = datimEvent1 + duration(istring) + timePre;
    
        % Trim data
        idWant = datim >= datimBegPlot & datim <= datimEndPlot;
        data = data(idWant);
        datim = datim(idWant);

        % Is data clipped?
        if sigClipped( data )
            plotCol = 'r';
        else
            plotCol = 'b';
        end

        % Remove mean value
        data = data - mean( data );

        % Calculate event sizes
        ampEvents = ones( size(datimEvents) );
        for ievent = 1:height(events)
            idWant = datim >= datimEvents(ievent) & datim <= datimEvents(ievent) + ampWindow(ievent);
            if sum( idWant ) == 0
                fprintf( "%13s %s %3d  error retrieving data\n", id(istring), sta, ievent );
                ampEvents(ievent) = NaN;
            else
                ampEvents(ievent) = max( abs( data(idWant) ) );
            end
        end

        % Tidy and normalize
        ampEvents = cumsum( ampEvents);
        ampEvents = ampEvents / max( ampEvents );
        minuteEvents = (datimEvents - datimEvent1) * 60 * 24;
        minuteEvents = minuteEvents / max( minuteEvents );

        plot( [0;minuteEvents], [0;ampEvents], '-', 'Color', plotCol, 'LineWidth', 0.5 );

    end

    xlim( [-0.1 1.1] );
    ylim( [-0.1 1.1] );
    xlabel( "Normalised time" );
    ylabel( "Normalised amplitude" );
    grid on;
    title( sta );

end

plotOverTitle( "VT Strings - cumulative event amplitude" );

toc