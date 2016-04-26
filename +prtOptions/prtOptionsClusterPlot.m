classdef prtOptionsClusterPlot
    % xxx Need Help xxx





    properties

        nSamplesPerDim = [500 100 20]; % Number of samples to use for plotting
        colorsFunction = @prtPlotUtilClassColors; % Colors function handle

        twoClassColorMapFunction = @prtPlotUtilTwoClassColorMap; % Two class colormap function handle        
    end
    
    methods
        function obj = prtOptionsClusterPlot(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end    
end
