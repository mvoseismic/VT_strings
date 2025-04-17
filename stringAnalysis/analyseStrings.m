% Various plots of VT strings
%
% RCS 2024-01-11
%

disp( "WARNING: This script crashes on long strings (app. 100+ minutes),")
disp( "         probably due to memory limitations.")
disp( "         This might help:")
disp( "             $ sudo swapoff -a")
disp( "             $ sudo swapon -a")
disp( "         Press any key to go on.")
disp( "")
pause;

clear;

tic

warning('off','all');

setColours;
setup = setupGlobals();
dirStringData = fullfile( setup.DirHome, "projects/Seismicity/VT_strings/data" );


% Stations
stations = [ "MSS1", "MBLG", "MBLY" ];
nstations = length( stations );


% Filter
fc = 1.0;


% Read info from VT_strings spreadsheet
vtStrings = read_string_spreadsheet( setup );
tmp = vtStrings.Id;
id = string( tmp );
tmp = vtStrings.DatimFirst;
datimBeg = datenum( tmp );
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
nStrings = length( datimBeg );


% List for choosing
idWant = strcmp( what, 'VT string' );
idWant = ones( size( what ) );
fmtString1 = "%4d  %13s  %-20s  %4d  %5.1f\n";
for istring = 1:nStrings

    if idWant(istring)
        plotstring = sprintf( "plots/%s*.png", id(istring) );
        fstruct = dir( plotstring );
        if strcmp( id(istring), "" )
            nplots = 0;
        else
            nplots = length( fstruct );
        end
        fprintf( fmtString1, istring, id(istring), what(istring), nplots, duration(istring)  );
    end

end

% Choose
nString = inputd( 'String to analyse', 'i', nStrings );
fprintf( "%4d    id: %13s    what: %-20s     events: %3d     duration: %9.2f min\n", ...
    nString, id(nString), what(nString), ntotal(nString), duration(nString) );

fprintf( "first event: %s\n", datestr( datimBeg(nString), 'yyyy-mm-dd HH:MM:SS.FFF' ) );
fprintf( "last event:  %s\n", datestr( datimEnd(nString), 'yyyy-mm-dd HH:MM:SS.FFF' ) );


% Plot(s) wanted
plots = [ "All", "Verticals", "Filtered verticals", "Station plots", "Spectrograms", "CumEnvelopes", "CumEvents" ];
for iplot = 1:length( plots )
    fprintf( " %1d  %s\n", iplot, plots(iplot) );
end
nplot = inputd( 'Plot type wanted', 'i', 1 );


% Display plots
showPlot = inputd( 'Show plot on screen', 'l', 'N' );

% Time limits for plot
if duration(nString) <= 2
    minutes = 2.0;
elseif duration(nString) <= 10
    minutes = 10.0;
elseif duration(nString) <= 20
    minutes = 20.0;
elseif duration(nString) <= 60
    minutes = 60.0;
elseif duration(nString) <= 120
    minutes = 120.0;
else
    minutes = 360.0;
end
minPre = minutes * 0.2;
minWin = minutes * 1.2;

datimBegPlot = datimBeg(nString) - minPre/(24*60);
datimEndPlot = datimBegPlot + minWin/(24*60);


% Read info from event list file
dirEventLists = fullfile( setup.DirSeismicity, 'VT_strings/data/event_lists' );
fileEventList = strcat( id(nString), '.txt' );
fileEventList = fullfile( dirEventLists, fileEventList );
events = readtable( fileEventList, 'NumHeaderLines', 0, 'ReadVariableNames', 0, 'ExpectedNumVariables',7);
datimEvents = datenum( events.Var1, events.Var2, events.Var3, events.Var4, events.Var5, events.Var6 );
datimEvents = 24*60*(datimEvents - datimBeg(nString));
if width(events) == 7
    typeEvents = events.Var7;
    typeEvents(cellfun(@isempty,typeEvents)) = {'VT'};
elseif width(events) == 1
    typeEvents = events.Var7;
    typeEvents(cellfun(@isempty,typeEvents)) = {'VT'};
else
    typeEvents = cell( size(datimEvents) );
    typeEvents(:) = {'VT'};
end


% mseed file
fileMseed = sprintf( "%s.mseed", id(nString) );
fileMseed = fullfile( dirStringData, "mseed_files", fileMseed );
if isfile(fileMseed)
    fprintf( "mseed file: %s\n", fileMseed );
else
    fprintf( "mseed file %s\n", "DOES NOT EXIST" );
    return
end

% Read mseed file
signalStruct = ReadMSEEDFast( fileMseed );


% Get data 
for istation = 1:nstations

    sta = stations(istation);

    % Find channel
    ichannel = 0;
    for icha = 1:length( signalStruct )
        if strcmp(signalStruct(icha).station, stations(istation) ) & strcmp( signalStruct(icha).channel(end), "Z" )
            ichannel = icha;
        end
    end

    if ichannel == 0
        fprintf( "NO MATCHING CHANNEL for %s\n", sta );
        sampleRate = 0.0;
        tdata = [];
        tdatim = [];
    else
        sampleRate = signalStruct(ichannel).sampleRate;
        tdata = signalStruct(ichannel).data;
        tdatim = signalStruct(ichannel).matlabTimeVector;
    end


    % Trim data
    idWant = tdatim >= datimBegPlot & tdatim <= datimEndPlot;
    if sum( idWant ) == 0
        fprintf( "NO DATA for %s\n", sta );
    end

    data = tdata(idWant);
    datim = tdatim(idWant);
    

    % Remove mean value
    data = data - mean( data );

    % Zero time
    datim0 = 24*60*(datim - datimBeg(nString));
    datimBegPlot0 = -1 * minPre;
    datimEndPlot0 = minWin;
    datimFirst0 = 0.0;
    datimLast0 = 24*60*(datimEnd(nString) - datimBeg(nString));

    % Filtered data
    if ~strcmp( sta, 'MSS1' ) 
        fdata = highpass(data,fc,sampleRate);
        fdata = fdata - mean( fdata );
    else
        fdata = data;
    end
    
    % Strange seismogram
    hdata = abs( hilbert( fdata ) );
    if sampleRate == 200
        nwin = 2001;
    else
        nwin = 101;
    end
    hdata = nan_rmedian( hdata, nwin );
    sdata = fdata ./ sqrt(hdata);

    scnl = strcat( signalStruct(ichannel).station, '.', signalStruct(ichannel).channel, '.' , ...
        strcat( signalStruct(ichannel).network, '.', signalStruct(ichannel).location ) );



    switch istation
        case 1
            dataSta1 = data;
            fdataSta1 = fdata;
            sdataSta1 = sdata;
            datimSta1 = datim0;
            scnlSta1 = scnl;
            fsSta1 = sampleRate;
        case 2
            dataSta2 = data;
            fdataSta2 = fdata;
            sdataSta2 = sdata;
            datimSta2 = datim0;
            scnlSta2 = scnl;
            fsSta2 = sampleRate;
        case 3
            dataSta3 = data;
            fdataSta3 = fdata;
            sdataSta3 = sdata;
            datimSta3 = datim0;
            scnlSta3 = scnl;
            fsSta3 = sampleRate;
    end

end


clear signalStruct;

fprintf( "plot   " );
%% PLOT 1 - VERTICALS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot verticals
if nplot == 1 || nplot == 2
    fprintf( "  1");
    if showPlot
        figure;
    else
        figure( 'Visible', 'off' );
    end
    figure_size( 'l' );
    for ista = 1:nstations

        switch ista
            case 1
                data = dataSta1;
                datim = datimSta1;
                scnl = scnlSta1;
                fs = fsSta1;
            case 2
                data = dataSta2;
                datim = datimSta2;
                scnl = scnlSta2;
                fs = fsSta2;
            case 3
                data = dataSta3;
                datim = datimSta3;
                scnl = scnlSta3;
                fs = fsSta3;
        end

        if fs == 0 
            fprintf( "FS = 0 for %s\n", sta );
            continue
        end

        % Max data
        dataMax = max( abs( data ) );

        subplot( 3, 1, ista );
        plot(datim,data);
        ylim( [-1.1*dataMax 1.1*dataMax] );
        xlim( [datimBegPlot0 datimEndPlot0] );
        set(gca,'TickDir','out');
        set( gca, 'YTickLabels', {} );
        if sigClipped( data )
            scnl = append( scnl, ' (CLIPPED)' );
        end
        title( scnl );
        set( gca, 'TitleHorizontalAlignment', 'left' );
        xlabel( 'Minutes' );
        xline( datimFirst0, 'k:', 'LineWidth', 0.2 );
        xline( datimLast0, 'k:', 'LineWidth', 0.2 );
        box on;

    end

    overTitle = append( id(nString), '    ', what(nString), '    Verticals' );
    plotOverTitle( overTitle );
    filePlot = append( id(nString), '--', what(nString), '-analysis_01-verticals.png' );
    filePlot = regexprep(filePlot, ' +', '_');
    filePlot = fullfile( './plots', filePlot );
    saveas( gcf, filePlot );
    if ~showPlot
        close( gcf );
    end

end


%% PLOT 2 - FILTERED VERTICALS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot filtered verticals
if nplot == 1 || nplot == 3
    fprintf( "  2");
    if showPlot
        figure;
    else
        figure( 'Visible', 'off' );
    end
    figure_size( 'l' );
    for ista = 1:nstations

        switch ista
            case 1
                data = dataSta1;
                fdata = fdataSta1;
                datim = datimSta1;
                scnl = scnlSta1;
                fs = fsSta1;
            case 2
                data = dataSta2;
                fdata = fdataSta2;
                datim = datimSta2;
                scnl = scnlSta2;
                fs = fsSta2;
            case 3
                data = dataSta3;
                fdata = fdataSta3;
                datim = datimSta3;
                scnl = scnlSta3;
                fs = fsSta3;
        end

        if fs == 0 
            fprintf( "FS = 0 for %s\n", sta );
            continue
        end

        % Max data
        dataMax = max( abs( fdata ) );

        subplot( 3, 1, ista );
        plot(datim,fdata);
        ylim( [-1.1*dataMax 1.1*dataMax] );
        xlim( [datimBegPlot0 datimEndPlot0] );
        set(gca,'TickDir','out');
        set( gca, 'YTickLabels', {} );
        if sigClipped( data )
            scnl = append( scnl, ' (CLIPPED)' );
        end
        title( scnl );
        set( gca, 'TitleHorizontalAlignment', 'left' );
        xlabel( 'Minutes' );
        xline( datimFirst0, 'k:', 'LineWidth', 0.2 );
        xline( datimLast0, 'k:', 'LineWidth', 0.2 );
        box on;

    end

    overTitle = append( id(nString), '    ', what(nString), '    Filtered Verticals (except MSS1)' );
    plotOverTitle( overTitle );
    filePlot = append( id(nString), '--', what(nString), '-analysis_02-filtered_verticals.png' );
    filePlot = regexprep(filePlot, ' +', '_');
    filePlot = fullfile( './plots', filePlot );
    saveas( gcf, filePlot );
    if ~showPlot
        close( gcf );
    end

end


%% PLOT 3 - STATION PLOTS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot station plots
if nplot == 1 || nplot == 4
    fprintf( "  3");

    for ista = 1:nstations

        switch ista
            case 1
                data = dataSta1;
                fdata = fdataSta1;
                sdata = sdataSta1;
                datim = datimSta1;
                scnl = scnlSta1;
                fs = fsSta1;
            case 2
                data = dataSta2;
                fdata = fdataSta2;
                sdata = sdataSta2;
                datim = datimSta2;
                scnl = scnlSta2;
                fs = fsSta2;
            case 3
                data = dataSta3;
                fdata = fdataSta3;
                sdata = sdataSta3;
                datim = datimSta3;
                scnl = scnlSta3;
                fs = fsSta3;
        end

        if fs == 0 
            fprintf( "FS = 0 for %s\n", sta );
            continue
        end

        sta = stations(ista);

        % Max data
        dataMax = max( abs( fdata ) );


        if showPlot
            figure;
        else
            figure( 'Visible', 'off' );
        end
        figure_size( 'l' );
        t = tiledlayout(3,1);

        ax1 = nexttile(1);
        plot(datim,fdata);
        ylim( [-1.1*dataMax 1.1*dataMax] );
        xlim( [datimBegPlot0 datimEndPlot0] );
        set(gca,'TickDir','out');
        if ~strcmp( sta, 'MSS1' ) 
            tit = sprintf( "Filtered seismogram %3.1fHz high-pass", fc );
        else
            tit = 'Unfiltered seismogram';
        end
        title( tit );
        set( gca, 'TitleHorizontalAlignment', 'left' ); 
        set( gca, 'YTickLabels', {} );
        box on;
        grid on;

        hold on;
        yLimits = ylim;
        y4 = yLimits(2);
        y3 = yLimits(1) + 0.95 * ( yLimits(2) - yLimits(1) );
        y2 = yLimits(1) + 0.05 * ( yLimits(2) - yLimits(1) );
        y1 = yLimits(1);
        idWant = strcmp( typeEvents, 'VT' );

        D = datimEvents( idWant );
        if length(D) > 0
            N = numel(D);
            X_plot = [D'; D'; NaN(1,N); D'; D'; NaN(1,N)];
            Y_plot = repmat([y1; y2; NaN; y3; y4; NaN],1,N);
            plot(X_plot(:),Y_plot(:), '-', 'LineWidth', 0.1, 'Color', darkRed );
        end
        D = datimEvents( ~idWant );
        if length(D) > 0
            N = numel(D);
            X_plot = [D'; D'; NaN(1,N); D'; D'; NaN(1,N)];
            Y_plot = repmat([y1; y2; NaN; y3; y4; NaN],1,N);
            plot(X_plot(:),Y_plot(:), '-', 'LineWidth', 0.1, 'Color', darkGreen );
        end
        legend( '', 'VT', 'non-VT', 'Location', 'northeast' );


        % Envelope
        hdata = abs( hilbert( fdata ) );
        if fs == 200
            nwin = 201;
        else
            nwin = 101;
        end
        hdata = nan_rmedian( hdata, nwin );

        ax2 = nexttile(2);
        plot(datim,hdata);
        xlim( [datimBegPlot0 datimEndPlot0] );
        set(gca,'TickDir','out');
        title( 'Smoothed envelope' );
        set( gca, 'TitleHorizontalAlignment', 'left' ); 
        set(gca, 'YScale', 'log')
        grid on;
        box on;

        hold on;
        yLimits = ylim;
        y4 = yLimits(2);
        y3 = 10^( log10(yLimits(1)) + ( 0.9 * ( log10(yLimits(2)) - log10(yLimits(1)) ) ) );
        y2 = 10^( log10(yLimits(1)) + ( 0.1 * ( log10(yLimits(2)) - log10(yLimits(1)) ) ) );
        y1 = yLimits(1);
        idWant = strcmp( typeEvents, 'VT' );

        D = datimEvents( idWant );
        if length(D) > 0
            N = numel(D);
            X_plot = [D'; D'; NaN(1,N); D'; D'; NaN(1,N)];
            Y_plot = repmat([y1; y2; NaN; y3; y4; NaN],1,N);
            plot(X_plot(:),Y_plot(:), 'r-', 'LineWidth', 0.1, 'Color', darkRed );
        end
        D = datimEvents( ~idWant );
        if length(D) > 0
            N = numel(D);
            X_plot = [D'; D'; NaN(1,N); D'; D'; NaN(1,N)];
            Y_plot = repmat([y1; y2; NaN; y3; y4; NaN],1,N);
            plot(X_plot(:),Y_plot(:), 'g-', 'LineWidth', 0.1, 'Color', darkGreen );
        end
        legend( '', 'VT', 'non-VT', 'Location', 'northeast' );


        % Spectrogram
        if length( fdata ) > 1
            % cwt

            % Wavelet transform
            [wt,f] = cwt(sdata,fs);
            sdb = abs(wt);
            sdb = log( sdb );
            t0 = (0:numel(data)-1)/fs;
            t0 = t0/60 + datim0(1);
            tit = 'Continuous wavelet transform (variable gain)';
            clear wt;

            % Decimation of cwt matrix
            if numel( sdata) > 1000000
                nDecimate = 1000;
            elseif numel( sdata) > 500000
                nDecimate = 100;
            else
                nDecimate = 10;
            end
            sdb = decimateArray( sdb, nDecimate );
            t0 = decimate( t0, nDecimate );

        else
            % spectrogram

            [s,f,t] = stft( fdata, sampleRate,'FrequencyRange','onesided' );
            sdb = mag2db(abs(s));
            t0 = t/60 + datim0(1);
            tit = 'Short-time fourier transform';
            clear s;

        end
    
        ax1 = nexttile(3);
        mesh(t0,f,sdb);
        colormap jet;
        view(2);
        axis tight;
        set( gca, 'YScale', 'log' );
        set(gca,'TickDir','out');
        xlim( [datimBegPlot0 datimEndPlot0] );
        ylim( [1 100] );
        clim( [0 max(max(sdb))] );
        ylabel( 'Hz' );
        title( tit );
        set( gca, 'TitleHorizontalAlignment', 'left' ); 
        grid off;
        box on;

        hold on;
        yLimits = ylim;
        y4 = yLimits(2);
        y3 = 10^( log10(yLimits(1)) + ( 0.9 * ( log10(yLimits(2)) - log10(yLimits(1)) ) ) );
        idWant = strcmp( typeEvents, 'VT' );

        D = datimEvents( idWant );
        if length(D) > 0
            N = numel(D);
            X_plot = [D'; D'; NaN(1,N)];
            Y_plot = repmat([y3; y4; NaN],1,N);
            plot(X_plot(:),Y_plot(:), 'r-', 'LineWidth', 0.1, 'Color', darkRed );
        end
        D = datimEvents( ~idWant );
        if length(D) > 0
            N = numel(D);
            X_plot = [D'; D'; NaN(1,N)];
            Y_plot = repmat([y3; y4; NaN],1,N);
            plot(X_plot(:),Y_plot(:), 'g-', 'LineWidth', 0.1, 'Color', darkGreen );
        end

        
        if sigClipped( data )
            scnl = append( scnl, ' (CLIPPED)' );
        end
        scnl = append( id(nString), '    ', what(nString), '    ', scnl );
        plotOverTitle( scnl );
        filePlot = append( id(nString), '--', what(nString), '-analysis_03_', sprintf("%s",sta), '.png' );
        filePlot = regexprep(filePlot, ' +', '_');
        filePlot = fullfile( './plots', filePlot );
        saveas( gcf, filePlot );
        if ~showPlot
            close( gcf );
        end

        clear sdb;

    end

end


%% PLOT 4 - SPECTROGRAMS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot spectrograms
if nplot == 1 || nplot == 5
    fprintf( "  4");

    if showPlot
        figure;
    else
        figure( 'Visible', 'off' );
    end
    figure_size( 'l' );
    t = tiledlayout(9,1,'TileSpacing','none');

    for ista = 1:nstations

        switch ista
            case 1
                data = dataSta1;
                fdata = fdataSta1;
                sdata = sdataSta1;
                datim = datimSta1;
                scnl = scnlSta1;
                fs = fsSta1;
            case 2
                data = dataSta2;
                fdata = fdataSta2;
                sdata = sdataSta2;
                datim = datimSta2;
                scnl = scnlSta2;
                fs = fsSta2;
            case 3
                data = dataSta3;
                fdata = fdataSta3;
                sdata = sdataSta3;
                datim = datimSta3;
                scnl = scnlSta3;
                fs = fsSta3;
        end

        if fs == 0 
            fprintf( "FS = 0 for %s\n", sta );
            continue
        end

        sta = stations(ista);

        % Max data
        dataMax = max( abs( fdata ) );

        ax1 = nexttile(ista);
        plot(datim,abs(fdata));
        ylim( [-0.1*dataMax 1.1*dataMax] );
        xlim( [datimBegPlot0 datimEndPlot0] );

        hold on;
        yLimits = ylim;
        y4 = yLimits(2);
        y3 = yLimits(1) + 0.95 * ( yLimits(2) - yLimits(1) );
        idWant = strcmp( typeEvents, 'VT' );

        D = datimEvents( idWant );
        if length(D) > 0
            N = numel(D);
            X_plot = [D'; D'; NaN(1,N)];
            Y_plot = repmat([y3; y4; NaN],1,N);
            plot(X_plot(:),Y_plot(:), 'r-', 'LineWidth', 0.1, 'Color', darkRed );
        end
        D = datimEvents( ~idWant );
        if length(D) > 0
            N = numel(D);
            X_plot = [D'; D'; NaN(1,N)];
            Y_plot = repmat([y3; y4; NaN],1,N);
            plot(X_plot(:),Y_plot(:), 'g-', 'LineWidth', 0.1, 'Color', darkGreen );
        end
      
        ax1.XGrid = 'on';
        if ista == 1
            set(gca,'XAxisLocation','Top');
            set(gca,'TickDir','out');
            xlabel( 'Minutes' );
        else
            xticklabels("");
            ax1.TickLength = [0, 0];
        end
        set( gca, 'ytick', [] );
        ylabel( sta );


        % Spectrogram
        if length( sdata ) > 1
            % cwt

            % Wavelet transform
            [wt,f] = cwt(sdata,fs);
            sdb = abs(wt);
            sdb = log( sdb );
            t0 = (0:numel(data)-1)/fs;
            t0 = t0/60 + datim0(1);
            tit = 'Continuous wavelet transform (variable gain)';
            clear wt;

            % Decimation of cwt matrix
            if numel( sdata) > 1000000
                nDecimate = 1000;
            elseif numel( sdata) > 500000
                nDecimate = 100;
            else
                nDecimate = 10;
            end
            sdb = decimateArray( sdb, nDecimate );
            t0 = decimate( t0, nDecimate );

        else
            % spectrogram

            [s,f,t] = stft( fdata, sampleRate,'FrequencyRange','onesided' );
            sdb = mag2db(abs(s));
            t0 = t/60 + datim0(1);
            tit = 'Short-time fourier transform';
            clear s;

        end
        
        itile = ista*2+2;
        ax2 = nexttile( itile, [2 1] );

        mesh(t0,f,sdb);
        colormap jet;
        view(2);
        axis tight;
        set( gca, 'YScale', 'log' );
        xlim( [datimBegPlot0 datimEndPlot0] );
        ylim( [1 150] );
        clim( [0 max(max(sdb))] );
        clear sdb;

        if ista == 3
            set(gca,'XAxisLocation','Bottom');
            set(gca,'TickDir','out');
            xlabel( 'Minutes' );
        else
            xticklabels("");
            tl = ax2.TickLength;
            tl(1) = 0;
            ax2.TickLength = tl;
        end
        ylabel( sta );
        grid on;
      
        hold on;
        yLimits = ylim;
        y4 = yLimits(2);
        y3 = 10^( log10(yLimits(1)) + ( 0.9 * ( log10(yLimits(2)) - log10(yLimits(1)) ) ) );
        idWant = strcmp( typeEvents, 'VT' );

        D = datimEvents( idWant );
        if length(D) > 0
            N = numel(D);
            X_plot = [D'; D'; NaN(1,N)];
            Y_plot = repmat([y3; y4; NaN],1,N);
            plot(X_plot(:),Y_plot(:), 'r-', 'LineWidth', 0.1, 'Color', darkRed );
        end
        D = datimEvents( ~idWant );
        if length(D) > 0
            N = numel(D);
            X_plot = [D'; D'; NaN(1,N)];
            Y_plot = repmat([y3; y4; NaN],1,N);
            plot(X_plot(:),Y_plot(:), 'g-', 'LineWidth', 0.1, 'Color', darkGreen );
        end


    end
        
    overTitle = append( id(nString), '    ', what(nString), '    Spectrograms' );
    plotOverTitle( overTitle );
    filePlot = append( id(nString), '--', what(nString), '-analysis_04-spectrograms.png' );
    filePlot = regexprep(filePlot, ' +', '_');
    filePlot = fullfile( './plots', filePlot );
    saveas( gcf, filePlot );
    if ~showPlot
        close( gcf );
    end

        


end

%% PLOT 5 - CUMULATIVE SMOOTHED ENVELOPES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot cumulative smoothed envelopes
if nplot == 1 || nplot == 6
    fprintf( "  5");

    if showPlot
        figure;
    else
        figure( 'Visible', 'off' );
    end
    figure_size( 'l' );
    t = tiledlayout(5,3,'TileSpacing','none');

    for ista = 1:nstations

        switch ista
            case 1
                data = dataSta1;
                fdata = fdataSta1;
                sdata = sdataSta1;
                datim = datimSta1;
                scnl = scnlSta1;
                fs = fsSta1;
            case 2
                data = dataSta2;
                fdata = fdataSta2;
                sdata = sdataSta2;
                datim = datimSta2;
                scnl = scnlSta2;
                fs = fsSta2;
            case 3
                data = dataSta3;
                fdata = fdataSta3;
                sdata = sdataSta3;
                datim = datimSta3;
                scnl = scnlSta3;
                fs = fsSta3;
        end

        if fs == 0 
            fprintf( "FS = 0 for %s\n", sta );
            continue
        end

        sta = stations(ista);

        if sigClipped( data )
            plotCol = 'r';
        else
            plotCol = 'b';
        end

        % Max data
        dataMax = max( abs( fdata ) );

        ax1 = nexttile(ista);
        plot(datim,abs(fdata));
        ylim( [-0.1*dataMax 1.1*dataMax] );
        xlim( [datimBegPlot0 datimEndPlot0] );

        set(gca,'XAxisLocation','Top');
        set(gca,'TickDir','out');
        xlabel( 'Minutes' );
        set( gca, 'ytick', [] );
        title( sta );

        % Envelope
        hdata = abs( hilbert( fdata ) );
        if fs == 200
            nwin = 101;
        else
            nwin = 51;
        end
        hdata = nan_rmedian( hdata, nwin );
        ax3 = nexttile(ista+3);
        plot(datim,hdata, '-', 'Color', plotCol );
        xlim( [datimBegPlot0 datimEndPlot0] );
        set( gca, 'ytick', [] );
        set( gca, 'xtick', [] );
        grid on;


        idWant =  (datim < 0);
        hdata = cumsum( hdata );
        %p = polyfit( datim(idWant), hdata(idWant), 1 );
        %remove = polyval(p,datim);
        %hdatar = hdata - remove;
        hdatar = hdata;


        ax2 = nexttile(ista+6, [3 1]);
        idWant = datim >= 0 & datim <= datimLast0+0.5;
        plot(datim(idWant),hdatar(idWant), '-', 'Color', plotCol );

        xlim( [datimBegPlot0 datimEndPlot0] );
        set(gca,'XAxisLocation','Bottom');
        set(gca,'TickDir','out');
        xlabel( 'Minutes' );
        set( gca, 'ytick', [] );
        grid on;

    end

    overTitle = append( id(nString), '    ', what(nString), '    Cumulative smoothed envelope' );
    plotOverTitle( overTitle );
    filePlot = append( id(nString), '--', what(nString), '-analysis_05-cumulativeenvelope.png' );
    filePlot = regexprep(filePlot, ' +', '_');
    filePlot = fullfile( './plots', filePlot );
    saveas( gcf, filePlot );
    if ~showPlot
        close( gcf );
    end


end

%% PLOT 6 - CUMULATIVE EVENTS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot cumulative events
if nplot == 1 || nplot == 7
    fprintf( "  6");

    if showPlot
        figure;
    else
        figure( 'Visible', 'off' );
    end
    figure_size( 'l' );

    ampEvents = ones( size(datimEvents) );

    t = tiledlayout(2,2,'TileSpacing','none');

    ax1 = nexttile(1);
    plot( [0;datimEvents], cumsum([0;ampEvents]), 'b-' );
    xlim( [datimBegPlot0 datimEndPlot0] );
    ylim( [0 Inf] );
    set(gca,'XAxisLocation','Top');
    set(gca,'TickDir','out');
    xlabel( 'Minutes' );
    title( 'Cumulative events' );
    grid on;

    windowAmpMax = 5.0;
    windowAmp = diff( datimEvents ) * 60;
    windowAmp( windowAmp > windowAmpMax ) = windowAmpMax;
    windowAmp = [ windowAmp; windowAmpMax ];
    windowAmp = windowAmp / 60.0;

    for istation = 1:nstations

        for ievent = 1:height(events)

            switch istation
                case 1
                    datim = datimSta1;
                    data = dataSta1;
                    scnl = scnlSta1;
                case 2
                    datim = datimSta2;
                    data = dataSta2;
                    scnl = scnlSta2;
                case 3
                    datim = datimSta3;
                    data = dataSta3;
                    scnl = scnlSta3;
            end

            idWant = datim >= datimEvents(ievent) & datim <= datimEvents(ievent) + windowAmp(ievent);

            if sum( idWant ) == 0
                fprintf( "NO DATA for %s\n", sta );
                continue
            end

            ampEvents(ievent) = max( abs( data(idWant) ) );

        end

        if sigClipped( data )
            plotCol = 'r';
        else
            plotCol = 'b';
        end

        ax2 = nexttile(istation+1);
        plot( [0;datimEvents], cumsum([0;ampEvents]), '-', 'Color', plotCol );
        xlim( [datimBegPlot0 datimEndPlot0] );
        ylim( [0 Inf] );
        if istation == 1
            set(gca,'XAxisLocation','Top');
            set(gca,'YAxisLocation','Right');
        else
            set(gca,'XAxisLocation','Bottom');
            if istation == 3
                set(gca,'YAxisLocation','Right');
            end
        end
        set(gca,'TickDir','out');
        set( gca, 'ytick', [] );
        xlabel( 'Minutes' );
        grid on;
        legend( scnl, 'Location', 'northwest' );

    end

    overTitle = append( id(nString), '    ', what(nString), '    Cumulative event amplitude' );
    plotOverTitle( overTitle );
    filePlot = append( id(nString), '--', what(nString), '-analysis_06-cumulativeeventamp.png' );
    filePlot = regexprep(filePlot, ' +', '_');
    filePlot = fullfile( './plots', filePlot );
    saveas( gcf, filePlot );
    if ~showPlot
        close( gcf );
    end


end

fprintf( "\n");

warning('on','all');

toc
