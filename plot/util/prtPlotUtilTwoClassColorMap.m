function cMap = prtPlotUtilTwoClassColorMap(n)
% cMap = prtPlotUtilTwoClassColorMap(n=256)

if nargin < 1 || isempty(n)
    n = 256;
end

PlotOptions = optionsDprtPlot;
colors = feval(PlotOptions.colorsFunction,2);

% Lighten the colors
colors = prtPlotUtilLightenColors(colors);

cMap1 = prtPlotUtilLinspaceColormap(colors(1,:),[1 1 1],floor(n/2));
cMap2 = prtPlotUtilLinspaceColormap([1 1 1],colors(2,:),ceil(n/2));

cMap = cat(1,cMap1,cMap2);