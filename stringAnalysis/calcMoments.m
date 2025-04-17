% Calculates seismic moment for every string and stores them.
%
% R.C. Stewart, 31-Dec-2023

clear;

setup = setupGlobals();

reFetch( setup );

%fileSave = "./stringMoments.mat";

tenSeconds = 10.0 / (24.0*60.0*60.0);

magNoLoc = 1.0;
magNoDet = 0.5;

data_file = fullfile( setup.DirMegaplotData, 'fetchedHypoSelect.mat' );
load( data_file );

data_file = fullfile( setup.DirMegaplotData, 'fetchedVTstrings.mat' );
load( data_file );
vtstring_nev_M3plus = zeros( size( vtstring_nev_seisans ) );
vtstring_nev_M2plus = zeros( size( vtstring_nev_seisans ) );

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
stringId = vtstring_ids( idStrings );

istringl = nstrings;
%istringf = istringl - 80;
istringf = 1;

%momentId = NaN(1,nstrings);
momentMoment = NaN(1,nstrings);
momentRate = NaN(1,nstrings);
nM3plus = NaN(1,nstrings);
nM2plus = NaN(1,nstrings);

fid = fopen( 'stringMoments.csv', 'w' );

for istring = istringf:istringl
    
    stringBeg = stringDatimBeg(istring);
    stringEnd = stringBeg + stringDuration(istring)/(24.0*60.0);
    stringBeg = stringBeg - tenSeconds;
    stringEnd = stringEnd + tenSeconds;
    
    idStringHypo = [Hypo.otime] >= stringBeg & [Hypo.otime] <= stringEnd;
    Hypo2 = Hypo(idStringHypo);
    %stringNHypo = length( Hypo2 );
    %stringNHypoLoc = sum( [Hypo2.located] == 1 );
    %stringMaxMlHypo = max( [Hypo2.mag] );
   
    stringMoment = 0.0;
    
    for iev = 1:length(Hypo2)
        
        mag = [Hypo2(iev).mag];
        if isnan( mag ) 
            mag = magNoLoc;
        elseif isempty( mag )
            mag = magNoLoc;
        end
        
        stringMoment = stringMoment + moment( mag );
        
    end
    
    nextra = stringNTotal(istring) - stringNSeisan(istring);
    
    if nextra > 0
        
        for iev = 1: nextra
            
            stringMoment = stringMoment + moment( magNoDet );
            
        end
        
    end
      
    stringBeg = stringBeg + tenSeconds;
    stringEnd = stringEnd - tenSeconds;
    
    stringRate = stringNTotal(istring) / stringDuration(istring);
    stringMomentRate = stringMoment / stringDuration(istring);

    fprintf( '%s,%f,%f\n', datestr(stringBeg), stringMoment, stringMomentRate );
%    fprintf( fid, '%f,%f,%f\n', datenum(stringBeg), stringMoment, stringMomentRate );
    fprintf( fid, '%s,%20.2f,%20.2f\n', datestr(stringBeg), stringMoment, stringMomentRate );

    momentId(istring) = stringId(istring);
    momentMoment(istring) = stringMoment;
    momentRate(istring) = stringMomentRate;

    if isempty( Hypo2 )
        nM3plus(istring) = 0;
        nM2plus(istring) = 0;
    else
        mags = extractfield( Hypo2, "mag" );
        nM3plus(istring) = sum( mags >= 3.0 );
        nM2plus(istring) = sum( mags >= 2.0 );
    end
 
    
end
    
fclose(fid);


ns = length(vtstring_datim_begs );
vtstring_moments = nan(ns, 1);
vtstring_momentrates = nan(ns, 1);

nm = length( momentMoment );
for im = 1:nm
    id = string( momentId(im) );
    index = find(contains(vtstring_ids,id));
    if index
        vtstring_moments(index) = momentMoment(im);
        vtstring_momentrates(index) = momentRate(im);
        vtstring_nev_M3plus(index) = nM3plus(im);
        vtstring_nev_M2plus(index) = nM2plus(im);
    end

end

% Create table
ID = vtstring_ids;
DatimBeg = vtstring_datim_begs;
Duration = vtstring_durs;
NevTotal = vtstring_nev_totals;
NevLocated = vtstring_nev_locateds;
NevM2plus = vtstring_nev_M2plus;
NevM3plus = vtstring_nev_M3plus;
MaxML = vtstring_max_MLs;
What = vtstring_whats;
Activity = vtstring_activitys;
Repeating = vtstring_repeatings;
Purity = vtstring_puritys;
MSS1 = vtstring_MSS1;
FirstSta = vtstring_first;
Form = vtstring_form;
Comment = vtstring_comment;
Moment = vtstring_moments;
MomentRate = vtstring_momentrates;

vtstrings = table( ID, What, DatimBeg, Duration, NevTotal, NevLocated, NevM2plus, NevM3plus, MaxML, ...
    Moment, MomentRate, ...
    Activity, Repeating, Purity, MSS1, FirstSta, Form, Comment );

dataFile = fullfile( setup.DirMegaplotData, 'fetchedVTstringsPlus.mat' );
save( dataFile, 'vtstrings' );


