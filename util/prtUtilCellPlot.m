function h = prtUtilCellPlot(xCell,yCell)
%h = prtUtilCellPlot(xCell,yCell)
% Plot data in cell arrays xCell and yCell







xCell = xCell(:);
yCell = yCell(:);
fullCell = cat(1,xCell',yCell');
fullCell = fullCell(:)';
h = plot(fullCell{:});
