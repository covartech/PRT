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
            %[data,targets] = getObservationsAndTargets(obj)
            %[data,targets] = getObservationsAndTargets(obj,indices1)
            %[data,targets] = getObservationsAndTargets(obj,indices1,indices2,targetIndices)
            
            [indices1, indices2, indices3] = prtDataSetBase.parseIndices([obj.nObservations, obj.nFeatures obj.nTargetDimensions],varargin{:});
            
            data = obj.getObservations(indices1, indices2);
            targets = obj.getTargets(indices1, indices3);
        end
        
        function obj = setObservationsAndTargets(obj,data,targets)
            %obj = setObservationsAndTargets(obj,data,targets)
            
            disp('should this clear all the names?');
            if ~isempty(targets) && size(data,1) ~= size(targets,1)
                error('prtDataSet:invalidDataTargetSet','Incompatible data/targets sizes');
            end
            obj.data = data;
            obj.targets = targets;
        end
        
        function data = getObservations(obj,varargin)
            %data = getObservations(obj)
            %data = getObservations(obj,indices1)
            %data = getObservations(obj,indices1,indices2)
            
            if nargin == 1
                % No indicies identified. Quick exit
                data = obj.data;
                return
            end
            
            [indices1, indices2] = prtDataSetBase.parseIndices([obj.nObservations, obj.nFeatures],varargin{:});
            data = obj.data(indices1,indices2);
        end
        
        function obj = setObservations(obj, data, varargin)
            %obj = setObservations(obj,data)
            %obj = setObservations(obj,data,indices1)
            %obj = setObservations(obj,data,indices1,indices2)
            
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
        
        function targets = getTargets(obj,varargin)
            %targets = getTargets(obj)
            %targets = getTargets(obj,indices1)
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
        
        function obj = setTargets(obj,targets,varargin)
            %obj = setTargets(obj,targets)
            %obj = setTargets(obj,targets,indices1)
            %obj = setTargets(obj,targets,indices1,indices2)
            
            % Setting only specified entries of the matrix
            [indices1, indices2] = prtDataSetBase.parseIndices([obj.nObservations, obj.nTargetDimensions],varargin{:});
            %Handle empty targets
            if isempty(indices2) 
                indices2 = 1:size(targets,2);
            end
            
            obj.targets(indices1,indices2) = targets;
        end
        
        function obj = catObservations(obj, varargin)
            %obj = catObservations(obj, dataSet1)
            %obj = catObservations(obj, dataSet1, dataSet2, ...)
            if nargin == 1
                
                % Allow for an array of dataSets
                if length(obj) > 1
                    %otherObjCell = mat2cell(obj(2:end),ones(length(obj)-1,1),ones(length(obj)-1,1));
                    otherObjCell = num2cell(obj(2:end));
                    obj = obj(1).catObservations(otherObjCell{:});
                end
                
                return;
            end
            
            for argin = 1:length(varargin)
                currInput = varargin{argin};
                if currInput.isLabeled ~= obj.isLabeled
                    error('prtDataSet:invalidConcatenation','Attempt to combine labeled and unlabeled data sets in cat Observations');
                end
                obj = obj.catObservationNames(currInput);
                obj.data = cat(1,obj.data,currInput.getObservations);
                obj.targets = cat(1,obj.targets,currInput.getTargets);
            end
        end
        
        function [obj,retainedIndices] = removeObservations(obj,removeIndices)
            %[obj,retainedremoveIndices] = removeObservations(obj,removeIndices)
            
            removeIndices = prtDataSetBase.parseIndices(obj.nObservations ,removeIndices);
            
            if islogical(removeIndices)
                keepObservations = ~removeIndices;
            else
                keepObservations = setdiff(1:obj.nObservations,removeIndices);
            end
            
            [obj,retainedIndices] = retainObservations(obj,keepObservations);
        end
        
        function [obj,retainedIndices] = retainObservations(obj,retainedIndices)
            %[obj,retainedIndices] = retainObservations(obj,retainedIndices)
            
            retainedIndices = prtDataSetBase.parseIndices(obj.nObservations ,retainedIndices);
            
            obj = obj.retainObservationNames(retainedIndices);
            obj.data = obj.data(retainedIndices,:);
            if obj.isLabeled
                obj.targets = obj.targets(retainedIndices,:);
            end
            
            if ~isempty(obj.ObservationDependentUserData) 
                obj.ObservationDependentUserData = obj.ObservationDependentUserData(retainedIndices);
            end
            
        end
        
        function [obj,retainedFeatures] = removeFeatures(obj,removeIndices)
            %[obj,retainedFeatures] = removeFeatures(obj,removeIndices)
            
            removeIndices = prtDataSetBase.parseIndices(obj.nFeatures ,removeIndices);
            if islogical(removeIndices)
                keepFeatures = ~removeIndices;
            else
                keepFeatures = setdiff(1:obj.nFeatures,removeIndices);
            end
            [obj,retainedFeatures] = retainFeatures(obj,keepFeatures);
        end
        
        function [obj,retainedFeatures] = retainFeatures(obj,retainedFeatures)
            %[obj,retainedFeatures] = retainFeatures(obj,retainedFeatures)
            
            retainedFeatures = prtDataSetBase.parseIndices(obj.nFeatures ,retainedFeatures);
            obj = obj.retainFeatureNames(retainedFeatures);
            obj.data = obj.data(:,retainedFeatures);
        end
        
        function data = getFeatures(obj,varargin)
            featureIndices = prtDataSetBase.parseIndices(obj.nFeatures ,varargin{:});
            data = obj.getObservations(:,featureIndices);
        end
        
        function obj = setFeatures(obj,data,varargin)
            obj = obj.setObservations(data,:,varargin{:});
        end
        
        function obj = catFeatures(obj, varargin)
            %obj = catFeatures(obj, dataArray1, dataArray2,...)
            %obj = catFeatures(obj, dataSet1, dataSet2,...)

            if nargin == 1
                return;
            end
            for argin = 1:length(varargin)
                currInput = varargin{argin};
                if isa(currInput,class(obj.data))
                    obj.data = cat(2,obj.data, newData);
                elseif isa(currInput,class(obj))
                    obj = obj.catFeatureNames(currInput);
                    obj.data = cat(2,obj.data,currInput.getObservations);
                end
            end
        end
        
        function [obj, sampleIndices] = bootstrap(obj,nSamples)
            %obj = bootstrap(obj,nSamples)
            
            if nargin < 2 || isempty(nSamples)
                nSamples = obj.nObservations;
            end
            
            sampleIndices = ceil(rand(1,nSamples).*obj.nObservations);
            
            newData = obj.getObservations(sampleIndices);
            
            if obj.isLabeled
                newTargets = obj.getTargets(sampleIndices);
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
        
        
        function obj = catTargets(obj, varargin)
            %obj = catTargets(obj, targetArray1, targetArray2,...)
            %obj = catTargets(obj, dataSet1, dataSet2,...)
            warning('prt:Fixable','Does not handle feature names');
            
            if nargin == 1
                return;
            end
            for argin = 1:length(varargin)
                currInput = varargin{argin};
                if isa(currInput,class(obj.targets))
                    obj.targets = cat(2,obj.targets, newData);
                elseif isa(currInput,prtDataSetStandard)
                    obj = obj.catTargetNames(currInput);
                    obj.targets = cat(2,obj.targets,currInput.getTargets);
                end
            end
        end
        
        function [obj,retainedTargets] = removeTargets(obj,removeIndices)
            %[obj,retainedTargets] = removeTargets(obj,removeIndices)
            warning('prt:Fixable','Does not handle feature names');
            
            removeIndices = prtDataSetBase.parseIndices(obj.nTargetDimensions,removeIndices);
            
            if islogical(removeIndices)
                keepFeatures = ~removeIndices;
            else
                keepFeatures = setdiff(1:obj.nFeatures,removeIndices);
            end
            [obj,retainedTargets] = retainTargets(obj,keepFeatures);
        end
        
        function [obj,retainedTargets] = retainTargets(obj,retainedTargets)
            
            warning('prt:Fixable','Does not handle feature names');
            retainedTargets = prtDataSetBase.parseIndices(obj.nTargetDimensions ,retainedTargets);
            obj.data = obj.data(:,retainedTargets);
        end
        
    end
end