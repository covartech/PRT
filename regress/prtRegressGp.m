classdef prtRegressGp < prtRegress
    % prtRegresGP  Gaussian Process regression object
    %
    %   REGRESS = prtRegressGP returns a prtRegressGP object
    %
    %   REGRESS = prtRegressGP(PROPERTY1, VALUE1, ...) constructs a
    %   prtRegressGP object REGRESS with properties as specified by
    %   PROPERTY/VALUE pairs.
    % 
    %   A prtRegressGP object inherits all properties from the prtRegress
    %   class. In addition, it has the following properties:
    %
    %   covarianceFunction = @(x1,x2)prtUtilQuadExpCovariance(x1,x2, 1, 4, 0, 0);
    %       See: prtUtilQuadExpCovariance
    %
    %   meanRegressor (none) - A prtRegress object to be used to estimate
    %       dataSet.Y from dataSet.X.  The GP object is then used to model
    %       any residual error between the meanRegressor and the targets.
    %
    %   M Ebden. Gaussian processes for regression: a quick introduction.
    %   2008. https://arxiv.org/abs/1505.02965
    % 
    %   A prtRegressionGP object inherits the PLOT method from the
    %   prtRegress object, and the TRAIN, RUN, CROSSVALIDATE and KFOLDS
    %   methods from the prtAction object.
    %
    %   Example:
    %   
    %   dataSet = prtDataGenNoisySinc;           % Load a prtDataRegress
    %   dataSet.plot;                    % Display data
    %   reg = prtRegressGP;             % Create a prtRegressRvm object
    %   reg = reg.train(dataSet);        % Train the prtRegressRvm object
    %   reg.plot();                      % Plot the resulting curve
    %   dataSetOut = reg.run(dataSet);   % Run the regressor on the data
    %   hold on;
    %   plot(dataSet.getX,dataSetOut.getX,'c.') % Plot, overlaying the
    %                                           % fitted points with the 
    %                                           % curve and original data
    %   legend('Regression curve','Original Points','Fitted points',0)
    %
    %
    %   Example 2:
    %   
    %     ds = prtDataGenNoisyLine('slope',10,'xRange',[-1 5]);
    %     ds = ds.retainObservations(ds.X < 2 | ds.X > 4);
    %     r = prtRegressGp;
    %     r = r.train(ds);
    %     rLinear = prtRegressGp('meanRegressor',prtRegressLslr);
    %     rLinear = rLinear.train(ds);
    %     subplot(2,1,1); plot(r)
    %     subplot(2,1,2); plot(rLinear)
    %
    %
    %   See also prtRegress, prtRegressRvm, prtRegressLslr




    properties (SetAccess=private)
        name = 'Gaussian Process'
        nameAbbreviation = 'GP'
        
    end
    
    properties
        meanRegressor = [];  % If non-empty, use this regressor first, then regress a GP onto the residual error
        
        refineParameters = false;
        covarianceFunctionParameters = [1, 4, 0, 0]'; % covariance function parameters
        includeVarianceInX = false;
        
        covarianceFunction = @(x1,x2,params)prtUtilQuadExpCovariance(x1,x2,params);
        noiseVariance = 0.01;
        
    end
    
	% Inferred parameters
    properties (SetAccess = protected)
        CN = [];
        weights = [];
    end
    
    methods
        % Allow for string, value pairs
        function self = prtRegressGp(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
		end
        function self = set.noiseVariance(self,value)
            assert(isscalar(value) && value > 0,'Invalid noiseVariance specified; noise variance must be scalar and greater than 0, but specified value is %s',mat2str(value));
            self.noiseVariance = value;
        end
        function self = set.covarianceFunction(self,value)
            assert(isa(value,'function_handle'),'Invalid covarianceFunction specified; noise variance must be a function_handle, but specified value is a %s',class(value));
            self.covarianceFunction = value;
        end
        function self = setVerboseStorage(self,value)
            assert(prtUtilIsLogicalScalar(value),'verboseStorage must be a scalar logical');
            if ~value
                warning('prt:prtRegressGp:verboseStorage','prtRegressGp requires verboseStorage to be true. Ignoring request to set to false.');
            end
        end                
    end
    
	methods (Hidden)
		% Used to train/run the .meanRegressor object and calculate the residual error
        function self = trainMeanRegressor(self,dataSet)
            if ~isempty(self.meanRegressor)
                self.meanRegressor = self.meanRegressor.train(dataSet);
            end
        end
        function [dataSetEst,dataSetTargetResiduals] = runMeanRegressor(self,dataSet)
            % Run the mean-regressor object and make:
            %   dataSetEst - The output of the mean-regressor run on the
            %   dataSet
            %
            %   dataSetTargetResiduals - The same dataSet, but with the
            %   targets (Y) replaced with the residual error:
            %       dataSet.Y - dataSetEst.X
            if ~isempty(self.meanRegressor)
                dataSetEst = self.meanRegressor.run(dataSet);
            else
<<<<<<< Updated upstream
                % The mean regressor will output dataSet.X of the same size
                % as dataSet.Y, with all zeros!  dataSetEst.Y should be
                % dataSet.Y.  Note - at test-time, there may not be
                % dataSet.Y (e.g., running on new testing data).
                % prtRegressGp assumes that the number of desired targets
                % (size(dataSet.Y,2)) is 1, even if there werent any
                % targets provided (dataSet.Y is empty)
                dataSetEst = prtDataSetRegress(zeros(size(dataSet.X,1),1),dataSet.Y);
=======
                dataSetEst = prtDataSetRegress(zeros(dataSet.nObservations,1),zeros(dataSet.nObservations,1));
>>>>>>> Stashed changes
            end
            dataSetTargetResiduals = dataSet;
            if nargout > 1
                dataSetTargetResiduals.Y = dataSet.Y - dataSetEst.X;
            end
        end
    end
    methods (Access = protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            
            self = self.trainMeanRegressor(dataSet);
            [~,dataSetTargetResiduals] = self.runMeanRegressor(dataSet);
            
            if self.refineParameters
                self.covarianceFunctionParameters = fminsearch(@(params)-self.loglike(dataSetTargetResiduals.Y,self.covarianceFunction2(dataSetTargetResiduals,params)),self.covarianceFunctionParameters);
            end
            self.CN = self.covarianceFunction2(dataSetTargetResiduals, self.covarianceFunctionParameters);
            
            self.weights = self.CN\dataSetTargetResiduals.getTargets();
        end
        
        function [dataSet,variance] = runAction(self,dataSet)
            dataSetEst = runMeanRegressor(self,dataSet);
            
            k = feval(self.covarianceFunction, self.dataSet.getObservations(), dataSet.getObservations(), self.covarianceFunctionParameters);
            c = diag(feval(self.covarianceFunction, dataSet.getObservations(), dataSet.getObservations(), self.covarianceFunctionParameters)) + self.noiseVariance;
            
            dataSet = prtDataSetRegress(k'*self.weights);
            dataSet.X = dataSet.X + dataSetEst.X;
            variance = c - prtUtilCalcDiagXcInvXT(k', self.CN);
            if self.includeVarianceInX
                dataSet.X = cat(2,dataSet.X,variance);
            end
            %             dataSet.actionData.variance = variance;
        end
        
        function K = covarianceFunction2(self,dataSet,params)
            % with the additional variance term
            
            K = self.covarianceFunction(dataSet.getObservations(), dataSet.getObservations(), params)...
                + self.noiseVariance*eye(dataSet.nObservations);
        end
    end
    
    methods (Static)
        function val = loglike(x,Sigma)
            % multivariate Gaussian log likelihood
            % mean is assumed zero
            
            x = x(:); % ensure that x is a column vector
            val = -1/2*x'/Sigma*x-1/2*log(det(Sigma))-length(x)/2*log(2*pi);
        end
    end
    
end
