classdef prtClassDlrt < prtClass
    % prtClassDlrt  Distance likelihood ratio test classifier
    %
    %    CLASSIFIER = prtClassDlrt returns a Dlrt classifier
    %
    %    CLASSIFIER = prtClassDlrt(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassDlrt object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassDlrt object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %    k                  - The number of neigbors to be considered
    %    distanceFunction   - The function to be used to compute the
    %                         distance from samples to cluster centers. 
    %                         It must be a function handle of the form:
    %                         @(x1,x2)distFun(x1,x2). Most prtDistance*
    %                         functions will work.
    %
    %    For more information on Dlrt classifiers, refer to the
    %    following paper:
    %
    %    Remus, J.J. et al., "Comparison of a distance-based likelihood ratio
    %    test and k-nearest neighbor classification methods" Machine Learning
    %    for Signal Processing, 2008. MLSP 2008. IEEE Workshop on, October,
    %    2008.
    %
    %    A prtClassDlrt object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT method
    %    from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenUniModal;       % Create some test and
    %     TrainingDataSet = prtDataGenUniModal;   % training data
    %     classifier = prtClassDlrt;              % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassDlrt,  prtClass
    
    
    
    
    % prtClassDlrt - Distance to the K Nearest Neighbor classifer
    %
    % prtClassKnn Properties: 
    %   k - number of neighbors to consider
    %   distanceFunction - function handle specifying distance metric
    %
    % prtClassKnn Methods:
    %   prtClassKnn - Logistic Discrminant constructor
    %   train - Logistic discriminant training; see prtAction.train
    %   run - Logistic discriminant evaluation; see prtAction.run
    
    properties (SetAccess=private)
        name = 'Distance Likelihood Ratio Test' % Distance Likelihood Ratio Test
        nameAbbreviation = 'DLRT' % DLRT
        isNativeMary = false;  % False
    end 
    
    properties
 
        k = 3;   % The number of neighbors to consider in the voting
        distanceFunction = @(x1,x2)prtDistanceEuclidean(x1,x2);   % Function handle to compute distance
    end
    
    methods
        function Obj = prtClassDlrt(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            Obj.verboseStorage = true;
        end
    end
    
    methods (Access=protected, Hidden = true)
        function Obj = preTrainProcessing(Obj,DataSet)
            if ~Obj.verboseStorage
                warning('prtClassDlrt:verboseStorage:false','prtClassKnn requires verboseStorage to be true; overriding manual settings');
            end
            Obj.verboseStorage = true;
            Obj = preTrainProcessing@prtClass(Obj,DataSet);
        end
        function Obj = trainAction(Obj,~)
            %Do nothing; we've already specified "verboseStorage = true",
            %so the ".DataSet" field will be set when it comes time to test
            
            % Just one error check to make sure that we have enough
            % training data for our value of k
            assert(all(Obj.DataSet.nObservationsByClass >= Obj.k),'prtClassDlrt:trainAction','prtClassDlrt requires a training set with at least k observations from each class.');
        end
        
        function DataSetOut = runAction(Obj,TestDataSet)
            
            n = TestDataSet.nObservations;

            uClasses = Obj.DataSet.uniqueClasses;
            classCounts = histc(double(Obj.DataSet.getTargets),double(uClasses));
            n0 = classCounts(1);
            n1 = classCounts(2);
            
            y = zeros(n,1);
            
            memBlock = 1000;
            
            if n > memBlock
                for start = 1:memBlock:n
                    indices = start:min(start+memBlock-1,n);
                    
                    dH0 = sort(Obj.distanceFunction(Obj.DataSet.getObservationsByClassInd(1), TestDataSet.getObservations(indices)),1,'ascend');
                    dH0 = dH0(Obj.k,:)';
                    
                    dH1 = sort(Obj.distanceFunction(Obj.DataSet.getObservationsByClassInd(2), TestDataSet.getObservations(indices)),1,'ascend');
                    dH1 = dH1(Obj.k,:)';
                    
                    y(indices) = log(n0./n1) + TestDataSet.nFeatures*log(dH0./dH1);
                end
            else
                dH0 = sort(Obj.distanceFunction(Obj.DataSet.getObservationsByClassInd(1), TestDataSet.getObservations),1,'ascend');
                dH0 = dH0(Obj.k,:)';
                
                dH1 = sort(Obj.distanceFunction(Obj.DataSet.getObservationsByClassInd(2), TestDataSet.getObservations),1,'ascend');
                dH1 = dH1(Obj.k,:)';
                
                y = log(n0./n1) + TestDataSet.nFeatures*log(dH0./dH1);
            end
            
            DataSetOut = prtDataSetClass(y);
        end
        
    end
end
