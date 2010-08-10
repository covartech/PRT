classdef prtDataSetStandard < prtDataSetBase
% prtDataSetStandard  Standard Data Set Object
% 
%   DATASET = prtDataSetStandard returns a standard data set object
%
%   DATASET = prtDataSetStanard(PROPERTY1, VALUE1, ...) constructs a
%   prtDataSetStandard object DATASET with properties as specified by
%   PROPERTY/VALUE pairs.
% 
%   A prtDataSetStandard object inherits all properties from the
%   prtDataSetBase class. In addition, it has the following properties:
%
%   Observations     - A matrix of observations that has size nObservations 
%                      by nFeatures, i.e. each row contains one observation
%                      made up of nFeatures.
%   Targets          - The class corresponding to each observation. The
%                      number of targets must be empty, or equal the 
%                      number of observations.
%   nObservations    - The number of observations, read-only.
%   nFeatures        - The number of features per observation, read-only
%   isLabeled        - Flag indicating whether the data is labeled or not,
%                      read only.
%   name             - String variable containing the name of the data set
%   description      - Description of data set
%   UserData         - Additional data user may include with data set
%   ActionData       - ???
% 
%
%   See also: prtDataSetStandard.getObservations,
%   prtDataSetStandard.setObservations,
%   prtDataSetStandard.getTargets,
%   prtDataSetStandard.setTargets,
%   prtDataSetStandard.getObservationsAndTargets,
%   prtDataSetStandard.setObservationsAndTargets,
%   prtDataSetStandard.getFeatureNames, 
%   prtDataSetStandard.setFeatureNames

%% Another option for denoting functions, but no hyperlinks
%   A prtDataSetStandard object inherits all methods from the
%   prtDataSetBase class. In addtion, it provides the following methods:

%   getFeatureNames()        - Get the feature names
%   setFeatureNames(NAMES) - Set the feature names to the values in NAMES.
%                            NAMES must be a cell array of strings, and 
%                            must contain the same number of elements as
%                            the data set has features.
%
%   getObservations()        - Return an array of observations
%   setObservations(OBS)   - Set the observations to the values in OBS. OBS
%   must be a matrix
%

%% Old help
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
%
    
    % OLD HELP
    % prtDataSetStandard < prtDataSetBase
    %   Base class for all prt DataSets that can be held in memory
    %
    % prtDataSetBase Properties: 
    %   ObservationDependentUserData - I think the gets and sets for this need to
    %          be in prtDataSetBase and be abstract; the current interface allows
    %          people to see the struct...
    %
    % methods:
    %   getFeatureNames - get the feature names
    %   setFeatureNames - set the feature names
    %
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
    
    properties (GetAccess = 'protected',SetAccess = 'protected')
        featureNames
    end
    
    properties
        ObservationDependentUserData = [];
    end
    
    properties (SetAccess='protected',GetAccess ='protected')
        data = [];
        targets = [];
    end
    
    methods
        
        function obj = catFeatureNames(obj,newDataSet)
            for i = 1:newDataSet.nFeatures;
                currFeatName = newDataSet.featureNames.get(i);
                if ~isempty(currFeatName)
                    obj.featureNames.put(i + obj.nFeatures,currFeatName);
                end
            end
        end
        
        function obj = retainFeatureNames(obj,varargin)
            %obj = retainFeatureNames(obj,varargin)
            %   Note: only call this from within retainFeatures
            
            retainIndices = prtDataSetBase.parseIndices(obj.nFeatures,varargin{:});
            %parse returns logicals
            if islogical(retainIndices)
                retainIndices = find(retainIndices);
            end

            %copy the hash with new indices
            newHash = java.util.Hashtable;
            for retainInd = 1:length(retainIndices);
                if obj.featureNames.containsKey(retainIndices(retainInd));
                    newHash.put(retainInd,obj.featureNames.get(retainIndices(retainInd)));
                end
            end
            obj.featureNames = newHash;
        end
        
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = prtDataSetStandard(varargin)
            % Nothing to do.
            % This should only be called when initializing a sub-class
            obj.featureNames = java.util.Hashtable;
            
            if nargin == 0
                return;
            end
            if isa(varargin{1},'prtDataSetStandard')
                obj = varargin{1};
                varargin = varargin(2:end);
            end
            if isa(varargin{1},'double')
                obj = obj.setObservations(varargin{1});
                varargin = varargin(2:end);
                
                if nargin >= 2 && (isa(varargin{1},'double') || isa(varargin{1},'logical'))
                    obj = obj.setTargets(varargin{1});
                end
                varargin = varargin(2:end);
            end
            
            %handle public access to observations and targets, via their
            %pseudonyms.  If these were public, this would be simple... but
            %they are not public.
            dataIndex = find(strcmpi(varargin(1:2:end),'observations'));
            targetIndex = find(strcmpi(varargin(1:2:end),'targets'));
            stringIndices = 1:2:length(varargin);
            
            if ~isempty(dataIndex) && ~isempty(targetIndex)
                obj = prtDataSetStandard(varargin{stringIndices(dataIndex)+1},varargin{stringIndices(targetIndex)+1});
                newIndex = setdiff(1:length(varargin),[stringIndices(dataIndex),stringIndices(dataIndex)+1,stringIndices(targetIndex),stringIndices(targetIndex)+1]);
                varargin = varargin(newIndex);
            elseif ~isempty(dataIndex)
                obj = prtDataSetStandard(varargin{dataIndex+1});
                newIndex = setdiff(1:length(varargin),[stringIndices(dataIndex),stringIndices(dataIndex)+1]);
                varargin = varargin(newIndex);
            end
            
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        function featNames = getFeatureNames(obj,varargin)
            % prtDataSetStandard/getFeatureNames  Return a prtDataSetStandard feature names
            %
            %   featNames = dataSet.getFeatureNames() Return a cell array of 
            %   the dataSet object feature names. If setFeatureNames has not been 
            %   called or the 'featureNames' field was not set at construction,
            %   default behavior is to return sprintf('Feature %d',i) for all
            %   features.
            %
            %   featNames = dataSet.getFeatureNames(INDICES) Return the feature
            %   names at the specified INDICES.
            
            indices2 = prtDataSetBase.parseIndices(obj.nFeatures,varargin{:});
            %parse returns logicals
            if islogical(indices2)
                indices2 = find(indices2);
            end
            
            featNames = cell(length(indices2),1);
            for i = 1:length(indices2)
                featNames{i} = obj.featureNames.get(indices2(i));
                if isempty(featNames{i})
                    featNames(i) = prtDataSetBase.generateDefaultFeatureNames(indices2(i));
                end
            end
        end
        
        function obj = setFeatureNames(obj,featNames,varargin)
            % prtDataSetStandard/setFeatureNames  Set a prtDataSetStandard feature names
            % 
            %   dataSet = dataSet.setFeatureNames(FEATNAMES) sets the
            %   feature names of the dataSet object. FEATNAMES must be a
            %   cell array of strings, and must have the same number of
            %   elements as the object has features.
            %
            %   dataSet = dataSet.setFeatureNames(FEATNAMES, INDICES) sets the
            %   feature names of the dataSet object at the corresponding
            %   INDICES.
           
            indices2 = prtDataSetBase.parseIndices(obj.nFeatures,varargin{:});
            if length(featNames) > obj.nFeatures
                error('prtDataSetStandard:setFeatureNames','Attempt to set feature names for more features than exist \n%d feature names provided, but object only has %d features',length(featNames),obj.nFeatures);
            end
            %parse returns logicals
            if islogical(indices2)
                indices2 = find(indices2);
            end
            
            %Put the default string names in there; otherwise we might end
            %up with empty elements in the cell array 
            for i = 1:length(indices2)
                obj.featureNames.put(indices2(i),featNames{i});
            end
        end
        
        
        function [data,targets] = getObservationsAndTargets(obj,varargin)
            % prtDataSetStandard/getObservationsAndTargets  Get the
            % observations and targets of a prtDataSetStandard object.
            %
            %[DATA,TARGETS] = dataSet.getObservationsAndTargets() Returns
            %the observations and targets of the dataSet object.
            %
            %[DATA,TARGETS] = dataSet.getObservationsAndTargets(INDICES) Returns
            %the observations and targets of the dataSet object at the
            %specified INDICES. 
            %
            %[data,targets] = getObservationsAndTargets(obj,indices1,indices2,targetIndices)
            % XXX THIS MAKES NO SENSE 
            [indices1, indices2, indices3] = prtDataSetBase.parseIndices([obj.nObservations, obj.nFeatures obj.nTargetDimensions],varargin{:});
            
            data = obj.getObservations(indices1, indices2);
            targets = obj.getTargets(indices1, indices3);
        end
        
        function obj = setObservationsAndTargets(obj,data,targets)
            % prtDataSetStandard/SetObservationsAndTargets  Set the
            % observations and targets of a prtDataSetStandard object.
            %
            % dataSet = dataSet.setObservationsAndTargets(DATA, TARGETS)
            % sets the observations and targets to the DATA and TARGETS.
            % The number of TARGETS must be equal to the number of
            % observations contained in DATA.
            
            %disp('should this clear all the names?');
            if ~isempty(targets) && size(data,1) ~= size(targets,1)
                error('prtDataSet:invalidDataTargetSet','Data and non-empty target matrices must have the same number of rows, but data is size %s and targets are size %s',mat2str(size(data)),mat2str(size(targets)));
            end
            obj.data = data;
            obj.targets = targets;
        end
        
        function data = getObservations(obj,varargin)        
            % prtDataSetStandard/getObservations  Get the
            % observations of a prtDataSetStandard object.
            %
            %[DATA] = dataSet.getObservationsAndTargets() Returns
            %the observations of the dataSet object.
            %
            %[DATA,TARGETS] = dataSet.getObservationsAndTargets(INDICES) Returns
            %the observations of the dataSet object at the specified INDICES. 
            
            if nargin == 1
                % No indicies identified. Quick exit
                data = obj.data;
                return
            end
            
            [indices1, indices2] = prtDataSetBase.parseIndices([obj.nObservations, obj.nFeatures],varargin{:});
            data = obj.data(indices1,indices2);
        end
        
        function obj = setObservations(obj, data, varargin)
            % prtDataSetStandard/SetObservations  Set the observations
            % prtDataSetStandard object.
            %
            % dataSet = dataSet.setObservations(DATA) sets the observations
            % to DATA.
            %
            % dataSet = dataSet.setObservations(DATA, INDICES), sets the
            % observations to DATA at the specified INDICES
            %
            %obj = setObservations(obj,data,indices1,indices2)
            % MAKES NO SENSE XXX
            
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
            % prtDataSetStandard/getTargets  Get the targets of a prtDataSetStandard object.
            %
            %TARGETS = dataSet.getTargets() Returns the targets of the
            %dataSet object.
            %
            %TARGETS = dataSet.getTargets(INDICES) Returns the targets of
            %the dataSet object at the specified INDICES. 
            %
            %[data,targets] = getObservationsAndTargets(obj,indices1,indices2,targetIndices)
            % XXX THIS MAKES NO SENSE      
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
            % prtDataSetStandard/SetTargets  Set the Targets
            % prtDataSetStandard object.
            %
            % dataSet = dataSet.setTargets(TARGETS) sets the targets
            % to DATA.
            %
            % dataSet = dataSet.setTargets(TARGETS, INDICES), sets the
            % targets to TARGETS at the specified INDICES
            %
            %obj = setObservations(obj,data,indices1,indices2)
            % MAKES NO SENSE XXX
               
            % Setting only specified entries of the matrix
            [indices1, indices2] = prtDataSetBase.parseIndices([obj.nObservations, obj.nTargetDimensions],varargin{:});
                
            %Handle empty targets (2-D)
            if isempty(indices2) 
                indices2 = 1:size(targets,2);
            end
            %Handle empty targets (1-D)
            if isempty(indices1) && ~isempty(targets);
                indices1 = 1:obj.nObservations;
            end
            
            if ~isempty(targets)
                if ~isequal([length(indices1),length(indices2)],size(targets))
                    if isempty(obj.targets) && nargin < 3
                        error('prtDataSetStandard:InvalidTargetSize','Attempt to set targets to matrix of size %s, but indices are of size [%d %d]',mat2str(size(targets)),length(indices1),length(indices2))
                    else
                        error('prtDataSetStandard:InvalidTargetSize','Attempt to set targets to matrix of size %s, but data is size %s',mat2str(size(targets)),mat2str(size(obj.data)));
                    end
                end
                
                obj.targets(indices1,indices2) = targets;
            else
                obj.targets = [];
            end
        end
        
        function obj = catObservations(obj, varargin)
            %obj = catObservations(obj, dataSet1)
            %obj = catObservations(obj, dataSet1, dataSet2, ...)
           
            if nargin == 1
                return;
            end
            disp('need to check target/data size agreement');
            for argin = 1:length(varargin)
                currInput = varargin{argin};
                if isa(currInput,class(obj.data))
                    obj.data = cat(1,obj.data, currInput);
                elseif isa(currInput,class(obj))
                    obj = obj.catObservationNames(currInput);
                    obj.data = cat(1,obj.data,currInput.getObservations);
                    obj.targets = cat(1,obj.targets,currInput.getTargets);
                end
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
                    obj.data = cat(2,obj.data, currInput);
                elseif isa(currInput,class(obj))
                    obj = obj.catFeatureNames(currInput);
                    obj.data = cat(2,obj.data,currInput.getObservations);
                end
            end
        end
        
        function [obj, sampleIndices] = bootstrap(obj,nSamples)
            %obj = bootstrap(obj,nSamples)
            
            if obj.nObservations == 0
                error('prtDataSetStandard:BootstrapEmpty','Cannot bootstrap empty data set');
            end
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
        function plot(obj,varargin)
            error('prt:Fixable','Not yet');
        end
        function summarize(obj,varargin)
            error('prt:Fixable','Not yet');
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
            obj.targets = obj.targets(:,retainedTargets);
        end
        
    end
end