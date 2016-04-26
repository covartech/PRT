function colors = prtPlotUtilDarkenColors(colors)
% Internal function, 
% xxx Need Help xxx







colors = colors - 0.2;
colors(colors < 0) = 0;
