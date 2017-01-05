classdef prtClassMatlabLinSvm < prtClass
    % prtClassMatlabLinSvm
    % Support vector machine classifier using MATLAB's fitclinear
    
    properties (SetAccess=private)
        name = 'Linear Support Vector Machine';
        nameAbbreviation = 'LinSVM';
        isNativeMary = false;
    end
    
    properties
        mdl
    end
    
    methods
        function self = prtClassLinSvm(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end    
    end
    
    methods (Access=protected, Hidden=true)
        
        function self = trainAction(self,dataSet)
            self.mdl = fitclinear(dataSet.X,dataSet.Y,...
              'Learner','logistic');
        end
        
        function DataSetOut = runAction(self,dataSet)
            DataSetOut = dataSet;
            DataSetOut.X = self.runActionFast(dataSet.X);
        end
        
        function y = runActionFast(self,x)
            [~,scores] = predict(self.mdl,x);
            y = scores;
        end
    end
end

