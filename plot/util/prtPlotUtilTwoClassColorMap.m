function cMap = prtPlotUtilTwoClassColorMap(n,colors)
% cMap = prtPlotUtilTwoClassColorMap(n=256)
% xxx Need Help xxx







if nargin < 1 || isempty(n)
    n = 256;
end

if nargin < 2 || isempty(colors)
    plotOptions = prtOptionsGet('prtOptionsDataSetClassPlot');
    colors = feval(plotOptions.colorsFunction,2);
end

% Lighten the colors
colors = prtPlotUtilLightenColors(colors);

cMap1 = prtPlotUtilLinspaceColormap(colors(1,:),[1 1 1],floor(n/2));
cMap2 = prtPlotUtilLinspaceColormap([1 1 1],colors(2,:),ceil(n/2));

cMap = cat(1,cMap1,cMap2);
