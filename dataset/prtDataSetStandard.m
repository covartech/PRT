classdef prtDataSetStandard < prtDataSetBase
    % prtDataSetStandard < prtDataSetBase
    %   Base class for all prt DataSets that can be held in memory
    %
    % prtDataSetBase Properties: 
    %   ObservationDependentUserData - I think the gets and sets for this need to
    %          be in prtDataSetBase and be abstract; the current interface allows
    %          people to see the struct...
    %
    % methods:
    %   getObservations - Return an array of observations
    %   setObservations - Set the array of observations
    %   
    %   getTargets - Return an array of targets (empty if unlabeled)
    %   setTargets - Set the array of targets
    %
    %   catFeatures - Combine the features from a data set with additional data
    %   catObservations - Combine the Observations from a data set with additional data
    %
    %   removeObservations - Remove observations from a data set
    %   retainObservations - Retain observatons (remove all others) from a data set
    %   replaceObservations - Replace observatons in a data set
    %
    %   removeFeatures - Remove features from a data set
    %   retainFeatures - Remove features (remove all others) from a data set
    %   replaceFeatures - Replace features in a data set
    %
    %   bootstrap
    %
    %   export - 
    %   plot - 
    %   summarize - 
    
    properties (Dependent)
        nObservations         % size(data,1)
        nFeatures             % size(data,2)
        nTargetDimensions     % size(targets,2)
    end
    
    properties
        ObservationDependentUserData = [];
    end
    
    properties (SetAccess='protected',GetAccess ='protected')
        data = [];
        targets = [];
    end
    
    methods
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = prtDataSetStandard(varargin)
            % Nothing to do.
            % This should only be called when initializing a sub-class
        end
        
        
        function [data,targets] = getObservationsAndTargets(obj,varargin)
            %[data,targets] = getObservationsAndTargets(obj,indices1)
            
            [indices1, indices2, indices3] = prtDataSetBase.parseIndices([obj.nObservations, obj.nFeatures obj.nTargetDimensions],varargin{:});
            
            data = obj.getObservations(indices1, indices2);
            targets = obj.getTargets(indices1, indices3);
        end
        
        function obj = setObservationsAndTargets(obj,data,targets)
            if ~isempty(targets) && size(data,1) ~= size(targets,1)
                error('prtDataSet:invalidDataTargetSet','Incompatible data/targets sizes');
            end
            obj.data = data;
            obj.targets = targets;
        end
        
        %data = getObservations(obj,indices1,indices2)
        function data = getObservations(obj,varargin)
            %data = getObservations(obj)
            %data = getObservations(obj,indices1,indices2)
            
            if nargin == 1
                % No indicies identified. Quick exit
                data = obj.data;
                return
            end
            
            [indices1, indices2] = prtDataSetBase.parseIndices([obj.nObservations, obj.nFeatures],varargin{:});
            
            data = obj.data(indices1,indices2);
        end
        
        %obj = setObservations(obj,data)
        function obj = setObservations(obj, data, varargin)
            %obj = setObservations(obj,data)

            if nargin < 3
                % Setting the entire data matrix
                if obj.isLabeled && obj.nObservations ~= size(data,1)       
                    error('prtDataSet:invalidDataTargetSet','Attempt to change size of observations in a labeled data set; use setObservationsAndTargets to change both simultaneously');
                end
                obj.data = data;            
            else
                % Setting only specified entries of the matrix
                [indices1, indices2] = prtDataSetBase.parseIndices([obj.nObservations, obj.nFeatures],varargin{:});
                
                obj.data(indices1,indices2) = data;
            end
        end
        
        %targets = getTargets(obj,indices1,indices2)
        function targets = getTargets(obj,varargin)
            %targets = getTargets(obj)
            %targets = getTargets(obj,indices1,indices2)
            
            if nargin == 1
                % No indicies identified. Quick exit
                targets = obj.targets;
                return
            end
            
            if obj.isLabeled
                [indices1, indices2] = prtDataSetBase.parseIndices([obj.nObservations, obj.nTargetDimensions],varargin{:});
            
                targets = obj.targets(indices1,indices2);
            else
                targets = [];
            end
        end
        
        %obj = setTargets(obj,targets)
        function obj = setTargets(obj,targets,varargin)
            %obj = setTargets(obj,targets)
            
            if nargin < 3
                % Setting the entire data matrix
                if ~isempty(targets) && obj.nObservations ~= size(targets,1)       
                    error('prtDataSet:invalidDataTargetSet','Attempt to change size of targets for a labeled data set; use setObservationsAndTargets to change both simultaneously');
                end
                obj.targets = targets;           
            else
                % Setting only specified entries of the matrix
                [indices1, indices2] = prtDataSetBase.parseIndices([obj.nObservations, obj.nTargetDimensions],varargin{:});
                
                obj.targets(indices1,indices2) = targets;
            end
            
            
        end
        
        %obj = catObservations(obj, dataSet1, dataSet1, ...)
        function obj = catObservations(obj, varargin)
            %obj = catObservations(obj, dataSet1, dataSet1, ...)
            if nargin == 1
                return;
            end
            warning('prt:Fixable','Doesn''t handle observations names');
            
            for argin = 1:length(varargin)
                currInput = varargin{argin};
                if currInput.isLabeled ~= obj.isLabeled
                    error('prtDataSet:invalidConcatenation','Attempt to combine labeled and unlabeled data sets in cat Observations');
                end
                obj.data = cat(1,obj.data,currInput.getObservations);
                obj.targets = cat(1,obj.targets,currInput.getTargets);
            end
        end
        
        %[obj,retainedIndices] = removeObservations(obj,removeIndices)
        function [obj,retainedIndices] = removeObservations(obj,removeIndices)
            %[obj,retainedremoveIndices] = removeObservations(obj,removeIndices)
            warning('prt:Fixable','Does not handle observation names');
            
            removeIndices = prtDataSetBase.parseIndices(obj.nObservations ,removeIndices);
            
            if islogical(removeIndices)
                keepObservations = ~removeIndices;
            else
                keepObservations = setdiff(1:obj.nObservations,removeIndices);
            end
            
            
            [obj,retainedIndices] = retainObservations(obj,keepObservations);
        end
        
        %[obj,retainedIndices] = retainObservations(obj,retainedIndices)
        function [obj,retainedIndices] = retainObservations(obj,retainedIndices)
            %[obj,retainedIndices] = retainObservations(obj,retainedIndices)
            warning('prt:Fixable','Does not handle observation names');
            
            retainedIndices = prtDataSetBase.parseIndices(obj.nObservations ,retainedIndices);
            
            obj.data = obj.data(retainedIndices,:);
            if obj.isLabeled
                obj.targets = obj.targets(retainedIndices,:);
            end
            
            if ~isempty(obj.ObservationDependentUserData)
                obj.ObservationDependentUserData = obj.ObservationDependentUserData(retainedIndices);
            end
        end
        
        %[obj,retainedFeatures] = removeFeatures(obj,removeIndices)
        function [obj,retainedFeatures] = removeFeatures(obj,removeIndices)
            %[obj,retainedFeatures] = removeFeatures(obj,removeIndices)
            warning('prt:Fixable','Does not handle feature names');
            
            removeIndices = prtDataSetBase.parseIndices(obj.nFeatures ,removeIndices);
            
            if islogical(removeIndices)
                keepFeatures = ~removeIndices;
            else
                keepFeatures = setdiff(1:obj.nFeatures,removeIndices);
            end
            [obj,retainedFeatures] = retainFeatures(obj,keepFeatures);
        end
        
        %[obj,retainedFeatures] = retainFeatures(obj,retainedFeatures)
        function [obj,retainedFeatures] = retainFeatures(obj,retainedFeatures)
            %[obj,retainedFeatures] = retainFeatures(obj,retainedFeatures)
            warning('prt:Fixable','Does not handle feature names');
            
            retainedFeatures = prtDataSetBase.parseIndices(obj.nFeatures ,retainedFeatures);
            
            obj.data = obj.data(:,retainedFeatures);
        end
        
        function data = getFeatures(obj,varargin)
            warning('prt:Fixable','Does not handle feature names');
            data = obj.getObservations(varargin{:});
        end
        
        function obj = setFeatures(obj,data,varargin)
            warning('prt:Fixable','Does not handle feature names');
            obj = obj.setObservations(data,varargin{:});
        end
        
        %obj = catFeatures(obj, dataArray1, dataArray2,...)
        %obj = catFeatures(obj, dataSet1, dataSet2,...)
        function obj = catFeatures(obj, varargin)
            %obj = catFeatures(obj, dataArray1, dataArray2,...)
            %obj = catFeatures(obj, dataSet1, dataSet2,...)
            warning('prt:Fixable','Does not handle feature names');
            
            if nargin == 1
                return;
            end
            for argin = 1:length(varargin)
                currInput = varargin{argin};
                if isa(currInput,class(obj.data))
                    obj.data = cat(2,obj.data, newData);
                elseif isa(currInput,prtDataSetStandard)
                    obj.data = cat(2,obj.data,currInput.getObservations);
                end
            end
        end
        
        function obj = bootstrap(obj,nSamples)
            %obj = bootstrap(obj,nSamples)
            sampleIndices = ceil(rand(1,nSamples).*obj.nObservations);
            
            newData = obj.getObservations(sampleIndices,:);
            
            if obj.isLabeled
                newTargets = obj.getTargets(sampleIndices,:);
                obj.data = newData;
                obj.targets = newTargets;
            else
                obj.data = newData;
            end
        end
        
        function nObservations = get.nObservations(obj)
            nObservations = size(obj.data,1); %use InMem's .data field
        end
        
        function nFeatures = get.nFeatures(obj)
            nFeatures = size(obj.data,2);
        end
        
        function nTargetDimensions = get.nTargetDimensions(obj)
            %nTargetDimensions = get.nTargetDimensions(obj)
            nTargetDimensions = size(obj.targets,2); %use InMem's .data field
        end
        
        
        function obj = set.ObservationDependentUserData(obj,Struct)
            if isempty(Struct)
                % Empty is ok.
                % It has to be for loading and saving. 
                return
            end
            
            errorMsg = 'ObservationDependentUserData must be an nObservations x 1 structure array';
            assert(isa(Struct,'struct'),errorMsg);
            assert(numel(Struct)==obj.nObservations,errorMsg);
            
            obj.ObservationDependentUserData = Struct;
        end
        
        function export(obj,varargin) %#ok<MANU>
            error('prt:Fixable','Not yet implemented');
        end
        
        function obj = catTargets(obj,dataSet)
            error('prt:Fixable','Not yet implemented');
        end
        function obj = removeTargets(obj,varargin)
            error('prt:Fixable','Not yet implemented');
        end
        function obj = retainTargets(obj,varargin)
            error('prt:Fixable','Not yet implemented');
        end
        
    end
end