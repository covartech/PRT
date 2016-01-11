classdef prtRegressLslrNonNeg < prtRegress
    %prtRegressLslrNonNeg  Least squares non-negative regression selfect
    %
    %   REGRESS = prtRegressLslrNonNeg returns a prtRegressLslrNonNeg selfect
    %
    %   REGRESS = prtRegressLslrNonNeg(PROPERTY1, VALUE1, ...) constructs a
    %   prtRegressGP selfect REGRESS with properties as specified by
    %   PROPERTY/VALUE pairs.
    % 
    %   A prtRegressLslrNonNeg selfect inherits all properties from the prtRegress
    %   class. In addition, it has the following properties:
    %
    %   beta                   - The regression weights
    %   t                      - A measure of feature importance
    %   rss                    - The residual sum of squares
    %   standardizedResiduals  -  The standardized residuals
    %
    % 
    %   A prtRegressionLslr selfect inherits the PLOT method from the
    %   prtRegress selfect, and the TRAIN, RUN, CROSSVALIDATE and KFOLDS
    %   methods from the prtAction selfect.
    %
    %   See also prtRegress, prtRegressRvm, prtRegressGP, prtRegressLslr

    %
    properties (SetAccess=private)
        name = 'LslrNonNeg' % Least Squares Linear Regression
        nameAbbreviation = 'LslrNonNeg'                % LSLR
    end
    
    properties
        beta = [];  % Regression weights estimated via least squares linear regression
    end
    
    properties (Hidden)
        includeDcOffset = true;
    end

    methods
        
          % Allow for string, value pairs
        function self = prtRegressLslrNonNeg(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            
            x = dataSet.getObservations;
            y = dataSet.getTargets;
            if self.includeDcOffset
                x = cat(2,ones(size(x,1),1),x);
            end
            self.beta = lsqnonneg(x,y);
            if ~self.includeDcOffset
                self.beta = cat(1,0,self.beta);
            end
        end
        
        function dataSet = runAction(self,dataSet)
            x = dataSet.getObservations;
            x = cat(2,ones(size(x,1),1),x);
            yHat = x*self.beta;
            dataSet.X = yHat;
        end
        
        function RegressionResults = runActionFast(self,x)
            RegressionResults = x*self.beta;
        end
    end
        
    methods (Hidden = true)
        function yOut = runStream(self,vector)
            % yOut = runStream(self,vector)
            offset = self.beta(1);
            beta_ = self.beta(2:end);
            betaFilter = cat(1,beta_(:),zeros(size(beta_)));
            yOut = imfilter(vector(:),betaFilter(:),'replicate') + offset;
        end
    end
end
