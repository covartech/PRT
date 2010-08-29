classdef prtRegressPlotOpt
    properties
        nSamplesPerDim = [500 100 20]; % Number of samples to use for plotting
        colorsFunction = @(x)prtPlotUtilDarkenColors(prtPlotUtilClassColors(x)); % Colors function handle
        lineWidth = 2;
    end
    
    methods
        function obj = prtRegressPlotOpt(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end    
end