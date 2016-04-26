classdef prtUiManagerPlotScatter < prtUiManagerPlot





    properties

        plotSymbolsFunction = @(n)prtPlotUtilClassSymbols(n);
        plotSymbolEdgeModificationFunction = @(color)prtPlotUtilLightenColors(color);
        plotSymbolLineWidth = 1;
        plotSymbolSize = 8;
    end
    properties (Dependent)
        nDataDims
    end
    methods
        function self = prtUiManagerPlotScatter(varargin)
            if nargin
                self = prtUtilAssignStringValuePairs(self, varargin{:});
            end
        end
        function addPlot(self, X)
            
            allColors = self.plotColorsFunction(self.nLines+1);
            allSymbols = self.plotSymbolsFunction(self.nLines+1);
            
            self.hold = 'on';
            newLineHandles = prtPlotUtilScatter(X, {}, allSymbols(end), allColors(end,:), self.plotSymbolEdgeModificationFunction(allColors(end,:)), self.plotSymbolLineWidth, self.plotSymbolSize);
            self.lineHandles = cat(1,self.lineHandles,newLineHandles);
            self.hold = 'off';
            
            self.setAxesConstraints();
        end
    end
end
