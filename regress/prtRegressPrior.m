classdef prtRegressPrior < prtClass
   
    properties (SetAccess=private)
        name = 'meh' % Least Squares Linear Regression
        nameAbbreviation = 'blleh'                % LSLR
        isNativeMary = false;
    end
    
    properties
        
        alpha = 0;
        priorCov = 1;
    end
    properties (SetAccess = 'protected')
        
        beta = [];  % Regression weights estimated via least squares linear regression
        
    end
    
    methods
        
          % Allow for string, value pairs
        function self = prtRegressLslr(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function self = trainAction(self,DataSet)
            
            x = DataSet.getObservations;
            y = DataSet.getTargets;
            
            xCentered = bsxfun(@minus,x,mean(x,1));
            yCentered = bsxfun(@minus,y,mean(y,1));
            
            D = cov(xCentered);
            rho = xCentered'*yCentered./size(xCentered,1);
            
            self.beta = (D+self.priorCov^-1*self.alpha)\rho;
            self.beta = [mean(y,1) - mean(x,1)*self.beta;self.beta];
            
        end
        
        function RegressionResults = runAction(self,DataSet)
            x = DataSet.getObservations;
            [N,p] = size(x);
            x = cat(2,ones(N,1),x);
            RegressionResults = DataSet.setObservations(x*self.beta);
        end
        
    end
    
end
