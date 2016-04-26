classdef prtOptionsDataSetClassPlot
    % Internal function
    % xxx Need Help xxx





    properties

        colorsFunction = @prtPlotUtilClassColors;
        colorsFunctionBw = @prtPlotUtilClassColorsBW; 
        
        symbolsFunction = @prtPlotUtilClassSymbols; 
        symbolsFunctionBw = @prtPlotUtilClassSymbolsBW;
        
        symbolEdgeModificationFunction = @(color)prtPlotUtilSymbolEdgeColorModification(color);
        
        symbolLineWidth = 0.1;
        symbolSize = 8;
        
        starLineWidth = 0.5;
    end
    
    methods
        function obj = prtOptionsDataSetClassPlot(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end    
end
