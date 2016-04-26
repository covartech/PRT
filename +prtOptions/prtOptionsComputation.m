classdef prtOptionsComputation





    properties

        largestMatrixSize = 9e6; % Total number of elements in the matrix (3000 x 3000)
        verboseStorage = true;   % Save's the training dataset within each
                                 % action. True enables easier plotting
                                 % and data exploration.
        showProgressBar = true;
    end
    
    methods
        function obj = prtOptionsComputation(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end
    
    methods
        function obj = set.largestMatrixSize(obj,val)
            assert(prtUtilIsPositiveInteger(val),'largestMatrixSize must be a positive integer');
            
            if val < 1e3
                warning('prt:prtOptionsComputation','Although valid, this value for largestMatrixSize is small. Consider using a larger value.')
            end
            
            obj.largestMatrixSize = val;
        end
    end
end
