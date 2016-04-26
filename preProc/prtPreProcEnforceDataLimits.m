classdef prtPreProcEnforceDataLimits < prtPreProcFunction
    % prtPreProcEnforceDataLimits   Applies a function to observations
    %
    %   



    properties (SetAccess=private)
    end
    properties
        dataLimits = [0 inf];
    end
        
    methods
        function self = prtPreProcEnforceDataLimits(varargin)
            self.operateOnMatrix = true; % Set to true for faster operation, but be careful

            self = prtUtilAssignStringValuePairs(self,varargin{:});
            self.isTrained = true;
        end
        
        function self = set.dataLimits(self,val)
            self.dataLimits = val;
            self.transformationFunction = @(x)cvrEnforceDataLimits(x,self.dataLimits);
        end
    end
    
    
end
