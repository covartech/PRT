classdef prtDataSetClassPlotOpt
    
    properties
        colorsFunction = @prtPlotUtilClassColors;
        colorsFunctionBw = @prtPlotUtilClassColorsBW; 
        
        symbolsFunction = @prtPlotUtilClassSymbols; 
        symbolsFunctionBw = @prtPlotUtilClassSymbolsBW;
        
        symbolEdgeModificationFunction = @(color)prtPlotUtilSymbolEdgeColorModification(color);
        
        symbolLineWidth = 0.1;
        symbolSize = 4;
        
        starLineWidth = 0.5;
    end
    
    methods
        function obj = prtDataSetClassPlotOpt(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end    
end