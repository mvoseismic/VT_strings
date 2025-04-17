% VT string stuff
%
% R.C. Stewart, 21-Apr-2020
clear;

setup = setupGlobals();

reFetch( setup );

tenSeconds = 10.0 / (24.0*60.0*60.0);

%magNoLoc = 1.0;
%magNoDet = 0.5;
magNoLoc = -5.0;
magNoDet = -5.0;

data_file = fullfile( setup.DirMegaplotData, 'fetchedHypoSelect.mat' );
load( data_file );

data_file = fullfile( setup.DirMegaplotData, 'fetchedVTstrings.mat' );
load( data_file );

data_file = 'calcVtRates.mat';
load( data_file );
stringVtRateRatio = stringVtRat(:,3);

idStrings = strcmp( vtstring_whats, 'VT string' );
nstrings = sum( idStrings );
stringDatimBeg = vtstring_datim_begs( idStrings );
stringDatimEnd = vtstring_datim_ends( idStrings );
stringDuration = vtstring_durs( idStrings );
stringNSeisan = vtstring_nev_seisans( idStrings );
stringNLoc = vtstring_nev_locateds( idStrings );
stringNTotal = vtstring_nev_totals( idStrings );
%stringNMplus = vtstring_nev_mags( idStrings );
stringMaxMl = vtstring_max_MLs( idStrings );
%stringEnergy = vtstring_energys( idStrings );
%stringSurfaceActivity = vtstring_surface_activitys( idStrings );

istringl = nstrings;
%istringf = istringl - 80;
istringf = 1;

fid = fopen( 'listStrings2.out', 'w' );

for istring = istringf:istringl
    
    stringBeg = stringDatimBeg(istring);
    stringEnd = stringBeg + stringDuration(istring)/(24.0*60.0);
    stringBeg = stringBeg - tenSeconds;
    stringEnd = stringEnd + tenSeconds;
    
    idStringHypo = [Hypo.otime] >= stringBeg & [Hypo.otime] <= stringEnd;
    Hypo2 = Hypo(idStringHypo);
    stringNHypo = length( Hypo2 );
    stringNHypoLoc = sum( [Hypo2.located] == 1 );
    stringMaxMlHypo = max( [Hypo2.mag] );
    
    stringMoment = 0.0;
    
    for iev = 1:length(Hypo2)
        
        mag = [Hypo2(iev).mag];
        %fprintf( '   %3.1f', mag );
        if isnan( mag ) 
            mag = magNoLoc;
        elseif isempty( mag )
            mag = magNoLoc;
        end
        
        %%%%%%%%%%%% HACK
        %if mag >= 2.5
            mw = 0.6667 * mag + 1.15;
            moment = 10 ^ (1.5 * (mw + 6.07));
        
            stringMoment = stringMoment + moment;
        %end
        
    end
    %fprintf( '\n' );
    
    nextra = stringNTotal(istring) - stringNSeisan(istring);
    
    if nextra > 0
        
        for iev = 1: nextra
            
            mw = 0.6667 * magNoDet + 1.15;
            moment = 10 ^ (1.5 * (mw + 6.07));
            
            stringMoment = stringMoment + moment;
            
        end
        
    end
    
    %{
    fprintf( '%20s %20s %5.1f %3d %3d %3d %3d %3.1f %6.2f, %3d\n', ...
        datestr( stringBeg ), ...
        datestr( stringEnd ), ...
        stringDuration( istring ), ...
        stringNSeisan( istring ), ...
        stringNLoc( istring ), ...
        stringNMplus( istring ), ...
        stringNTotal( istring ), ...
        stringMaxMl( istring ), ...
        stringEnergy( istring ), ...
        stringSurfaceActivity( istring ));
    fprintf( '%20s %20s %5.1f %3d %3d %3d %3.1f %3d %3d %3.1f %3d %13.6e\n', ...
        datestr( stringBeg ), ...
        datestr( stringEnd ), ...
        stringDuration( istring ), ...
        stringNSeisan( istring ), ...
        stringNLoc( istring ), ...
        stringNTotal( istring ), ...
        stringMaxMl( istring ), ...
        stringNHypo, ...
        stringNHypoLoc, ...
        stringMaxMlHypo, ...
        nextra, ...
        stringMoment );
    %}
    
    stringBeg = stringBeg + tenSeconds;
    stringEnd = stringEnd - tenSeconds;
    
    stringRate = stringNTotal(istring) / stringDuration(istring);
    stringMomentRate = stringMoment / stringDuration(istring);
    if stringMoment > 3.0e+14
        fprintf( '%19s, %5.1f, %6.0f, %6.1f, %6.1f\n', ...
            datestr( stringBeg, 31 ), ...
            stringDuration( istring ), ...
            stringMoment/1.0e12, ...
            stringMomentRate/1.0e12, ...
            stringVtRateRatio( istring ) );
    end
    %{    
    fprintf( '%20s, %5.1f, %3d, %3d, %3d, %4.2f, %3.1f, %6.2f, %6.2f\n', ...
            datestr( stringBeg ), ...
            stringDuration( istring ), ...
            stringNSeisan( istring ), ...
            stringNLoc( istring ), ...
            stringNTotal( istring ), ...
            stringRate, ...
            stringMaxMl( istring ), ...
            stringMoment/1.0e12, ...
            stringMomentRate/1.0e12 );

    fprintf( fid, '%f,%f,%f\n', datenum(stringBeg), stringMoment, stringMomentRate );
    %}

end
    
fclose(fid);
