classdef prtOptionsKernelPlot
    % Internal function
    % xxx Need Help xxx





    properties

        color = [0 0 0];
        markerFaceColor = 'none';
        
        symbol = 'o';
        
        symbolLineWidth = 2;
        symbolSize = 8;
    end
    
    methods
        function obj = prtOptionsKernelPlot(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end    
end
