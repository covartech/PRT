classdef prtClassMatlabSvm < prtClass
    % prtClassMatlabSvm  Support vector machine classifier using MATLAB's
    % fitcsvm
    
    properties (SetAccess=private)
        name = 'Support Vector Machine'  % Support Vector Machine
        nameAbbreviation = 'SVM'         % SVM
        isNativeMary = false;  % False
    end
    
    properties
        kernel = 'rbf' % AKA 'gaussian'. May also be 'linear' or 'polynomial'
        mdl
    end
    
    methods
        
        function self = prtClassMatlabSvm(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            self.mdl = fitcsvm(dataSet.X,dataSet.Y,'KernelFunction',self.kernel);
        end
        
        function DataSetOut = runAction(self,dataSet)
            DataSetOut = dataSet;
            DataSetOut.X = self.runActionFast(dataSet.X);
        end
        
        function y = runActionFast(self,x)
            [~,y] = predict(self.mdl,x);
        end
        
    end
end

