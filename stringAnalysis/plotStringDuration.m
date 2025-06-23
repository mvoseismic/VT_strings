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
figure_size( 'l', 1200 );
plot( dtStrings, vtstrings.Duration, 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 4 );
title( 'VT String Duration (minutes)' );
grid on;

xlim( tLimits );

fileSave = sprintf( "%s.png", mfilename );
saveas( gcf, fileSave );
