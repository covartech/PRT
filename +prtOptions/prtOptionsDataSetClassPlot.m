classdef prtOptionsDataSetClassPlot
    % Internal function
    % xxx Need Help xxx





    properties

        colorsFunction = @prtPlotUtilClassColors;
        colorsFunctionBw = @prtPlotUtilClassColorsBW; 
        
        symbolsFunction = @prtPlotUtilClassSymbols; 
        symbolsFunctionBw = @prtPlotUtilClassSymbolsBW;
        
        symbolEdgeModificationFunction = @(color)prtPlotUtilDarkenColors(color);
        
        symbolLineWidth = 1;
        symbolSize = 36;
        markerFaceAlpha = 0.6;
        
        starLineWidth = 0.5;
    end
    
    methods
        function obj = prtOptionsDataSetClassPlot(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end    
end
