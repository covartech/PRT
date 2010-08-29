function colors = prtPlotUtilDarkenColors(colors)

colors = colors - 0.2;
colors(colors < 0) = 0;