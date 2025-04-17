clear;

figure;
figure_size( 's' );
tiledlayout( 2, 2 );

for ista = 1:4
    switch ista
        case 1
            sta = "MSS1";
        case 2
            sta = "MBLG";
        case 3
            sta = "MBLY";
        case 4
            sta = "MBRY";
    end

    wants = sprintf( "plotsCumEventAmp/%s*.png", sta );
    fstruct = dir( wants );

    nplot = length( fstruct );

    imgstack = zeros( 1642, 1766 );

    for iplot = 1:nplot

        img = imread( fullfile( fstruct(iplot).folder, fstruct(iplot).name ) );
        imgg = rgb2gray( img );
        imgb = imbinarize( imgg );

        imgstack = imgstack + double( not(imgb) );

    end

    imgstack = log( imgstack );
    maxStack = max( max( imgstack ) );
    imgstack = 255 - (255 * imgstack/maxStack);
    imgstackg = uint8( imgstack );

    nexttile;
    imshow( imgstackg );
    title( sta );

end
