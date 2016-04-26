classdef prtRegressGp < prtRegress
    % prtRegresGP  Gaussian Process regression object
    %
    %   REGRESS = prtRegressGP returns a prtRegressGP object
    %
    %    REGRESS = prtRegressGP(PROPERTY1, VALUE1, ...) constructs a
    %    prtRegressGP object REGRESS with properties as specified by
    %    PROPERTY/VALUE pairs.
    % 
    %    A prtRegressGP object inherits all properties from the prtRegress
    %    class. In addition, it has the following properties:
    %
    %   covarianceFunction = @(x1,x2)prtUtillQuadExpCovariance(x1,x2, 1, 4, 0, 0);
    %   noiseVariance = 0.01;
    %   CN ?
    %   weights?
    %
    %   Need reference 
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
    % legend('Regression curve','Original Points','Fitted points',0)
    %
    %
    %   See also prtRegress, prtRegressRvm, prtRegressLslr







    properties (SetAccess=private)
        name = 'Gaussian Process'
        nameAbbreviation = 'GP'
    end
    
    properties
        % Optional parameters
        
        covarianceFunction = @(x1,x2)prtUtillQuadExpCovariance(x1,x2, 1, 4, 0, 0);
        noiseVariance = 0.01;
        
    end
    % Infered parameters
    properties (SetAccess = protected)
        CN = [];
        weights = [];
    end
    
    methods
        % Allow for string, value pairs
        function Obj = prtRegressGP(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        function Obj = set.noiseVariance(Obj,value)
            assert(isscalar(value) && value > 0,'Invalid noiseVariance specified; noise variance must be scalar and greater than 0, but specified value is %s',mat2str(value));
            Obj.noiseVariance = value;
        end
        function Obj = set.covarianceFunction(Obj,value)
            assert(isa(value,'function_handle'),'Invalid covarianceFunction specified; noise variance must be a function_handle, but specified value is a %s',class(value));
            Obj.covarianceFunction = value;
        end
        function Obj = setVerboseStorage(Obj,value)
            assert(prtUtilIsLogicalScalar(value),'verboseStorage must be a scalar logical');
            if ~value
                warning('prt:prtRegressGp:verboseStorage','prtRegressGp requires verboseStorage to be true. Ignoring request to set to false.');
            end
        end                
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.CN = feval(Obj.covarianceFunction, DataSet.getObservations(), DataSet.getObservations()) + Obj.noiseVariance*eye(DataSet.nObservations);
            
            Obj.weights = Obj.CN\DataSet.getTargets();
        end
        
        function [DataSet,variance] = runAction(Obj,DataSet)
            k = feval(Obj.covarianceFunction, Obj.dataSet.getObservations(), DataSet.getObservations());
            c = diag(feval(Obj.covarianceFunction, DataSet.getObservations(), DataSet.getObservations())) + Obj.noiseVariance;
            
            DataSet = prtDataSetRegress(k'*Obj.weights);
            variance = c - prtUtilCalcDiagXcInvXT(k', Obj.CN);
        end
        
    end
    
end
