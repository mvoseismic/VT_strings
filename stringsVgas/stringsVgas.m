clear all;
close all;
setup = setupGlobals();
setColours;


% Get strings
minStringMoment = 1.0E+15;
minStringMoment = 1.0;
dataFile = fullfile( setup.DirMegaplotData, 'fetchedVTstringsPlus.mat' );
load( dataFile );
whats = vtstrings.What;
idWant =  ismember( whats, 'VT string' );
stringId= string( vtstrings.ID( idWant ) );
stringDatimBeg = vtstrings.DatimBeg( idWant );
stringMoment = vtstrings.Moment( idWant );
idWant = stringMoment >= minStringMoment;
datetimeString = datetime( stringDatimBeg(idWant), 'ConvertFrom','datenum' );
dataString = stringMoment(idWant);
idString = stringId( idWant );


% Get traverse SO2
load('~/projects/megaplot/data/gas/gas_so2_traverse.mat');
datimGasTrav = gas_dates;
dataGasTrav = gas_so2_trav;
errGasTrav = gas_err;
datetimeGasTrav = datetime(datimGasTrav,'ConvertFrom','datenum')';

% Get DOAS SO2
load( '~/projects/megaplot/data/gas/gas_so2_auto' );
gdata = get( gas_so2, 'Data' );
tdata = get( gas_so2, 'Time' );
tstart = datenum( gas_so2.TimeInfo.StartDate );
% change by PJS 31-08-2011 - removed -1 as discovered a 1 day offset
tdata = tdata + tstart;% - 1;
datetimeGas = datetime(tdata,'ConvertFrom','datenum')';
begDoas = datetime( datenum('01-Jan-2002'),'ConvertFrom','datenum');
begNewDoas =  datetime( datenum('01-Jan-2017'),'ConvertFrom','datenum');
idxDoas= datetimeGas >= begDoas & datetimeGas < begNewDoas;
datetimeGas = datetimeGas(idxDoas);
dataGas = gdata( idxDoas );

% Get VT counts
data_file = fullfile( setup.DirMegaplotData, 'fetchedCountVolcstat.mat' );
load( data_file );
dataVT = [CountVolcstatVT.data];
datimVT = [CountVolcstatVT.datim];
datetimeVT = datetime(datimVT,'ConvertFrom','datenum');


daysPre = 120;
daysAft = 120;


nStrings = length( datetimeString );

%diary stringsVgas.out;

for iString = 1:nStrings

    fprintf( "%13s  %7.2e\n", idString(iString), dataString(iString) );

    datetimeThisString = datetimeString(iString );
    
    dtBeg = datetimeThisString - days( daysPre );
    dtEnd = datetimeThisString + days( daysAft );
    tLimits = [dtBeg dtEnd];

    figure('Visible','off');
    figure_size('s',1200);
    tiledlayout( 'vertical' );

    yyaxis left;
    hold on;
    idWant = datetimeGasTrav >= dtBeg & datetimeGasTrav <= dtEnd;
    if sum(idWant) > 0
        errorbar( datetimeGasTrav(idWant), dataGasTrav(idWant), errGasTrav(idWant), ...
            'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'k', 'MarkerSize', 8, ...
            'DisplayName', 'Traverse' );
    end
    idWant = datetimeGas >= dtBeg & datetimeGas <= dtEnd;
    if sum(idWant) > 0
        plot( datetimeGas(idWant), dataGas(idWant), ...
            'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'MarkerSize', 6, ...
            'DisplayName', 'DOAS' );
    end
    %xline( datetimeThisString, 'Color', darkBlue, 'LineWidth', 1, 'LineStyle', '--', 'HandleVisibility','off' );
    xlim( tLimits );
    ylabel( 'SO_{2} flux' );
    yLimits = ylim;
    yLimits(1) = 0;
    if yLimits(2) < 1500
        yLimits(2) = 1500;
    end
    yLimits = [0 5000];
    ylim( yLimits );
    legend( 'Location','northwest');

    yyaxis right;
    idWant = datetimeString >= dtBeg & datetimeString <= dtEnd;
    stem( datetimeString(idWant), dataString(idWant), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', ...
        'LineWidth', 1, 'MarkerSize', 6, 'Color', 'r', 'LineStyle', '-', 'HandleVisibility','off' );
    ylabel( 'String Moment' );
    %set(gca, 'YScale', 'log');   
    xlim( tLimits );
%    ylim( [1.0e+12 3.0e+15] );
    ylim( [0 3.0e+15] );

    box on;
    
    tit = sprintf( "VT string %s  -  %d days before, %d days after", ...
        idString(iString), daysPre, daysAft);
    title( tit );

    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'r';

    filePlot = sprintf( "%s--VT_string-VTrate_gas.png", idString(iString) );
    saveas( gcf, filePlot );

end

%diary off;