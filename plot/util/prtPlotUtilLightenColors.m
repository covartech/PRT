function colors = prtPlotUtilLightenColors(colors)

colors = colors + 0.2;
colors(colors > 1) = 1;