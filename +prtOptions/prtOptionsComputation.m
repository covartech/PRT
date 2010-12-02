classdef prtOptionsComputation
    properties
        largestMatrixSize = 25e6; % Total number of elements in the matrix (3000 x 3000)
        nProcessors = 1; % Number of processors to utilized (beta)
    end
    
    methods
        function obj = prtOptionsComputation(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end    
end