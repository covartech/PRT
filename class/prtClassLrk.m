classdef prtClassLrk < prtClassLr







    properties 
        % kernel
        kernel = prtKernelDc & prtKernelRbfNdimensionScale;
    end    
    
    methods
        function self = prtClassLrk(varargin)
            self = self@prtClassLr();
            
            paramNames = varargin(1:2:end);
            if ismember('includeBias',paramNames)
                warning('prt:prtClassLrk:includeBiasIgnored','The includeBias parameter is ignored when useing kernel logistic regression');
            end
            
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            
            %self.name = 'Logistic Regression, Kernel'; % Logistic Regression, Kernel
            %self.nameAbbreviation = 'LRK'; % LRK
        end
    end
    
    methods (Hidden)
        function [self, x] = getFeatureMapTrain(self, dataSet)
            self.kernel = train(self.kernel, dataSet);
            
            x = run_OutputDoubleArray(self.kernel, dataSet);
        end
       
        function x = getFeatureMapRun(self, dataSet)
            x = run_OutputDoubleArray(self.kernel, dataSet);
        end
    end
end
