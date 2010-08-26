classdef prtClassPlsda < prtClass
        % prtClassPlsda  Partial least squares discriminant classifier
    %
    %    CLASSIFIER = prtClassPlsda returns a Partial least squares discriminant classifier
    %
    %    CLASSIFIER = prtClassPlsda(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassMAP object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassPlsda object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %    nComponents  -  The number of components
    %    Bpls         -  The regression weights, estimated during training
    %    xMeans       -  The xMeans, estimated during training
    %    yMeans       -  The yMeana, estimated during training   
    %
    %    For information on the partial least squares discriminant algorithm, please
    %    refer to the following URL:
    %
    %    Need reference 
    %
    %    A prtClassPlsda object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT and
    %    PLOTDECISION classes from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataUniModal;      % Create some test and 
    %     TrainingDataSet = prtDataUniModal;  % training data
    %     classifier = prtClassPlsda;           % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     classes  = classified.getX > .5;
    %     percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassMaryEmulateOneVsAll, prtClassDlrt,
    %    prtClassKnn, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass
    
    
    

    properties (SetAccess=private)
       
        name = 'Partial Least Squares Discriminant' % Partial Least Squares Discriminant
        nameAbbreviation = 'PLSDA' % PLSDA
        isSupervised = true;  % True
        
        isNativeMary = true;  % True
    end
    
    properties
        % w is a DataSet.nDimensions x 1 vector of projection weights
        % learned during Fld.train(DataSet)
        nComponents = 2;
    end
    properties (SetAccess=protected)
        xMeans  % The xMeans
        yMeans  % The yMeans
        Bpls    % The regression weights
    end
    
    methods
        
        function Obj = prtClassPlsda(varargin)
           
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
                                    
            X = DataSet.getObservations;
            if DataSet.nClasses > 2
                Y = DataSet.getTargetsAsBinaryMatrix;
            else
                Y = DataSet.getTargetsAsBinaryMatrix;
                Y = Y(:,2); %0's and 1's for H1
            end
            
            maxComps = min(size(X));
            if Obj.nComponents > maxComps;
                Obj.nComponents = maxComps;
            end
            
            Obj.xMeans = mean(X,1);
            Obj.yMeans = mean(Y,1);
            X = bsxfun(@minus, X, Obj.xMeans);
            Y = bsxfun(@minus, Y, Obj.yMeans);
            
            Obj.Bpls = prtUtilSimpls(X,Y,Obj.nComponents);
        end
        
        function DataSet = runAction(Obj,DataSet)
            yOut = bsxfun(@plus,DataSet.getObservations*Obj.Bpls, Obj.yMeans - Obj.xMeans*Obj.Bpls);
            DataSet = DataSet.setObservations(yOut);
        end
        
    end
    
end