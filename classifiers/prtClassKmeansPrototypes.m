classdef prtClassKmeansPrototypes < prtClass
    % prtClassKmeansPrototypes
    %   Unsupervised clustering on data in each hypothesis, then classify
    %   with closest prototype
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'K-Means Prototypes'
        nameAbbreviation = 'K-MeansProto'
        isSupervised = true;
        
        % Required by prtClass
        isNativeMary = true;
    end
    
    properties
        % w is a DataSet.nDimensions x 1 vector of projection weights
        % learned during Fld.train(DataSet)
        nClustersPerHypothesis = 2;
        clusterCenters = {};
        uY = [];
    end
    properties (SetAccess = private)
        fuzzyKMeansOptions = prtUtilOptFuzzyKmeans;
    end
    
    methods
        
        function Obj = prtClassKmeansPrototypes(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access=protected)
        
        function Obj = trainAction(Obj,DataSet)
            
            Obj.uY = unique(DataSet.getTargets);
            Obj.fuzzyKMeansOptions.nClusters = Obj.nClustersPerHypothesis;
            %For each class, extract the Fuzzy K-Means class centers:
            Obj.clusterCenters = cell(1,length(Obj.uY));
            for i = 1:length(Obj.uY)
                Obj.clusterCenters{i} = prtUtilFuzzyKmeans(DataSet.getObservationsByClass(Obj.uY(i)),Obj.fuzzyKMeansOptions);
            end
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            fn = Obj.fuzzyKMeansOptions.distanceMeasure;
            distance = nan(DataSet.nObservations,length(Obj.clusterCenters));
            for i = 1:length(Obj.clusterCenters)
                d = fn(DataSet.getObservations,Obj.clusterCenters{i});
                distance(:,i) = min(d,[],2);
            end
            
            %The smallest distance is the expected class:
            [~,ind] = min(distance,[],2);
            classes = Obj.uY(ind);  %note, use uY to get the correct label
            
            DataSet = DataSet.setObservations(classes);
        end
        
    end
    
end