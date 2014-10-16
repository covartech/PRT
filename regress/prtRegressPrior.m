classdef prtRegressPrior < prtClass

% Copyright (c) 2014 CoVar Applied Technologies
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
