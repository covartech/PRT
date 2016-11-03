classdef prtClassLinSvm < prtClass
    % prtClassLinSvm
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
            self.mdl = fitPosterior(self.mdl,dataSet.X,dataSet.Y);
        end
        
        function DataSetOut = runAction(self,dataSet)
            guess = predict(self.mdl,dataSet.X);
            DataSetOut = dataSet;
            DataSetOut.X = guess;
        end
        
        function y = runActionFast(self,x)
            [~,scores] = self.predict(self.mdl,x);
            y = scores;
        end
        
        function [labels,scores] = predict(self,mdl,X)
          S = self.score(mdl,X,1);
          scores = [-S,S];
          scores = mdl.PrivScoreTransform(scores);
          labels = nan;
        end
    end
       
    methods (Static, Access=protected, Hidden=true)
        function S = score(mdl,X,obsInRows)
            S = score(mdl.Impl,X,true,obsInRows);
        end
    end
end

