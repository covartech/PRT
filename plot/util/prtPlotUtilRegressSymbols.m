function classSymbols = prtPlotUtilRegressSymbols(nClasses)

classSymbols = 'os^dv';

classSymbolsInd = repmat((1:length(classSymbols))',ceil(nClasses/length(classSymbols)),1);
classSymbolsInd = classSymbolsInd(1:nClasses);

classSymbols = classSymbols(classSymbolsInd);