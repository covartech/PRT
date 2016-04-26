classdef prtOptionsDataSetRegressPlot
    % Internal function
    % xxx Need Help xxx





    properties

        colorsFunction = @prtPlotUtilClassColors; % Colors function handle
        colorsFunctionBw = @prtPlotUtilClassColorsBW;
        
        symbolsFunction = @prtPlotUtilRegressSymbols; 
        symbolsFunctionBw = @prtPlotUtilRegressSymbolsBW;
        
        symbolEdgeModificationFunction = @(color)prtPlotUtilSymbolEdgeColorModification(color);
        
        symbolLineWidth = 0.1;
        symbolSize = 4;
        
        nHistogramBins = 10;
        plotAsClassColorsFunction = @(n)summer(n);
    end
    
    methods
        function obj = prtOptionsDataSetRegressPlot(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end    
end
