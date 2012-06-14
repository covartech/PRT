classdef prtDataSetClassMultipleInstance < prtDataSetClass
    properties
        bag
        bagTarget
        bagInfo
    end
    properties (Dependent)
        nBags
        nObservationsByBag
        nBagsByUniqueClass
    end
        
    methods
        function obj = prtDataSetClassMultipleInstance(varargin)
            %warning('prt:prtDataSetClassMultipleInstance','prtDataSetClassMultipleInstance is incomplete and should not be used at this time');
            
            if nargin == 0
                return;
            end
            if isa(varargin{1},'prtDataSetClassMultipleInstance')
                obj = varargin{1};
                varargin = varargin(2:end);
            end
            
            if length(varargin) >= 1 && isa(varargin{1},'cell');
                obj = obj.setObservationsAndBagsFromCell(varargin{1});
                varargin = varargin(2:end);
                
                if length(varargin) >= 1 && ~isa(varargin{1},'char')
                    if (isnumeric(varargin{1}) || isa(varargin{1},'logical'))
                        obj = obj.setBagTargets(varargin{1});
                        varargin = varargin(2:end);
                    else
                        error('prtDataSet:InvalidTargets','Targets must be a double or logical array; but targets provided is a %s',class(varargin{1}));
                    end
                end
            end
            
            %handle public access to observations and targets, via their
            %pseudonyms.  If these were public, this would be simple... but
            %they are not public.
            dataIndex = find(strcmpi(varargin(1:2:end),'observations'));
            targetIndex = find(strcmpi(varargin(1:2:end),'targets'));
            stringIndices = 1:2:length(varargin);
            
            if ~isempty(dataIndex) && ~isempty(targetIndex)
                obj = prtDataSetClassMultipleInstance(varargin{stringIndices(dataIndex)+1},varargin{stringIndices(targetIndex)+1});
                newIndex = setdiff(1:length(varargin),[stringIndices(dataIndex),stringIndices(dataIndex)+1,stringIndices(targetIndex),stringIndices(targetIndex)+1]);
                varargin = varargin(newIndex);
            elseif ~isempty(dataIndex)
                obj = prtDataSetClassMultipleInstance(varargin{dataIndex+1});
                newIndex = setdiff(1:length(varargin),[stringIndices(dataIndex),stringIndices(dataIndex)+1]);
                varargin = varargin(newIndex);
            elseif ~isempty(targetIndex)
                obj = obj.setBagTargets(varargin{stringIndices(targetIndex)+1});
                newIndex = setdiff(1:length(varargin),[stringIndices(targetIndex),stringIndices(targetIndex)+1]);
                varargin = varargin(newIndex);
            end
            
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        function self = setObservationsAndBagsFromCell(self, val)
            
            nObsPerBag = cellfun(@length,val);
            self.bag = zeros(sum(nObsPerBag),1);
            cEnd = 0;
            for iBag = 1:length(nObsPerBag)
                cBags = iBag*ones(nObsPerBag(iBag),1);
                self.bag(cEnd+(1:nObsPerBag(iBag))) = cBags;
                cEnd = cEnd + nObsPerBag(iBag);
            end
            
            self.data = cell2mat(val); % No error checking on your cell array yet! Make sure this works!
        end
        function self = setBagTargets(self, val)
            self.bagTarget = val;
            
            nObsPerBag = self.nObservationsByBag;
            newTargets = zeros(self.nObservations,1);
            cEnd = 0;
            for iBag = 1:length(nObsPerBag)
                cY = val(iBag)*ones(nObsPerBag(iBag),1);
                newTargets(cEnd+(1:nObsPerBag(iBag))) = cY;
                cEnd = cEnd + nObsPerBag(iBag);
            end
            
            self.targets = newTargets;
        end
        
        function vals = getBagObservations(self,bagInd)
            if islogical(self.bag)
                error('broken')
            else
                vals = cell(length(bagInd),1);
                for iInd = 1:length(bagInd)
                    vals{iInd} = self.data(self.bag==bagInd(iInd),:);
                end
            end
        end
        function vals = getBagTarget(self,bagInd)
            vals = self.bagTarget(bagInd);
        end
        
        function self = setBagObservations(self, newObs,bagInd)
            error('broken');
        end
        function self = setBagTarget(self, newTargs, bagInd)
            error('broken');
        end
        
        function [obj,retainedIndices] = retainObservations(obj,retainedIndices)
            error('broken');
        end
        
        
%         function obj = setTargets(obj,targets,varargin)
%             error('broken')
%         end
        function obj = catObservations(obj,varargin)
            error('broken');
        end
        function obj = catFeatures(obj,varargin)
            error('broken');
        end
        function obj = retainClasses(obj,classes)
            error('broken');
        end
        
        function obj = retainClassesByInd(obj,classInds)
            error('broken');
        end
        function keys = getKFoldKeys(DataSet,K)
            error('broken');
        end
        
        function val = get.nBags(self)
            val = max(self.bag);
        end
        function val = get.nObservationsByBag(self)
            val = histc(self.bag,1:self.nBags);
        end
        function val = get.nBagsByUniqueClass(self)
            uClass = self.uniqueClasses;
            val = zeros(length(uClass),1);
            for iClass = 1:length(uClass)
                val(iClass) = sum(self.bagTarget==uClass(iClass));
            end
        end
    end
% 	methods (Hidden=true, Access='protected')
%         function obj = updateTargetsCache(obj)
%             error('broken');
%         end
%         function obj = updateObservationsCache(obj)
%             error('broken');
%         end
%     end
end