clear;

setup = setupGlobals();
dirStringData = fullfile( setup.DirHome, "STUFF/projectsMVO/Seismicity/VT_strings/data" );

% Read info from VT_strings spreadsheet
vtStrings = read_string_spreadsheet( setup );
tmp = vtStrings.Id;
id = string( tmp );
ntotal = vtStrings.NumTotal;

nstrings = length(id);

for istring = 1:nstrings

    % Read info from event list file
    dirEventLists = fullfile( setup.DirSeismicity, 'VT_strings/data/event_lists' );
    fileEventList = strcat( id(istring), '.txt' );
    fileEventList = fullfile( dirEventLists, fileEventList );

    fprintf( "%13s  %4d  ", id(istring), ntotal(istring) );
    if isfile( fileEventList )
        events = readtable( fileEventList, 'NumHeaderLines', 0, 'ReadVariableNames', 0, 'ExpectedNumVariables',7);
        fprintf( "%3d %3d\n", size(events) );
    else
        fprintf( "File does not exist\n" );
    end

end
