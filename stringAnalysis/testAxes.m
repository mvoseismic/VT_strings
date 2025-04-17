x = 1:100;
y = sin(x/10);

figure;
t = tiledlayout(1,1);

ax1 = axes(t);
plot(x,y,'k-');

ax2 = axes(t);
plot(ax2,x,y,'k-');
ax2.XAxisLocation = 'top';
xtick( [7 8 9 12 73 84] );
ax2.XTickLabel = {};
ax2.TickDir = 'in';
ax2.XColor = 'r';
ax2.YTick = [];
ax2.XAxisLocation = 'top';
box( ax2, 'XColor', 'k', 'YColor', 'k' );
ax2.TickLength = [0.1 0];

% Link the axes
linkaxes([ax1 ax2], 'x')