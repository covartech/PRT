classdef prtPreProcHistEq < prtPreProc
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Histogram Equalization'
        nameAbbreviation = 'HistEq'
        isSupervised = false;
    end
    
    properties
        nSamples = inf;
    end
    properties (SetAccess=private)
        % General Classifier Properties
        binEdges = [];
    end
    
    methods
        
        function Obj = prtPreProcHistEq(varargin)
            % Allow for string, value pairs
            % There are no user settable options though.
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            
            if Obj.nSamples == inf;
                Obj.nSamples = DataSet.nObservations;
                Obj.binEdges = sort(DataSet.getObservations);
            else
                for dim = 1:DataSet.nFeatures
                    [~,Obj.binEdges(:,dim)] = hist(DataSet.getObservations(:,dim),Obj.nSamples);
                end
            end
            Obj.binEdges = cat(1,-inf*ones(1,DataSet.nFeatures),Obj.binEdges);
            Obj.binEdges(end+1,:) = inf;
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            X = zeros(DataSet.nObservations,DataSet.nFeatures);
            for index = 1:DataSet.nObservations
                [ii,jj] = find(bsxfun(@gt,DataSet.getObservations(index,:),Obj.binEdges));
                [~,i] = unique(jj);
                ii = ii(i);
                X(index,:) = ii';
            end
            X = X./(size(Obj.binEdges,1)-2);  %-2, one for first, and one for last bin
            DataSet = DataSet.setObservations(X);
        end
        
    end
    
end