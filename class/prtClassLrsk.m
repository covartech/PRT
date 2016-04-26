classdef prtClassLrsk < prtClassLrs & prtClassLrk





    methods

        function self = prtClassLrsk(varargin)
            self = self@prtClassLrs();
            self = self@prtClassLrk();
            
            paramNames = varargin(1:2:end);
            if ismember('includeBias',paramNames)
                warning('prt:prtClassLrsk:includeBiasIgnored','The includeBias parameter is ignored when useing kernel logistic regression');
            end
            
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            
            %self.name = 'Logistic Regression, Sparse Kernel'; % Logistic Regression, Sparse Kernel
            %self.nameAbbreviation = 'LRSK'; % LRK
        end
    end
end
    
