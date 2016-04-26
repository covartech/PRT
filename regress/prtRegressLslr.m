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







 
    %
    properties (SetAccess=private)
        name = 'Least Squares Linear Regression' % Least Squares Linear Regression
        nameAbbreviation = 'LSLR'                % LSLR
    end
    
    properties
        % beta is a DataSet.nDimensions + 1 x 1 vector of regression
        % weights estimated via least-squares linear regression.  The first
        % element of beta corresponds to the DC bias weight.
        
        betaPriorAlpha = 0;
        beta = [];  % Regression weights estimated via least squares linear regression
    end
    
    properties (SetAccess = 'protected')
        
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
    properties (Hidden)
        includeDcOffset = true;
        useRobustFitStats = false;
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
            if isscalar(Obj.betaPriorAlpha)
                Obj.betaPriorAlpha = Obj.betaPriorAlpha*eye(size(x,2));
            end
            if Obj.useRobustFitStats
                Obj.beta = robustfit(x,y);
            else
                if ~Obj.includeDcOffset
                    %                 betaTemp = x\y;
                    %                 Obj.beta = cat(1,0,betaTemp);
                    betaTemp = (Obj.betaPriorAlpha + x'*x)^-1*x'*y;
                    Obj.beta = cat(1,0,betaTemp);
                else
                    xCentered = bsxfun(@minus,x,mean(x,1));
                    yCentered = bsxfun(@minus,y,mean(y,1));
                    
                    Obj.beta = (Obj.betaPriorAlpha + xCentered'*xCentered)^(-1) * xCentered'*yCentered;
                    Obj.beta = [mean(y,1) - mean(x,1)*Obj.beta;Obj.beta];
                end
            end
            z = cat(2,ones(size(x,1),1),x);
            
            yHat = z*Obj.beta;
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
        end
        
        function RegressionResults = runAction(Obj,DataSet)
            x = DataSet.getObservations;
            [N,p] = size(x);
            x = cat(2,ones(N,1),x);
            RegressionResults = DataSet.setObservations(x*Obj.beta);
        end
        
        function RegressionResults = runActionFast(Obj,x)
           	
            [N,p] = size(x);
            x = cat(2,ones(N,1),x);
            RegressionResults = x*Obj.beta;
        end
    end
    
end
