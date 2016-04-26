classdef prtPreProcSharpenPerClassTrainingOnly < prtPreProc
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
        
        function self = prtPreProcSharpenPerClassTrainingOnly(varargin)
            % Allow for string, value pairs
            % There are no user settable options though.
            self.isCrossValidateValid = false; %changes data size
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            self.verboseStorage = true;
        end
    end
    
    methods (Access=protected,Hidden=true)
        function self = preTrainProcessing(self,ds)
            if ~self.verboseStorage
                warning('prtClassSharpen:verboseStorage:false','prtPreProcSharpenPerClassTrainingOnly requires verboseStorage to be true; overriding manual settings');
            end
            self.verboseStorage = true;
        end
        
        function self = trainAction(self,ds)
            % Nothing to do.
        end
        
        function ds = runActionOnTrainingData(self,ds)
            
            yMat = logical(ds.getTargetsAsBinaryMatrix);
            X = ds.X;
            newX = X;
            for iClass = 1:ds.nClasses
                obsInds = find(yMat(:,iClass));
                
                cX = X(obsInds,:);
                
                distanceMat = feval(self.distanceFunction, cX, cX);
                
                [~,I] = sort(distanceMat,1,'ascend');
                nearestNeighborInds = I(self.k+1,:); %+1 to remove self-reference

                newX(obsInds,:) = cX(nearestNeighborInds,:);

            end

            ds = ds.setX(newX);

        end
        
        function ds = runAction(self,ds)
            % Nothing
        end
    end
end
