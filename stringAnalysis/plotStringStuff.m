% Plots the various string parameters.
%
% R.C. Stewart, 09-Apr-2025

clear;
close all;

setup = setupGlobals();
reFetch( setup );

dtBeg = datetime( 2007, 1, 1 );
dtEnd = datetime( 2026, 1, 1 );
tLimits = [ dtBeg dtEnd ];

dataFile = fullfile( setup.DirMegaplotData, 'fetchedVTstringsPlus.mat' );
load( dataFile );
idWant1 = strcmpi( vtstrings.What, "VT string" );
idWant = idWant1;
%idWant2 = strcmpi( vtstrings.What, "mini VT string" );
%idWant2 = vtstrings.Moment >= 5.0e13;
%idWant = idWant1 & idWant2;
vtstrings = vtstrings( idWant,:);
nStrings = height( vtstrings );

dtStrings = datetime( vtstrings.DatimBeg, 'ConvertFrom', 'datenum' );


figure;
figure_size( 'p' );
tiledlayout( 'vertical' );

ax1 = nexttile;
plot( dtStrings, vtstrings.Duration, 'ro', 'MarkerFaceColor', 'r' );
ylabel( 'Duration (minutes)' );
grid on;

ax2 = nexttile;
plot( dtStrings, vtstrings.Moment, 'ro', 'MarkerFaceColor', 'r' );
%set(gca, 'YScale', 'log');
ylabel( 'Seismic Moment (Nm)' );
grid on;

ax3 = nexttile;
plot( dtStrings, vtstrings.MomentRate, 'ro', 'MarkerFaceColor', 'r' );
%set(gca, 'YScale', 'log');
ylabel( 'Seismic Moment Rate (Nm/minute)' );
grid on;

linkaxes( [ax1 ax2 ax3], 'x' );
xlim( tLimits );
plotOverTitle( "All VT Strings" );

figure;
figure_size( 'p' );
tiledlayout( 'vertical' );

ax1 = nexttile;
edges = dtBeg:caldays(30):dtEnd;
histogram( dtStrings, edges );
title( 'Strings per 30 days' );

ax2 = nexttile;
plot( dtStrings, vtstrings.Duration, 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 4 );
title( 'Duration (minutes)' );
grid on;

ax3 = nexttile;
stairs( dtStrings, cumsum(vtstrings.Moment), 'r-', 'LineWidth', 1.0 );
title( 'Cumulative Seismic Moment (Nm)' );
grid on;

linkaxes( [ax1 ax2 ax3], 'x' );
xlim( tLimits );
plotOverTitle( "All VT Strings" );