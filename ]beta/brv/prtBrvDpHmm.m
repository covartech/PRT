classdef prtBrvDpHmm < prtBrvHmm





    methods
        function self = prtBrvDpHmm(varargin)
            self.transitionProbabilities = prtBrvDiscreteStickBreaking;
            self.initialProbabilities = prtBrvDiscreteStickBreaking;
            
            self = prtUtilAssignStringValuePairs(self, varargin{:});
        end
    end
end
        
