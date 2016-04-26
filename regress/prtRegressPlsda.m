classdef prtRegressPlsda < prtRegress
    % prtRegressPlsda  Partial least squares discriminant regression
    %
    %    REGRESS = prtRegressPlsda returns a Partial least squares
    %    discriminant regressor
    %
    %    REGRESS = prtRegressPlsda(PROPERTY1, VALUE1, ...) constructs a
    %    prtRegressPlsda object REGRESS with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtRegressPlsda object inherits all properties from the abstract
    %    Regress prtRegress. In addition is has the following properties:
    %
    %    nComponents  -  The number of components
    %    Bpls         -  The regression weights, estimated during training
    %    xMeans       -  The xMeans, estimated during training
    %    yMeans       -  The yMeana, estimated during training   
    %
    %    For information on the partial least squares discriminant
    %    algorithm, please refer to the following URL:
    %
    %    http://en.wikipedia.org/wiki/Partial_least_squares_regression
    %
    %    A prtRegressPlsda object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT method
    %    from prtRegress.
    %
    %    Example:
    %
    %   TestDataSet = prtDataGenNoisyLine;         % Create some test and 
    %   TrainingDataSet = prtDataGenNoisyLine;     % training data
    %   regress = prtRegressPlsda;                % Create a regressor
    %   regress = regress.train(TrainingDataSet); % Train
    %   regressed = run(regress, TestDataSet);    % Test
    %   regress.plot;
    %
    %    See also prtRegress, prtRegressLslr, prtRegressRvm







    properties (SetAccess=private)
        name = 'Partial Least Squares Discriminant' % Partial Least Squares Discriminant
        nameAbbreviation = 'PLSDA' % PLSDA
        isNativeMary = true;  % True
    end
    
    properties
        % w is a DataSet.nDimensions x 1 vector of projection weights
        % learned during Fld.train(DataSet)
        nComponents = 2;
    end
    
    properties (SetAccess=protected)
        Bpls     % The prediction weights
        loadings % T
        xFactors % P
        yFactors % Q
        yMeansFactor % Factor to be added into regression output (accounts for X means and yMeans);
    end
    
    methods
        
        function Obj = prtRegressPlsda(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.nComponents(Obj,val)
            if ~prtUtilIsPositiveInteger(val)
                error('prt:prtRegressPlsda:nComponents','nComponents must be a positive integer');
            end
            Obj.nComponents = val;
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
                                    
            X = DataSet.getObservations;
            
            Y = DataSet.getY;
            
            maxComps = min(size(X));
            if Obj.nComponents > maxComps;
                Obj.nComponents = maxComps;
            end
            
            xMeans = mean(X,1);
            yMeans = mean(Y,1);
            X = bsxfun(@minus, X, xMeans);
            Y = bsxfun(@minus, Y, yMeans);
            
            [Obj.Bpls, R, Obj.xFactors, Obj.yFactors, Obj.loadings, U] = prtUtilSimpls(X,Y,Obj.nComponents);  %#ok<ASGLU,NASGU>
            
            Obj.yMeansFactor = yMeans - xMeans*Obj.Bpls;
            
            
        end
        
        function DataSet = runAction(Obj,DataSet)
            yOut = bsxfun(@plus,DataSet.getObservations*Obj.Bpls, Obj.yMeansFactor);
            DataSet = DataSet.setObservations(yOut);
        end
        
        function xOut = runActionFast(Obj,xIn,ds) %#ok<INUSD>
           xOut = bsxfun(@plus,xIn*Obj.Bpls, Obj.yMeansFactor);
        end
    end
end
