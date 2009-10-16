function PlotOptions = prtPlotOpt

PlotOptions.nSamplesPerDim = [500 100 20];
PlotOptions.displayFunction = {@imagesc, @imagesc, @slice}; % These are not used for m-ary stuff

PlotOptions.colorsFunction = @dprtClassColors;
PlotOptions.testColorsFunction = @dprtTestClassColors;
PlotOptions.symbolsFunction = @dprtClassSymbols;
PlotOptions.twoClassColorMapFunction = @dprtTwoClassColorMap;

PlotOptions.mappingFunction = [];
PlotOptions.additionalPlotFunction = [];

PlotOptions.nativeMaryPlotFunction = @prtPlotNativeMary;