classdef prtClassDlrt < prtClass
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
        % Required by prtAction
        name = 'Distance Likelihood Ratio Test'
        nameAbbreviation = 'DLRT'
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
        function Obj = prtClassDlrt(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            Obj.verboseStorage = true;
        end
    end
    
    methods (Access=protected)
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
        end
        
        function DataSetOut = runAction(Obj,TestDataSet)
            
            n = TestDataSet.nObservations;

            uClasses = Obj.DataSet.uniqueClasses;
            classCounts = histc(double(Obj.DataSet.targets),double(uClasses));
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
            
            DataSetOut = prtDataSet(y);
        end
        
    end
end
