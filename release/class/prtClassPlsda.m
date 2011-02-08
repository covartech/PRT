classdef prtClassPlsda < prtClass
    % prtClassPlsda  Partial least squares discriminant classifier
    %
    %    CLASSIFIER = prtClassPlsda returns a Partial least squares
    %    discriminant classifier
    %
    %    CLASSIFIER = prtClassPlsda(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassMAP object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassPlsda object inherits all properties from the abstract
    %    class prtClass. In addition is has the following properties:
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
    %    A prtClassPlsda object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT method
    %    from prtClass.
    %
    %    Example:
    %
    %   TestDataSet = prtDataGenUnimodal;      % Create some test and 
    %   TrainingDataSet = prtDataGenUnimodal;  % training data
    %   classifier = prtClassPlsda;           % Create a classifier
    %   classifier = classifier.train(TrainingDataSet);    % Train
    %   classified = run(classifier, TestDataSet);         % Test
    %   subplot(2,1,1);
    %   classifier.plot;
    %   subplot(2,1,2);
    %   [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %   h = plot(pf,pd,'linewidth',3);
    %   title('ROC'); xlabel('Pf'); ylabel('Pd');
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
    %    prtClassKnn, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass
    
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
        xMeans   % The xMeans
        yMeans   % The yMeans
        Bpls     % The prediction weights
        loadings % T
        xFactors % P
        yFactors % Q
    end
    
    methods
        
        function Obj = prtClassPlsda(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.nComponents(Obj,val)
            if ~prtUtilIsPositiveInteger(val)
                error('prt:prtClassPlsda:nComponents','nComponents must be a positive integer');
            end
            Obj.nComponents = val;
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
                                    
            X = DataSet.getObservations;
            
            Y = DataSet.getTargetsAsBinaryMatrix;
            
            maxComps = min(size(X));
            if Obj.nComponents > maxComps;
                Obj.nComponents = maxComps;
            end
            
            Obj.xMeans = mean(X,1);
            Obj.yMeans = mean(Y,1);
            X = bsxfun(@minus, X, Obj.xMeans);
            Y = bsxfun(@minus, Y, Obj.yMeans);
            
            [Obj.Bpls, ~, Obj.xFactors, Obj.yFactors, Obj.loadings] = prtUtilSimpls(X,Y,Obj.nComponents);
        end
        
        function DataSet = runAction(Obj,DataSet)
            yOut = bsxfun(@plus,DataSet.getObservations*Obj.Bpls, Obj.yMeans - Obj.xMeans*Obj.Bpls);
            DataSet = DataSet.setObservations(yOut);
        end
        
    end
    
end