classdef prtDataSetInMem < prtDataSetBase
    
    properties (SetAccess = protected,GetAccess = protected)
        internalData
        internalTargets
        internalSizeConsitencyCheck = true;
    end
    
    properties (Dependent)
        data  
        targets
    end
    
    methods
        
        function self = set.data(self,input)
            self = self.setData(input);
        end
        
        function self = set.targets(self,input)
            self = self.setTargets(input);
        end
        
        function self = get.data(self)
            self = self.internalData;
        end
        
        function self = get.targets(self)
            self = self.internalTargets;
        end
        
        function self = setObservations(self,data,varargin)
            %             warning('use setData');
            self = self.setData(data,varargin{:});
        end
        
        function self = setObservationsAndTargets(self,data,targets)
            
            if ~(isempty(targets) || isempty(data)) && size(data,1) ~= size(targets,1)
                error('prt:DataTargetsSizeMisMatch','Neither targets nor data is empty, and the number of observations in data (%d) does not match the number of observations in targets (%d)',size(data,1),size(targets,1));
            end
            
            self.internalSizeConsitencyCheck = false;
            self = self.setData(data);
            self = self.setTargets(targets);
            self.internalSizeConsitencyCheck = true;
            self = self.update;
        end
        
        function d = getObservations(self,varargin)
            
            try
                d = self.data(varargin{:});
            catch ME
                prtDataSetBase.parseIndices(self.nObservations,varargin{:});
                throw(ME);
            end
            
        end
        
        
        function self = removeTargets(self,indices)
            if islogical(indices)
                indices = ~indices;
            else
                indices = setdiff(1:self.nTargetDimensions,indices);
            end
            self = self.retainTargets(self,indices);
        end
        
        function self = retainTargets(self,indices)
            self.Y = self.Y(:,indices);
            self.targetNamesInternal = self.targetNamesInternal.retain(indices);
            self = self.update;
        end
        
        function self = catTargets(self,varargin)
             
            if nargin == 1
                return;
            end
            
            for i = 1:length(varargin)
                currInput = varargin{i};
                if ~isa(currInput,'prtDataSetStandard')
                    self.targets = cat(2,self.targets,currInput);
                else
                    self.targets = cat(2,self.targets,currInput.targets);
                end
            end
            
            % Updated chached data info
            self = self.update;
        end
        
        function self = catObservationData(self, varargin)
            
            if nargin == 1
                return;
            end
            
            for i = 1:length(varargin)
                currInput = varargin{i};
                if ~isa(currInput,class(self))
                    %currInput = prtDataSetStandard(currInput);
                    currInput = feval(class(self),currInput); %try to call the constructor
                end
                
                self.internalSizeConsitencyCheck = false;
                self.data = cat(1,self.data,currInput.data);
                self.targets = cat(1,self.targets,currInput.targets);
                self.internalSizeConsitencyCheck = true;
                prtDataSetInMem.checkConsistency(self.internalData,self.internalTargets);
            end
            
            % Updated chached data info
            %             self = updateObservationsCache(self);
            self = self.update;
        end
        
        function nTargets = getNumTargetDimensions(self)
            nTargets = size(self.targets,2);
        end
        
        function n = getNumObservations(self)
            if isempty(self.data)
                n = size(self.targets,1);
            else
                n = size(self.data,1);
            end
        end
        
        function data = getData(self,varargin)
            
            if nargin == 2
                varargin{2} = ':';
            end
            
            try
                data = self.data(varargin{:});
            catch ME
                prtDataSetBase.parseIndices(self.nObservations ,varargin{:});
                rethrow(ME);
            end
        end
        
        function data = getTargets(self,varargin)
            if nargin == 1
                data = self.targets;
                return;
            end
            try
                data = self.targets(varargin{:});
            catch ME
                prtDataSetBase.parseIndices([self.nObservations,self.nTargetDimensions] ,varargin{:});
                rethrow(ME);
            end
        end
        
        function self = setData(self,dataIn,varargin)
            if nargin > 2
                self.internalData(varargin{:}) = dataIn;
            else
                self.internalData = dataIn;
            end
           
            if self.internalSizeConsitencyCheck
                prtDataSetInMem.checkConsistency(self.internalData,self.internalTargets);
            end
            self = self.update;
        end
        
        function self = setTargets(self,dataIn,varargin)
            %check target sizes
            if nargin > 2
                self.internalTargets(varargin{:}) = dataIn;
            else
                self.internalTargets = dataIn;
            end
            
            if self.internalSizeConsitencyCheck
                prtDataSetInMem.checkConsistency(self.internalData,self.internalTargets);
            end
            self = self.update;
        end
        
        function self = retainObservationData(self,indices)
            
            self.internalSizeConsitencyCheck = false;
            try
                self.data = self.data(indices,:);
                if self.isLabeled
                    self.targets = self.targets(indices,:);
                end
            catch  ME
                prtDataSetBase.parseIndices(self.nObservations ,indices);
                rethrow(ME);
            end
            self.internalSizeConsitencyCheck = true;
            self = self.update;
        end
    end
    
    methods (Access = 'protected', Static)
        function checkConsistency(data,targets)
            if ~(isempty(data) || isempty(targets)) && size(data,1) ~= size(targets,1)
                error('prt:DataTargetsSizeMisMatch','Neither targets nor data is empty, and the number of observations in data (%d) does not match the number of observations in targets (%d)',size(data,1),size(targets,1));
            end
        end
    end
end