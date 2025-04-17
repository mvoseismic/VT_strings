x = 1:1000;

y = sqrt(x);
plot(x,y,'k-');
hold on;
y = log(x);
plot(x,y,'b-');
y = log10(x);
plot(x,y,'r-');

legend( 'sqrt', 'log', 'log10' );