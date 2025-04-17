clear;

diary testMemCwt.txt;
diary on;

opengl software;

fs = 200.0;

for i = 16:16

    n = i*fs*60;
    t = 1:n;
    y  = sin(t/1000);

    fprintf( '%2d   %8d   %-20s  %s\n', i, n, 'Start', sysMemory );


    [wt,f] = cwt(y,100.0);
    sdb = abs(wt);
    fprintf( '%2d   %8d   %-20s  %s\n', i, n, 'CWT calculated', sysMemory );

    sdb = log( sdb );
    sdb = decimateArray( sdb, 10 );
    t0 = (0:numel(t)-1)/200;
    t0 = decimate( t0, 10 );

    figure;
    mesh(t0,f,sdb);
    colormap jet;
    view(2);
    fprintf( '%2d   %8d   %-20s  %s\n', i, n, 'CWT plotted', sysMemory );
    

end
    
diary off;
