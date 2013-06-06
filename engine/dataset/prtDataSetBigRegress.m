classdef prtDataSetBigRegress < prtDataSetBig
    % prtDataSetBigRegress is a class for prtDataSetBig that are for
    % regression. It is currently a placeholder for future regression
    % specific helper methods.
    
    methods
        function self = prtDataSetBigRegress(varargin)
            self = prtUtilAssignStringValuePairs(self, varargin{:});
        end
    end
end