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

daysPlusMinus = 200;

magNoLoc = 1.0;
magNoDet = 0.5;

nev = length(Hypo2);
localDatim2 = NaN( 1, nev );
localMoment2 = NaN( 1, nev );
for iev = 1:nev        
    mag = [Hypo2(iev).mag];
    if isnan( mag ) 
        mag = magNoLoc;
    elseif isempty( mag )
        mag = magNoLoc;
    end        
    mw = 0.6667 * mag + 1.15;
    localMoment2(iev) = 10 ^ (1.5 * (mw + 6.07));
    localDatim2(iev) = [Hypo2(iev).datim];        
end

nev = length(Hypo3);
localDatim3 = NaN( 1, nev );
localMoment3 = NaN( 1, nev );
for iev = 1:nev        
    mag = [Hypo3(iev).mag];
    if isnan( mag ) 
        mag = magNoLoc;
    elseif isempty( mag )
        mag = magNoLoc;
    end        
    mw = 0.6667 * mag + 1.15;
    localMoment3(iev) = 10 ^ (1.5 * (mw + 6.07));
    localDatim3(iev) = [Hypo3(iev).datim];        
end

nev = length(Hypo4);
localDatim4 = NaN( 1, nev );
localMoment4 = NaN( 1, nev );
for iev = 1:nev        
    mag = [Hypo4(iev).mag];
    if isnan( mag ) 
        mag = magNoLoc;
    elseif isempty( mag )
        mag = magNoLoc;
    end        
    mw = 0.6667 * mag + 1.15;
    localMoment4(iev) = 10 ^ (1.5 * (mw + 6.07));
    localDatim4(iev) = [Hypo4(iev).datim];        
end

for iString = 1:17
    switch iString
        case 1
            dateString = datenum( 2009, 10, 7, 2, 33, 47 );
        case 2
            dateString = datenum( 2011, 3, 28, 19, 5, 57 );
        case 3
            dateString = datenum( 2012, 3, 23, 7, 10, 14 );
        case 4
            dateString = datenum( 2014, 3, 8, 17, 51, 33 );
        case 5
            dateString = datenum( 2014, 11, 12, 5, 53, 50 );
        case 6
            dateString = datenum( 2015, 12, 25, 1, 12, 57 );
        case 7
            dateString = datenum( 2017, 7, 27, 10, 40, 17);
        case 8
            dateString = datenum( 2019, 4, 10, 22, 3, 23);
        case 9
            dateString = datenum( 2020, 2, 5, 14, 55, 57 );
        case 10
            dateString = datenum( 2020, 12, 31, 3, 57, 34);
        case 11
            dateString = datenum( 2021, 2, 20, 21, 9, 9);
        case 12
            dateString = datenum( 2022, 2, 17, 11, 34, 1);
        case 13
            dateString = datenum( 2022, 7, 30, 15, 52, 7);
        case 14
            dateString = datenum( 2023, 7, 7, 8, 6, 48);
        case 15
            dateString = datenum( 2023, 11, 4, 23, 8, 54);
        case 16
            dateString = datenum( 2024, 4, 29, 13, 43, 42 );
        case 17
            dateString = datenum( 2024, 12, 19, 14, 20, 39 );
    end

    figure( 'visible', 'off' );
    figure_size('l', 1920);
    hold on;

    for iStair = 1:2
        switch iStair
            case 1
                localDatim = localDatim2;
                localMoment = localMoment2;
                col = 'k';
                lab = 'All VTs';
            case 2
                localDatim = localDatim4;
                localMoment = localMoment4;
                col = 'r';
                lab = 'Non-string VTs';
            case 3
                localDatim = localDatim3;
                localMoment = localMoment3;
                col = 'b';
                lab = 'String VTs';
        end

        idWant = localDatim >= dateString-daysPlusMinus & localDatim <= dateString+daysPlusMinus;
        datim = localDatim(idWant) - dateString;
        data = cumsum(localMoment(idWant));
        stairs( datim, data, '-', 'color', col, 'LineWidth', 2.0, 'DisplayName', lab );

    end

    grid on;
    xlim( [-210 210] );
    xlabel( 'Days from string' );
    ylabel( 'Cumulative seismic Moment' );
    title( datestr( dateString) );
    legend( 'Location', 'northwest' )

    fontsize(gcf, 18, 'points');
    fileSave = sprintf( '%s--VT_string-effectOnCumMoment.png', datestr( dateString, 'yyyymmdd-hhMM' ) );
    saveas( gcf, fileSave );

end