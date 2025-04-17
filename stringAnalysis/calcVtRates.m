% Calculates VT rates before and after stings
%
% R.C. Stewart 2024-12-24

clear;
setup = setupGlobals();
reFetch( setup );

dataFile = fullfile( setup.DirMegaplotData, 'fetchedVTstringsPlus.mat' );
load( dataFile );
whats = vtstrings.What;
idWant =  ismember( whats, 'VT string' );

stringId= string( vtstrings.ID( idWant ) );
stringDatimBeg = vtstrings.DatimBeg( idWant );
stringDatimDiff = diff( stringDatimBeg );
stringDatimDiff = [ stringDatimDiff; NaN ];
stringDuration = vtstrings.Duration( idWant );
stringDuration = stringDuration / (24*60);
stringMoment = vtstrings.Moment( idWant );

dataFile = fullfile( setup.DirMegaplotData, 'fetchedHypoSelect.mat' );
load( dataFile );
volctypes = extractfield( Hypo, 'volctype' );
%instrings = extractfield( Hypo, 'isin_string' );
datims = [Hypo.datim];
idWant =  strcmp( volctypes, 't' );
%idWant = idWant & ~instrings;
vtDatim = datims( idWant );

stringVtRat = [];

for istring = 1:length( stringId )

    for month = 1:6

        if istring == length(stringId)
            durCalc = now - (stringDatimBeg(istring) + stringDuration(istring));
        else
            durCalc = 30*month;
        end
        % before
        datimVtEndBef = stringDatimBeg(istring);
        datimVtBegBef = datimVtEndBef - durCalc;
        idWant = vtDatim >= datimVtBegBef & vtDatim < datimVtEndBef;
        nVtBef = sum( idWant );
        
        % after
        datimVtBegAft = stringDatimBeg(istring) + stringDuration(istring);
        datimVtEndAft = datimVtBegAft + durCalc;
        idWant = vtDatim >= datimVtBegAft & vtDatim < datimVtEndAft;
        nVtAft = sum( idWant );

        ratVt = nVtAft / nVtBef;
        stringVtRat(istring,month) = ratVt;


        fprintf( "%13s  %s  %s  %s  %s  %s  %5.2f  %7.2e\n", stringId(istring), ...
            datestr(datimVtBegBef), datestr(datimVtEndBef), ...
            datestr( stringDatimBeg(istring) ), ...
            datestr(datimVtBegAft), datestr(datimVtEndAft), ...
            ratVt, stringMoment(istring) );
        
    end
    
end

save( 'calcVtRates.mat', 'stringMoment', 'stringDatimBeg', 'stringVtRat', 'stringDatimDiff', 'vtDatim' );
