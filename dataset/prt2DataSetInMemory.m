classdef prt2DataSetInMemory < prt2DataSetBase
    % prt2DataSetInMemory < prt2DataSetBase
    %   Base class for all prt DataSets that can be held in memory
    %
    % prtDataSetBase Properties: 
    %   ObservationDependentUserData - I think the gets and sets for this need to
    %          be in prt2DataSetBase and be abstract; the current interface allows
    %          people to see the struct...
    %
    % methods:
    %   getObservations - Return an array of observations
    %   setObservations - Set the array of observations
    %
    %   getTargets - Return an array of targets (empty if unlabeled)
    %   setTargets - Set the array of targets
    %
    %   joinFeatures - Combine the features from two or more data sets
    %   joinObservations - Combine the observations from two or more data sets
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
    %   export - 
    %   plot - 
    %   summarize - 
    
    properties (Dependent)
        nObservations         % size(data,1)
        nFeatures             % size(data,2)
        nTargetDimensions     % size(targets,2)
    end
    
    properties
        ObservationDependentUserData = struct;
    end
    
    properties (SetAccess='protected',GetAccess ='protected')
        data = [];
        targets = [];
    end
    
    methods
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = prt2DataSetInMemory(varargin)
            % Nothing to do.
            % This should only be called when initializing a sub-class
        end
        
        function targets = getTargets(obj,indices1,indices2)
            if isempty(obj.targets)
                targets = [];
                return;
            end
            if nargin > 1
                prt2DataSetInMemory.checkIndices(indices1,obj.nObservations);
            else
                indices1 = 1:obj.nObservations;
            end
            if nargin > 2
                prt2DataSetInMemory.checkIndices(indices2,obj.nFeatures);
            else
                indices2 = 1:obj.nTargetDimensions;
            end
            targets = obj.targets(indices1,indices2);
        end
        
        function obj = setTargets(obj,targets,indices1,indices2)
            warning('Need to check sizes');
            if nargin > 2
                prt2DataSetInMemory.checkIndices(indices1,obj.nObservations);
            else
                indices1 = 1:obj.nObservations;
            end
            if nargin > 3
                prt2DataSetInMemory.checkIndices(indices1,obj.nObservations);
            else
                indices2 = 1:obj.nTargetDimensions;
                %Allow setting targets when previous targets is empty
                if isequal(obj.nTargetDimensions,0)
                    indices2 = 1:size(targets,2);
                end
            end
            obj.targets(indices1,indices2) = targets;
        end
        
        function nObservations = get.nObservations(obj)
            nObservations = size(obj.data,1); %use InMem's .data field
        end
        function nFeatures = get.nFeatures(obj)
            nFeatures = size(obj.data,2);
        end
        function nTargetDimensions = get.nTargetDimensions(obj)
            nTargetDimensions = size(obj.targets,2); %use InMem's .data field
        end
        
        %Required by prtDataSetBase:
        function [obj,retainedFeatures] = removeFeatures(obj,indices)
            warning('Does not handle feature names');
            prt2DataSetInMemory.checkIndices(indices,obj.nFeatures);
            
            if islogical(indices)
                keepFeatures = ~indices;
            else
                keepFeatures = setdiff(1:obj.nFeatures,indices);
            end
            [obj,retainedFeatures] = retainFeatures(obj,keepFeatures);
        end
        
        function [obj,retainedFeatures] = retainFeatures(obj,retainedFeatures)
            warning('Does not handle feature names');
            prt2DataSetInMemory.checkIndices(retainedFeatures,obj.nFeatures);
            obj.data = obj.data(:,retainedFeatures);
        end
        
        function obj = replaceFeatures(obj,data,indices)
            warning('Does not handle feature names');
            prt2DataSetInMemory.checkIndices(indices,obj.nFeatures);
            indices = indices(:);
            if size(indices,1) ~= size(data,2)
                error('prt:prt2DataSetInMemory:invalidIndices','length(indices) (%d) ~= size(data,1) (%d)',length(indices),size(data,1));
            end
            
            obj.data(:,indices) = data;
        end
        
        function [obj,retainedIndices] = removeObservations(obj,indices)
            warning('Does not handle observation names');
            prt2DataSetInMemory.checkIndices(indices,obj.nObservations);
            
            if islogical(indices)
                keepObservations = ~indices;
            else
                keepObservations = setdiff(1:obj.nObservations,indices);
            end
            
            [obj,retainedIndices] = retainObservations(obj,keepObservations);
        end
        
        function [obj,retainedIndices] = retainObservations(obj,retainedIndices)
            warning('Does not handle observation names');
            prt2DataSetInMemory.checkIndices(retainedIndices,obj.nObservations);
            obj.data = obj.data(retainedIndices,:);
            
            if ~isempty(obj.ObservationDependentUserData)
                obj.ObservationDependentUserData = obj.ObservationDependentUserData(retainedIndices);
            end
        end
        
        function obj = replaceObservations(obj,data,indices)
            warning('Does not handle observation names');
            prt2DataSetInMemory.checkIndices(indices,obj.nObservations);
            if size(indices,1) ~= size(data,1)
                indices = indices(:);
                error('prt:prt2DataSetInMemory:invalidIndices','length(indices) (%d) ~= size(data,1) (%d)',length(indices),size(data,1));
            end
            
            obj.data(indices,:) = data;
        end
        
        %Return the data by indices
        function data = getObservations(obj,indices1,indices2)
            if nargin == 1
                % No indicies identified. Quick exit
                data = obj.data;
                return
            end
            
            if nargin < 2 || isempty(indices1) || strcmpi(indices1,':')
                indices1 = 1:obj.nObservations;
            end
            if nargin < 3 || isempty(indices2) || strcmpi(indices2,':')
                indices2 = 1:obj.nFeatures;
            end
            
            prt2DataSetInMemory.checkIndices(indices1,obj.nObservations);
            prt2DataSetInMemory.checkIndices(indices2,obj.nFeatures);
            data = obj.data(indices1,indices2);
        end
        
        %Set the observations to a new set
        function obj = setObservations(obj,data,indices1,indices2)
            warning('Need to check that resulting data size is not > target size');
            %check sizes:
            if nargin == 2
                obj.data = data;
                return;
            end
            if nargin < 3 || isempty(indices1) || isequal(indices1,':')
                indices1 = 1:obj.nObservations;
            end
            if nargin < 4 || isempty(indices2) || isequal(indices2,':')
                indices2 = 1:obj.nFeatures;
            end
            if isnumeric(indices1)
                nRefs1 = length(indices1);
            elseif islogical(indices1)
                nRefs1 = sum(indices1);
            else
                error('setObservations invalid indices');
            end
            if isnumeric(indices2)
                nRefs2 = length(indices2);
            elseif islogical(indices2)
                nRefs2 = sum(indices2);
            else
                error('setObservations invalid indices');
            end
            
            if ~isequal([nRefs1,nRefs2],size(data))
                error('setObservations sizes not commensurate');
            end
            obj.data(indices1,indices2) = data;
            return;
        end
        
        %Required by prtDataSetBase:
        function obj = setData(obj,data)
            if ~isa(data,'double') || ndims(data) ~= 2
                error('prt:prtDataSetBaseInMemeoryLabeled:invalidData','data must be a 2-Dimensional double array');
            end
            obj.data = data;
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
        
        %         function obj = set.data(obj, data)
        %             obj.data = data;
        %         end
        %
        %         function data = get.data(obj)
        %             data = obj.data;
        %         end
        
        function obj = joinObservations(obj, varargin)
            warning('Does not handle observation names');
            for iCat = 1:length(varargin)
                obj = catObservations(obj, varargin{iCat}.getObservations);
            end
        end
        
        function obj = joinFeatures(obj, varargin)
            warning('Does not handle feature names');
            for iCat = 1:length(varargin)
                obj = catFeatures(obj, varargin{iCat}.getObservations);
            end
        end
        
        function obj = catFeatures(obj, newData)
            obj.data = cat(2,obj.data, newData);
        end
        
        function obj = catObservations(obj, newData)
            obj.data = cat(1,obj.data, newData);
        end
        
        function export(obj,varargin) %#ok<MANU>
            error('Not Done Yet');
        end
        
    end
    
    
    methods (Access = 'protected',Static = true);
        function [err,errorID,errorMsg] = checkIndices(indices,maxVal,boolError)
            if islogical(indices)
                indices = find(indices);
            end
            if nargin < 3
                boolError = true;
            end
            err = 0;
            if ~isvector(indices)
                errorID = 'prt:prt2DataSetInMemory:invalidIndices';
                errorMsg = 'Indices must be a vector';
                err = 3;
            end
            if any(indices < 1)
                errorID = 'prt:prt2DataSetInMemory:indexOutOfRange';
                errorMsg = sprintf('Some index elements (%d) are less than 1',min(indices));
                err = 1;
            end
            if any(indices > maxVal)
                errorID = 'prt:prt2DataSetInMemory:indexOutOfRange';
                errorMsg = sprintf('Some index elements out of range (%d > %d)',max(indices),maxVal);
                err = 2;
            end

            if err ~= 0 && boolError
                error(errorID,errorMsg);
            end
        end
    end
    
end