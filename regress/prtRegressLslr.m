classdef prtRegressLslr < prtRegress
    %prtRegresLslr  Least squares regression object
    %
    %   REGRESS = prtRegressLslr returns a prtRegressLslr object
    %
    %   REGRESS = prtRegressLslr(PROPERTY1, VALUE1, ...) constructs a
    %   prtRegressGP object REGRESS with properties as specified by
    %   PROPERTY/VALUE pairs.
    % 
    %   A prtRegressLslr object inherits all properties from the prtRegress
    %   class. In addition, it has the following properties:
    %
    %   beta                   - The regression weights
    %   t                      - A measure of feature importance
    %   rss                    - The residual sum of squares
    %   standardizedResiduals  -  The standardized residuals
    %
    % 
    %   A prtRegressionLslr object inherits the PLOT method from the
    %   prtRegress object, and the TRAIN, RUN, CROSSVALIDATE and KFOLDS
    %   methods from the prtAction object.
    %
    %   Example:
    %   
    %   x = [1:.5:10]';                % Create a linear, noisy data set.
    %   y = 2*x + 3 + randn(size(x));
    %   dataSet = prtDataSetRegress;  % Create a prtDataSetRegress object
    %   dataSet= dataSet.setX(x);
    %   dataSet = dataSet.setY(y);
    %   dataSet.plot;                    % Display data
    %   reg = prtRegressLslr;            % Create a prtRegressRvm object
    %   reg = reg.train(dataSet);        % Train the prtRegressRvm object
    %   reg.plot();                      % Plot the resulting curve
    %   dataSetOut = reg.run(dataSet);   % Run the regressor on the data
    %   hold on;
    %   plot(dataSet.getX,dataSetOut.getX,'k*') % Plot, overlaying the
    %                                           % fitted points with the 
    %                                           % curve and original data
    % legend('Regression line','Original Points','Fitted points',0)
    %
    %
    %   See also prtRegress, prtRegressRvm, prtRegressGP

% Copyright (c) 2013 New Folder Consulting
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


 
    %
    properties (SetAccess=private)
        name = 'Least Squares Linear Regression' % Least Squares Linear Regression
        nameAbbreviation = 'LSLR'                % LSLR
    end
    
    properties (SetAccess = 'protected')
        
        % beta is a DataSet.nDimensions + 1 x 1 vector of regression
        % weights estimated via least-squares linear regression.  The first
        % element of beta corresponds to the DC bias weight.
        
        beta = [];  % Regression weights estimated via least squares linear regression
        
        % t is a measure of the importance of each of the
        % DataSet.nDimensions + 1 (DC bias) weights.  The first element of
        % t corresponds to the DC bias term.  
        
        t = []; % Measuer of the importance of each weight
       
        % rss contains the residual sum of squared errors from the training
        % set.
        
        rss = [];  % Resisudal sum of the squared error
        
        % standardizedResiduals are standardized residuals (see Hastie...)
        
        standardizedResiduals = []; % Standardized residuals
        
    end
    
    methods
        
          % Allow for string, value pairs
        function Obj = prtRegressLslr(varargin)
          
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            
            x = DataSet.getObservations;
            y = DataSet.getTargets;
            
            xCentered = bsxfun(@minus,x,mean(x,1));
            yCentered = bsxfun(@minus,y,mean(y,1));
            
            Obj.beta = (xCentered'*xCentered)^(-1) * xCentered'*yCentered;
            Obj.beta = [mean(y,1) - mean(x,1)*Obj.beta;Obj.beta];
            
            z = cat(2,ones(size(xCentered,1),1),xCentered);
            
            yHat = cat(2,ones(size(x,1),1),x)*Obj.beta;
            e = yHat - y;
            Obj.rss = sum(e(:).^2);
            sigmaHat = sqrt(Obj.rss./(size(x,1) - size(x,2) - 1));
            
            if size(x,1) < 1000
                % this can be expensive to calculate
                H = z*(z'*z)^(-1)*z';
                Obj.standardizedResiduals = bsxfun(@rdivide,e,(sigmaHat*(1-diag(H)).^(1/2)));
            else
                Obj.standardizedResiduals = nan;
            end
            
            Obj.t = bsxfun(@rdivide,Obj.beta,sigmaHat*sqrt(diag((z'*z)^(-1))));
            
            Obj.standardizedResiduals = Obj.standardizedResiduals;

        end
        
        function RegressionResults = runAction(Obj,DataSet)
            x = DataSet.getObservations;
            [N,p] = size(x);
            x = cat(2,ones(N,1),x);
            RegressionResults = DataSet.setObservations(x*Obj.beta);
        end
        
    end
    
end
