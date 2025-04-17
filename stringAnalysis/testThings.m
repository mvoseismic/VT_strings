% Analyses  VT strings spreadsheet and lists them
%
% RCS 2019-06-06
%

clear;
setup = setupGlobals();
dirStringData = fullfile( setup.DirHome, "STUFF/projectsMVO/Seismicity/VT_strings/data" );

% Stations
stations = [ "MSS1", "MBLG", "MBLY" ];
nstations = length( stations );

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

nString = 780;


% mseed file
fileMseed = sprintf( "%s.mseed", id(nString) );
fileMseed = fullfile( dirStringData, "mseed_files", fileMseed );
if isfile(fileMseed)
    fprintf( "mseed file: %s\n", fileMseed );
else
    fprintf( "mseed file %s\n", "DOES NOT EXIST" );
    return
end

% Time limits for plot
if duration(nString) <= 10
    minPre = 1.0;
    minWin = 12.0;
elseif duration(nString) <= 60
    minPre = 6.0;
    minWin = 66.0;
elseif duration(nString) <= 120
    minPre = 12.0;
    minWin = 132.0;
else
    minPre = 36.0;
    minWin = 396.0;
end

datimBegPlot = datimBeg(nString) - minPre/(24*60);
datimEndPlot = datimBegPlot + minWin/(24*60);

% Read mseed file
signalStruct = ReadMSEEDFast( fileMseed );

sta = 'MSS1';
    
% Find channel
ichannel = 0;
for icha = 1:length( signalStruct )
    if strcmp(signalStruct(icha).station, 'MSS1' ) & strcmp( signalStruct(icha).channel(end), "Z" )
        ichannel = icha;
    end
end

sampleRate = signalStruct(ichannel).sampleRate;
tdata = signalStruct(ichannel).data;
tdatim = signalStruct(ichannel).matlabTimeVector;
    
% Trim data
idWant = tdatim >= datimBegPlot & tdatim <= datimEndPlot;
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
    
% Max data
dataMax = max( abs( data ) );

figure;
figure_size('l');

subplot(5,1,1);
plot(datim0,data);
ylim( [-1.1*dataMax 1.1*dataMax] );
xlim( [datimBegPlot0 datimEndPlot0] );
set(gca,'TickDir','out');
xlabel( 'Minutes' );
box on;

% Envelope
hdata = abs( hilbert( data ) );
if sampleRate == 200
    nwin = 401;
else
    nwin = 201;
end
hdata = nan_rmedian( hdata, nwin );
subplot( 5, 1, 2 );
plot(datim0,hdata);
xlim( [datimBegPlot0 datimEndPlot0] );
ylabel( 'envelope' );
set(gca, 'YScale', 'log')
set(gca,'TickDir','out');
box on;

subplot( 5, 1, 3 );

% Short-time fourier transform
%[s,f,t] = stft( data, sampleRate,'FrequencyRange','onesided' );
%sdb = mag2db(abs(s));
%t0 = t/60 + datim0(1);

% Wavelet transform
[wt,f] = cwt(data,sampleRate);
awt = abs(wt);
sdb = log( awt );
t0 = (0:numel(data)-1)/sampleRate;
t0 = t0/60 + datim0(1);

mesh(t0,f,sdb);
colormap jet;
view(2);
axis tight;
set( gca, 'YScale', 'log' );
set(gca,'TickDir','out');
xlim( [datimBegPlot0 datimEndPlot0] );
ylim( [1 100] );
clim( [0 max(max(sdb))] );
ylabel( 'Frequency (Hz)' );
grid off;
box on;

% Strange seismogram
fdata = data ./ sqrt(hdata);
subplot( 5, 1, 4 );
plot(datim0,fdata);
xlim( [datimBegPlot0 datimEndPlot0] );
set(gca,'TickDir','out');
box on;
    
subplot( 5, 1, 5 );
    
% Short-time fourier transform, strange data
%[s,f,t] = stft( fdata, sampleRate,'FrequencyRange','onesided' );
%sdb = mag2db(abs(s));
%t0 = t/60 + datim0(1);

% Wavelet transform
[wt,f] = cwt(fdata,sampleRate);
awt = abs(wt);
sdb = log( awt );
t0 = (0:numel(fdata)-1)/sampleRate;
t0 = t0/60 + datim0(1);

mesh(t0,f,sdb);
colormap jet;
view(2);
axis tight;
set( gca, 'YScale', 'log' );
set(gca,'TickDir','out');
xlim( [datimBegPlot0 datimEndPlot0] );
ylim( [1 100] );
clim( [0 max(max(sdb))] );
ylabel( 'Frequency (Hz)' );
grid off;
box on;


%{    
    % Wavelet transform
    [wt,f] = cwt(fdata,sampleRate);
    awt = abs(wt);
    awt = log( awt );
    t0 = (0:numel(data)-1)/sampleRate;
    t0 = t0/60 + datim0(1);
    mesh(t0,f,awt);
    colormap jet;
    view(2);
    axis tight;
    set( gca, 'YScale', 'log' );
    set(gca,'TickDir','out');
    xlim( [datimBegPlot0 datimEndPlot0] );
    ylim( [1 100] );
    clim( [0 max(max(awt))] );
    ylabel( 'Frequency (Hz)' );
    grid off;
    box on;
    


    scnl = append( id(nString), '    ', what(nString), '    ', scnl );
    plotOverTitle( scnl );
    nplot = 2 + istation;
    filePlot = append( id(nString), '--', what(nString), '-analysis_', sprintf("%02d-%s",nplot,sta), '.png' );
    filePlot = regexprep(filePlot, ' +', '_');
    saveas( gcf, filePlot );

end
%}
