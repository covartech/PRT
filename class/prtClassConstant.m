classdef prtClassConstant < prtClass







    
    properties (SetAccess=private)
        
        name = 'Constant' % Fisher Linear Discriminant
        nameAbbreviation = 'Constant'            % FLD
        isNativeMary = true;  % False
    end
    
    properties
        constant
    end
    
    methods
        % Allow for string, value pairs
        function self = prtClassConstant(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,ds)
            self.constant = mean(ds.getY);
        end
        
        function ds = runAction(self,ds)
            ds.X = repmat(self.constant,ds.nObservations,1);
        end
        
        
    end
    
end
