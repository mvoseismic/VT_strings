clear;
close all;

load( 'calcVtRates.mat' );





idWant = stringMoment > 0.3e+15;


figure;
figure_size( 'l' );
tiledlayout(3,1);

nexttile([2 1]);
hold on;

plot( stringDatimBeg(idWant), stringVtRat(idWant,3), 'ko', 'MarkerFaceColor', [1 0 0], 'MarkerSize', 8 );
plot( stringDatimBeg(end), stringVtRat(end,3), 'ko', 'MarkerFaceColor', [1 0 1], 'MarkerSize', 8 );


xlim( [datenum(2007,1,1,0,0,0) datenum(2025, 1, 1, 0, 0, 0)] );
ylim( [0.3333 3] );
set(gca, 'YScale', 'log')
datetick( 'x', 'keeplimits' );
ylabel( 'After : Before' );
yline( 1 );
title( 'Ratio of number of VTs three months after and three months before VT strings with total Seismic Moment  \geq 0.3 x 10^{15}Nm' );
set(gca,...
    'ytick',[0.5, 1.0, 2.0], ...
    'yticklabel',{'1:2', '1:1', '2:1'} );
set(gca,'YMinorTick','off');
set( gca, 'XGrid', 'on' );
set( gca, 'YGrid', 'on' );
set( gca, 'YMinorGrid', 'off' );
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
box on;

legend( {'3 months', '3 weeks'}, 'Location', 'northwest' );

nexttile;
edges = floor( stringDatimBeg(1) ) : 30 : ceil( stringDatimBeg(end) );
histogram( stringDatimBeg, edges );
xlim( [datenum(2007,1,1,0,0,0) datenum(2025, 1, 1, 0, 0, 0)] );
datetick( 'x', 'keeplimits' );
title( 'VTs per month' );

