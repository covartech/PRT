classdef prtDataSetClassMultipleInstance < prtDataSetInMem & prtDataInterfaceCategoricalTargets
    % prtDataSetImage < prtDataSetInMem & prtDataInterfaceCategoricalTargets
     
    methods (Access = protected)
        function self = update(self)
            % Updated chached target info
            self = updateTargetCache(self);
            % Updated chached data info
            self = updateObservationsCache(self);
        end
    end
    
    properties (Dependent, SetAccess='protected')
        expandedData
        expandedTargets
        bagInds
        nBags
        nTotalObservations
        nObservationsPerBag
    end
    
    methods
        
        function obj = prtDataSetClassMultipleInstance(varargin)
            %obj = prtDataSetImage(varargin)
            obj.data.data = [];
            
            if nargin == 0
                return;
            end
            if isa(varargin{1},'prtDataSetClass')
                obj = varargin{1};
                varargin = varargin(2:end);
            end
            
            %handle first input data:
            if length(varargin) >= 1 && (isa(varargin{1},'struct'))
                obj = obj.setObservations(varargin{1});
                varargin = varargin(2:end);
                %handle first input data, second input targets:
                if length(varargin) >= 1 && ~isa(varargin{1},'char')
                    if (isa(varargin{1},'double') || isa(varargin{1},'logical'))
                        obj = obj.setTargets(varargin{1});
                        varargin = varargin(2:end);
                    else
                        error('prtDataSet:InvalidTargets','Targets must be a double or logical array; but targets provided is a %s',class(varargin{1}));
                    end
                end
            end
           
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
            obj = obj.update;
        end
        
        function val = get.nTotalObservations(self)
            val = getNumTotalObservations(self);
        end
        function nTotObs = getNumTotalObservations(self)
            nTotObs = sum(self.nObservationsPerBag);
        end
            
        function val = get.expandedTargets(self)
            val = getExpandedTargets(self);
        end
        function bigTargets = getExpandedTargets(self)
            nObsPerBag = self.nObservationsPerBag;
            littleTargets = self.targets;
            bigTargets = zeros(self.nTotalObservations,size(littleTargets,2));
            cEnd = 0;
            for iBag = 1:length(nObsPerBag)
                cY = repmat(littleTargets(iBag,:),nObsPerBag(iBag),1);
                bigTargets(cEnd+(1:nObsPerBag(iBag)),:) = cY;
                cEnd = cEnd + nObsPerBag(iBag);
            end            
        end
        function val = get.expandedData(self)
            val = getExpandedData(self);
        end
        function bigData = getExpandedData(self)
            bigData = cat(1,self.data.data);          
        end
        function val = get.bagInds(self)
            val = getBagInds(self);
        end
        function bagInds = getBagInds(self)
            nObsPerBag = self.nObservationsPerBag;
            bagInds = zeros(self.nTotalObservations,1);
            cEnd = 0;
            for iBag = 1:length(nObsPerBag)
                bagInds(cEnd+(1:nObsPerBag(iBag))) = iBag*ones(nObsPerBag(iBag),1);
                cEnd = cEnd + nObsPerBag(iBag);
            end             
        end
        
        function val = get.nBags(self)
            val = getNumBags(self);
        end        
        function nBags = getNumBags(self)
            nBags = self.nObservations;
        end
        function val = get.nObservationsPerBag(self)
            val = getNumObservationsPerBag(self);
        end
        function nOpb = getNumObservationsPerBag(self)
            nOpb = arrayfun(@(s)size(s.data,1),self.data);
        end

        
        function dsClass = toPrtDataSetClass(self)
            dsClass = prtDataSetClass(self.expandedData, self.expandedTargets);
        end
    end 
end