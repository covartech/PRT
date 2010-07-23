classdef prtClassKnn < prtClass
    % prtClassKnn - Logistic discriminant classification
    % object.
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
        % Required by prtAction
        name = 'K-Nearest Neighbor'
        nameAbbreviation = 'KNN'
        isSupervised = true;
        
        % Required by prtClass
        isNativeMary = false;
        
    end 
    
    properties
        % k
        %   K specifies the number of neighbors to consider in the
        %   nearest-neighbor voting.
        k = 3;
        % distanceFunction
        %   Specifies a function handle taking two vector-valued inputs x1
        %   and x2 and outputing a matrix of distances of size size(x1,1) x
        %   size(x2,1).  Most prtDistance* functions are valid here. 
        distanceFunction = @(x1,x2)prtDistanceEuclidean(x1,x2);
    end
    
    methods
        function Obj = prtClassKnn(varargin)
            %Knn = prtClassKnn(varargin)
            %   The KNN constructor allows the user to use name/property 
            % pairs to set public fields of the KNN classifier.
            %
            %   For example:
            %
            %   ds = prtDataUnimodal;
            %   Knn = prtClassKnn;
            %   Knn = Knn.train(ds);
            %   subplot(2,1,1); plot(Knn);
            %
            %   Knn11neighbors = prtClassKnn('k',11);
            %   Knn11neighbors = Knn11neighbors.train(ds);
            %   subplot(2,1,2); plot(Knn11neighbors)
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            Obj.verboseStorage = true;
        end
    end
    
    methods (Access=protected)
        function Obj = preTrainProcessing(Obj,DataSet)
            if ~Obj.verboseStorage
                warning('prtClassKnn:verboseStorage:false','prtClassKnn requires verboseStorage to be true; overriding manual settings');
            end
            Obj.verboseStorage = true;
            Obj = preTrainProcessing@prtClass(Obj,DataSet);
        end
        function Obj = trainAction(Obj,~)
            %Do nothing; we've already specified "verboseStorage = true",
            %so the ".DataSet" field will be set when it comes time to test
        end
        
        function ClassifierResults = runAction(Obj,PrtDataSet)
            
            x = getObservations(PrtDataSet);
            n = PrtDataSet.nObservations;
            
            nClasses = Obj.DataSet.nClasses;
            uClasses = Obj.DataSet.uniqueClasses;
            labels = getTargets(Obj.DataSet);
            y = zeros(n,nClasses);
            
            xTrain = getObservations(Obj.DataSet);
            memBlock = 1000;
            
            if n > memBlock
                for start = 1:memBlock:n
                    indices = start:min(start+memBlock-1,n);
                    
                    distanceMat = feval(Obj.distanceFunction,xTrain,x(indices,:));
                    
                    [~,I] = sort(distanceMat,1,'ascend');
                    I = I(1:Obj.k,:);
                    L = labels(I)';
                    
                    for class = 1:nClasses
                        y(indices,class) = sum(L == uClasses(class),2);
                    end
                end
            else
                distanceMat = feval(Obj.distanceFunction,xTrain,x);
                
                [~,I] = sort(distanceMat,1,'ascend');
                I = I(1:Obj.k,:);
                L = labels(I)';
                
                for class = 1:nClasses
                    y(:,class) = sum(L == uClasses(class),2);
                end
            end
            
            [Etc.nVotes,Etc.MapGuessInd] = max(y,[],2);
            Etc.MapGuess = uClasses(Etc.MapGuessInd);
            ClassifierResults = prtDataSetClass(y);
            
        end
        
    end
end
