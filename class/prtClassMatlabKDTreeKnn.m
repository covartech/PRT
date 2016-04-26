classdef prtClassMatlabKDTreeKnn < prtClass
    % prtClassMatlabKDTreeKnn  K-nearest neighbors classifier using
    % MATLAB's KDTreeSearcher
    %
    %    CLASSIFIER = prtClassMatlabKDTreeKnn returns a K-nearest neighbors
    %       classifier
    %
    %    CLASSIFIER = prtClassMatlabKDTreeKnn(PROPERTY1, VALUE1, ...)
    %    constructs a prtClassMatlabKDTreeKnn object CLASSIFIER with 
    %    properties as specified by PROPERTY/VALUE pairs.
    %
    %    A prtClassMatlabKDTreeKnn object inherits all properties from the
    %    abstract class prtClass. In addition is has the following
    %    properties:
    %
    %    k                  - The number of neigbors to be considered
    %    distanceMetric     - The function to be used to compute the
    %                         distance from samples to cluster centers. 
    %                         It must be a string from the set:
    %                           'euclidean' — Euclidean distance (default)
    %                           'cityblock' — City block distance
    %                           'chebychev' — Chebychev distance
    %                           'minkowski' — Minkowski distance
    %                               If using minkowski, also specify 'P'
    %                               A positive scalar indicating the
    %                               exponent of the Minkowski distance.
    %
    %    bucketSize          - A positive integer, indicating the maximum
    %                          number of data points in each leaf node of
    %                          the kd-tree. Default is 50.
    %
    %    A prtClassMatlabKDTreeKnn object inherits the TRAIN, RUN,
    %    CROSSVALIDATE and KFOLDS methods from prtAction. It also inherits
    %    the PLOT method from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenUnimodal;      % Create some test and 
    %     TrainingDataSet = prtDataGenUnimodal;  % training data
    %     classifier = prtClassMatlabKDTreeKnn;  % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass







    properties (SetAccess=private)
       
        name = 'MATLAB KDTree KNN'   % K-Nearest Neighbor
        nameAbbreviation = 'KDKNN'   % KNN  
        isNativeMary = true;         % true
        
    end
    
    properties
      
        k = 3;   % The number of neighbors to consider in the voting
        
        distanceMetric = 'Euclidean'; % String specifying distance metric
        p = []; % Used when distanceMetric = 'Minkowski'
        bucketSize = 50; % A positive integer, indicating the maximum
                         % number of data points in each leaf node of the
                         % kd-tree. Default is 50.
        
        
        matlabKDTreeSearch = []; % Should be private but left open for
                                 % exploration, be careful.
    end
    
    methods
        function self = prtClassMatlabKDTreeKnn(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        function self = set.k(self,val)
            if ~prtUtilIsPositiveScalarInteger(val)
                error('prt:prtClassMatlabKDTreeKnn:k','k must be a positive scalar integer');
            end
            self.k = val;
        end
        function self = set.bucketSize(self,val)
            if ~prtUtilIsPositiveScalarInteger(val)
                error('prt:prtClassMatlabKDTreeKnn:bucketSize','bucketSize must be a positive scalar integer');
            end
            self.bucketSize = val;
        end
        function self = set.distanceMetric(self,val)
            if ~ischar(val)
                error('prt:prtClassMatlabKDTreeKnn:distanceFunction','distanceMetric must be a string in the set {euclidean,cityblock,chebychev,minkowski}');
            end
            if ~ismember(lower(val),{'euclidean','cityblock','chebychev','minkowski'})
                error('prt:prtClassMatlabKDTreeKnn:distanceMetric','distanceMetric must be a string in the set {euclidean,cityblock,chebychev,minkowski}');
            end 
            self.distanceMetric = val;
        end
    end
    
    methods (Access=protected, Hidden = true)
        function self = preTrainProcessing(self,DataSet)
            if ~self.verboseStorage
                warning('prtClassKnn:verboseStorage:false','prtClassKnn requires verboseStorage to be true; overriding manual settings');
            end
            self.verboseStorage = true;
            self = preTrainProcessing@prtClass(self,DataSet);
        end
        
        function self = trainAction(self,ds)
            
            if strcmpi(self.distanceMetric,'minkowski')
                assert(~isempty(self.p),'When using the minkowski distanceMatric, the additional parameter P must be specified')
                self.matlabKDTreeSearch = KDTreeSearcher(ds.X,'Distance',self.distanceMetric,'p',self.p,'bucketSize',self.bucketSize);
            else
                self.matlabKDTreeSearch = KDTreeSearcher(ds.X,'Distance',self.distanceMetric,'bucketSize',self.bucketSize);
            end
        end
        
        function ds = runAction(self,ds)
            
            neighborInds = self.matlabKDTreeSearch.knnsearch(ds.X,'k',self.k);
            
            closestNeighborY = self.dataSet.Y(neighborInds);
            
            out = zeros(ds.nObservations,self.dataSet.nClasses);
            uY = self.dataSet.uniqueClasses;
            for iY = 1:length(uY)
                out(:,iY) = sum(closestNeighborY==uY(iY),2);
            end
                
            ds = ds.setObservations(out);
        end
    end
end
