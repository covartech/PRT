function colors = prtPlotUtilDarkenColors(colors)
% Internal function, 
% xxx Need Help xxx - see prtUserOptions

colors = colors - 0.2;
colors(colors < 0) = 0;