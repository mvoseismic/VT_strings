% Gives info on station data availability for strings.
%
% Version 1.0
% R.C. Stewart, 1-Apr-2022

clear;
setup = setupGlobals();

% Read info from VT_strings spreadsheet
vtStrings = read_string_spreadsheet( setup );

%idWant1 = strcmp( vtStrings.What, 'VT string' );
%idWant2 = strcmp( vtStrings.What, 'mini VT string' );
%idWant3 = strcmp( vtStrings.What, 'VT doublet' );
%idWant4 = strcmp( vtStrings.What, 'VT triplet' );
%idWant = idWant1 | idWant2 | idWant3 | idWant4;
idWant = strcmp( vtStrings.Checked, 'y' );

stations = [ "MSCP"; "MSUH"; "MSS1"; "MBFR"; "MBLG"; "MBLY"; "MBRY"; ...
             "MBBY"; "MBHA"; "MSMX"; "MBGH"; "MBWH"; "MBWW" ];

nsta = length( stations );

for ista = 1:nsta

    status(ista,:) = vtStrings.(stations(ista));

end

status = status(:,idWant);

[size1 size2] = size( status );
[X,Y] = meshgrid(1:size2,1:size1);

status4 = status( 4:7,:);
for iev = 1:length(status4)
    ngoodSta4(iev) = 0;
    for ista = 4:7
        if strcmp( status(ista,iev), '' )
            ngoodSta4(iev) = ngoodSta4(iev) + 1;
        elseif strcmp( status(ista,iev), 's' )
            ngoodSta4(iev) = ngoodSta4(iev) + 1;
        elseif strcmp( status(ista,iev), 'g' )
            ngoodSta4(iev) = ngoodSta4(iev) + 1;
        elseif strcmp( status(ista,iev), 'C' )
            ngoodSta4(iev) = ngoodSta4(iev) + 1;
        elseif strcmp( status(ista,iev), 'f' )
            ngoodSta4(iev) = ngoodSta4(iev) + 1;
        end
    end
end

for iev = 1:length(status)
    ngoodSta(iev) = 0;
    for ista = 1:nsta
        if strcmp( status(ista,iev), '' )
            ngoodSta(iev) = ngoodSta(iev) + 1;
        elseif strcmp( status(ista,iev), 's' )
            ngoodSta(iev) = ngoodSta(iev) + 1;
        elseif strcmp( status(ista,iev), 'g' )
            ngoodSta(iev) = ngoodSta(iev) + 1;
        elseif strcmp( status(ista,iev), 'C' )
            ngoodSta(iev) = ngoodSta(iev) + 1;
        elseif strcmp( status(ista,iev), 'f' )
            ngoodSta(iev) = ngoodSta(iev) + 1;
        end
    end
end


figBig;
hold on;

%{
% Off stations
Z = strcmp( status, 'X' );
XP = X .* Z;
XP(XP==0)=nan;
YP = Y .* Z;
YP(YP==0)=nan;
plot( XP, YP, 'k|' );

% Gap stations
Z = strcmp( status, 'G' );
XP = X .* Z;
XP(XP==0)=nan;
YP = Y .* Z;
YP(YP==0)=nan;
plot( XP, YP, 'b|' );

% Timing stations
Z = strcmp( status, 'T' );
XP = X .* Z;
XP(XP==0)=nan;
YP = Y .* Z;
YP(YP==0)=nan;
plot( XP, YP, 'r|' );

% Fault stations
Z = strcmp( status, 'F' );
XP = X .* Z;
XP(XP==0)=nan;
YP = Y .* Z;
YP(YP==0)=nan;
plot( XP, YP, 'k|' );
%}

% Spike stations
Z = strcmp( status, 's' );
XP = X .* Z;
XP(XP==0)=nan;
YP = Y .* Z;
YP(YP==0)=nan;
plot( XP, YP, 'r|', 'MarkerSize', 10 );

% Good stations
Z = strcmp( status, '' );
XP = X .* Z;
XP(XP==0)=nan;
YP = Y .* Z;
YP(YP==0)=nan;
plot( XP, YP, 'b|', 'MarkerSize', 10 );

% Gap stations
Z = strcmp( status, 'g' );
XP = X .* Z;
XP(XP==0)=nan;
YP = Y .* Z;
YP(YP==0)=nan;
plot( XP, YP, 'r|', 'MarkerSize', 10 );

% Clipped stations
Z = strcmp( status, 'C' );
XP = X .* Z;
XP(XP==0)=nan;
YP = Y .* Z;
YP(YP==0)=nan;
plot( XP, YP, 'g|', 'MarkerSize', 10 );

% Fault stations
Z = strcmp( status, 'f' );
XP = X .* Z;
XP(XP==0)=nan;
YP = Y .* Z;
YP(YP==0)=nan;
plot( XP, YP, 'r|', 'MarkerSize', 10 );


stations = [ "MSCP (0.7km)"; "MSUH (1.0km)"; "MSS1 (1.3km)"; "MBFR (2.0km)"; "MBLG (2.1km)"; "MBLY (2.1km)"; "MBRY (2.4km)"; ...
             "MBBY (3.3km)"; "MBHA (3.5km)"; "MSMX (3.7km)"; "MBGH (3.8km)"; "MBWH (3.9km)"; "MBWW (5.0km)" ];

xlabel( 'VT string number' );
xlim( [-10 size2+10] );
%ylim( [0 nsta+2] );
ylim( [0 nsta+5] );
yticks( 1:nsta );
yticklabels( stations );
h=gca; 
h.YAxis.TickLength = [0 0];
h.XAxis.TickLength = [0 0];
set(h, 'Ydir', 'reverse');
box on;
% crappy legend
%legx = 600;
xLimits = xlim;
legx = xLimits(2) * 0.8;
legy = 0.3;
text( legx, legy, 'Station Status', 'FontWeight', 'bold' );
legy = 0.7;
plot( legx, legy, 'b|', 'MarkerSize', 10 );
text( legx+10, legy, 'Good' );
legy = 1.1;
plot( legx, legy, 'g|', 'MarkerSize', 10 );
text( legx+10, legy, 'Clipped' );
legy = 1.5;
plot( legx, legy, 'r|', 'MarkerSize', 10 );
text( legx+10, legy, 'Faulty' );
boxPos = [ legx-10 0 70 2 ];
rectangle( 'position', boxPos );

yyaxis right;
bar( ngoodSta, 1.0, 'FaceColor', [.7 .7 .7] );
hold on;
bar( ngoodSta4, 1.0, 'k' );
ylim( [0 60] );
yticks( [0 2 4 6 8 10 12] );
%lh = ylabel( 'N stations' );
%lh.Position(1) = size2+20;
%lh.Position(2) = 6;
% crappy legend 2
legx = 500;
legy = 13.7;
text( legx, legy, '# Working Stations', 'FontWeight', 'bold' );
legy = 12;
text( legx, legy, 'from all stations', 'BackgroundColor', [.7 .7 .7] );
legy = 10.3;
text( legx, legy, 'from MBFR, MBLG, MBLY and MBRY', 'Color', 'w', 'BackgroundColor', 'k' );

ax = gca;
ax.YAxis(2).Color = 'k';

%{
dim = [0.06 0.07 0.1 0.1];
str = {'N stations from', 'MBFR, MBLG,', 'MBLY and MBRY'};
annotation('textbox',dim,'String',str,'FitBoxToText','on');
%}
title( 'All "Strings" - Useable Seismic Stations');

for iyr = 2008:2:2022
    
    [fpt,ipt] = min( abs(datenum(vtStrings.DatimFirst) - datenum(iyr,1,1,0,0,0)));

    hxl = xline( ipt, '--', sprintf('%4d', iyr ), ...
        'LineWidth', 0.1, ...
        'LabelOrientation', 'horizontal'  );
    hxl.FontSize = 8;
    hxl.FontAngle = "italic";
    
end
