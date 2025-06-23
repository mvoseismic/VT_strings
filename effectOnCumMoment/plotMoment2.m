clear;
close all;

setup = setupGlobals();
reFetch( setup );

setup.DatimBeg = dateCommon( 'begPhase1' );
setup.PlotBeg = setup.DatimBeg;
setup.DatimEnd = dateCommon( 'now' );
setup.PlotEnd = setup.DatimEnd;

Hypo = getHypo( setup );
Hypo2 = hypoSubset( Hypo, 'LV_vt', [setup.DatimBeg], [setup.DatimEnd] );
Hypo3 = hypoSubset( Hypo, 'LV_str', [setup.DatimBeg], [setup.DatimEnd] );
Hypo4 = hypoSubset( Hypo, 'LV_nst', [setup.DatimBeg], [setup.DatimEnd] );
Hypo = Hypo4;

daysPlusMinus = 200;

magNoLoc = 1.0;
magNoDet = 0.5;

nev = length(Hypo);
localDatim = NaN( 1, nev );
localMoment = NaN( 1, nev );
for iev = 1:nev        
    mag = [Hypo(iev).mag];
    if isnan( mag ) 
        mag = magNoLoc;
    elseif isempty( mag )
        mag = magNoLoc;
    end        
    mw = 0.6667 * mag + 1.15;
    localMoment(iev) = 10 ^ (1.5 * (mw + 6.07));
    localDatim(iev) = [Hypo(iev).datim];        
end

figure;
figure_size( 's', 1920 );
hold on;

for iString = 1:7
    switch iString
        case 1
            dateString = datenum( 2009, 10, 7, 2, 33, 47 );
        case 2
            dateString = datenum( 2012, 3, 23, 7, 10, 14 );
        case 3
            dateString = datenum( 2014, 3, 8, 17, 51, 33 );
        case 4
            dateString = datenum( 2017, 7, 27, 10, 40, 17);
        case 5
            dateString = datenum( 2019, 4, 10, 22, 3, 23);
        case 6
            dateString = datenum( 2020, 2, 5, 14, 55, 57 );
        case 7
            dateString = datenum( 2024, 12, 19, 14, 20, 39 );
    end

    idWant = localDatim >= dateString-daysPlusMinus & localDatim <= dateString+daysPlusMinus;
    datim = localDatim(idWant) - dateString;
    data = cumsum(localMoment(idWant));
    data = data + (iString-1) * 0.5e15;

    stairs( datim, data, 'k-', 'LineWidth', 2.0 );

end

grid on;
xlim( [-210 210] );
xlabel( 'Days from string' );
ylabel( 'Cumulative seismic Moment' );


fontsize(gcf, 18, 'points');
fileSave = "fig--VT_string-effectOnCumMoment.png";
saveas( gcf, fileSave );


