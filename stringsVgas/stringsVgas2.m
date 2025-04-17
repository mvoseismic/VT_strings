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


figure;
figure_size('p',1800);
tiledlayout( 'vertical' );


for iString = 1:2
    switch iString
        case 1
            datetimeThisString = datetime(2012,3,23,7,10,14);
            idThisString = "20120323-0710";
        case 2
            datetimeThisString = datetime(2024,12,19,14,20,39);
            idThisString = "20241219-1420";
    end

    nexttile;

    dtBeg = datetimeThisString - days( daysPre );
    dtEnd = datetimeThisString + days( daysAft );
    tLimits = [dtBeg dtEnd];

    idWant = datetimeString >= dtBeg & datetimeString <= dtEnd;
    stem( datetimeString(idWant), dataString(idWant), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', ...
        'LineWidth', 1, 'MarkerSize', 6, 'Color', 'r', 'LineStyle', '-', 'HandleVisibility','off' );
    ylabel( 'Total String Moment (Nm)' );
    xlim( tLimits );
    ylim( [0 3.0e+15] );
    box on;
    grid on;
    title( idThisString );


    nexttile;

    hold on;
    idWant = datetimeGasTrav >= dtBeg & datetimeGasTrav <= dtEnd;
    if sum(idWant) > 0
        errorbar( datetimeGasTrav(idWant), dataGasTrav(idWant), errGasTrav(idWant), ...
            'o', 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k', 'MarkerSize', 6, ...
            'DisplayName', 'Traverse' );
    end

    idWant = datetimeGas >= dtBeg & datetimeGas <= dtEnd;
    if sum(idWant) > 0
        plot( datetimeGas(idWant), dataGas(idWant), ...
            'o', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'k', 'MarkerSize', 6, ...
            'DisplayName', 'DOAS' );
    end

    xlim( tLimits );
    ylabel( 'SO_{2} Flux (tonnes/day)' );
    yLimits = [0 5000];
    ylim( yLimits );
    legend( 'Location','northwest');
    xline( datetimeThisString, 'r--', 'HandleVisibility','off' );
    box on;
    grid on;

end

tit = sprintf( "VT strings and SO_{2} flux  -  %d days before, %d days after string", ...
    daysPre, daysAft);
plotOverTitle( tit );

filePlot = "fig--two_VT_strings-VTrate_gas.png";
saveas( gcf, filePlot );