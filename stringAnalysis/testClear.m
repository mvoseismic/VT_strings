clear;

unix( 'free -m -L' );
M = ones(10000,100000);
unix( 'free -m -L' );
clear M;
unix( 'free -m -L' );


