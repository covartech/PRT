classdef prtPreProcSharpen < prtPreProc
    %







    properties (SetAccess=private)
        % Required by prtAction
        name = 'Sharpening'
        nameAbbreviation = 'SHARP'
    end
    
    properties
        k = 1;
        distanceFunction = @(x1,x2)prtDistanceEuclidean(x1,x2);
    end
    
    methods
        
        function Obj = prtPreProcSharpen(varargin)
            % Allow for string, value pairs
            % There are no user settable options though.
            Obj.isCrossValidateValid = false; %changes data size
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            Obj.verboseStorage = true;
        end
    end
    
    methods (Access=protected,Hidden=true)
        function Obj = preTrainProcessing(Obj,DataSet)
            if ~Obj.verboseStorage
                warning('prtClassSharpen:verboseStorage:false','prtClassSharpen requires verboseStorage to be true; overriding manual settings');
            end
            Obj.verboseStorage = true;
        end
        
        function Obj = trainAction(Obj,DataSet)
            % Nothing to do.
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            memBlock = 1000;
            n = DataSet.nObservations;
            nearestNeighborInds = zeros(n,1);
            if n > memBlock
                for start = 1:memBlock:n
                    indices = start:min(start+memBlock-1,n);
                    
                    distanceMat = feval(Obj.distanceFunction, Obj.dataSet.getObservations, DataSet.getObservations(indices));
                    
                    [~,I] = sort(distanceMat,1,'ascend');
                    nearestNeighborInds(indices) = I(Obj.k+1,:); %+1 to remove self-reference
                end
            else
                distanceMat = feval(Obj.distanceFunction, Obj.dataSet.getObservations(), DataSet.getObservations());
                
                [~,I] = sort(distanceMat,1,'ascend');
                nearestNeighborInds = I(Obj.k+1,:); %+1 to remove self-reference
            end

            DataSet = DataSet.retainObservations(nearestNeighborInds);
        end
    end
end
