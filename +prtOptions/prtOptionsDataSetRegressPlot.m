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
    end
    
    methods
        function obj = prtOptionsDataSetRegressPlot(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end    
end