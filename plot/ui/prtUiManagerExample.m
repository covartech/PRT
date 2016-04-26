%%





clear classes


ds = prtDataGenBimodal;

obj = prtUiManagerPlotScatter('plotColorsFunction', ds.plotOptions.colorsFunction, ...
                              'plotSymbolsFunction', ds.plotOptions.symbolsFunction, ...
                              'plotSymbolEdgeModificationFunction', ds.plotOptions.symbolEdgeModificationFunction, ...
                              'plotSymbolLineWidth', ds.plotOptions.symbolLineWidth,...
                              'plotSymbolSize', ds.plotOptions.symbolSize);

obj.addPlot(ds.getObservationsByClassInd(1))
obj.addPlot(ds.getObservationsByClassInd(2))


%%
