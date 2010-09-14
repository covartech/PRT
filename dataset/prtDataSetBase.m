classdef prtDataSetBase
    % prtDataSetBase    Base class for all prt data sets.
    %
    % This is an abstract class from which all prt data sets inherit from.
    % It can not be instantiated. It contains the following properties:
    %
    %   name           - Data set descriptive name
    %   description    - Description of the data set
    %   UserData       - Structure for holding additional related to the
    %                    data set
    %   ActionData     - Structure for prtActions to place additional data
    %
    %   ObservationDependentUserData - Structure array holding additional
    %                                  data per related to each observation
    %
    %   nObservations     - Number of observations in the data set
    %   nTargetDimensions - Number of target dimensions
    %   isLabeled         - Whether or not the data set is labeled
    %
    % The prtDataSetBase class has the following methods
    %
    %   getObservationNames - get the observation names
    %   setObservationNames - set the observation names
    %
    %   getTargetNames      - get the target names
    %   setTargetNames      - set the target names
    %
    %   getX - Shortcut for getObservations
    %   setX - Shortcut for setObservations
    %   getY - Shortcut for getTargets
    %   setY - Shortcut for setTargets
    %
    %   setXY - Shortcut for setObservationsAndTargets
    %
    % The prtDataSetBase class also specifies the following abstract
    % functions, which are implemented by all derived classes:
    %
    %   getObservations - Return an array of observations
    %   setObservations - Set the array of observations
    %
    %   getTargets - Return an array of targets (empty if unlabeled)
    %   setTargets - Set the array of targets
    %
    %   setObservationsAndTargets - Set the array of observations and
    %                               targets
    %   catFeatures               - Combine the features from a data set
    %                               with another data set
    %   catObservations           - Combine the Observations from a data
    %                               set with another data set
    %   catTargets                - Combine the targets from a data set
    %                               with another data set
    %   removeObservations        - Remove observations from a data set
    %   retainObservations        - Retain observatons (remove all others)
    %                               from a data set
    %
    %   removeTargets - Remove columns of targets from a data set
    %   retainTargets - Retain columns of targets from a data set
    %   plot          - Plot the data set
    %   summarize     - Output a summary of the data set
    %
    %   See also: prtDataSetStandard, prtDataSetClass, prtDataSetRegress,
    
    
    properties (Abstract, Dependent)
        nObservations         % The number of observations
        nTargetDimensions     % The number of target dimensions
    end
    properties (Dependent)
        isLabeled           % Whether or not the data has target labels
    end
    
    properties  %public, for now
        name = ''             % A string naming the data set
        description = ''      % A string with a verbose description of the data set
        UserData = struct;         % Additional data per data set
    end
    
    properties(Hidden)
        ActionData = struct;      % Data stored by a prtAction
    end
    
    % Only prtDataSetBase knows about these, use getObs... and getFeat.. to
    % get and set these, they handle the dirty stuff
    properties (GetAccess = 'protected',SetAccess = 'protected')
        observationNames    % The observations names
        targetNames         % The target names.
    end
    
    methods
        function isLabeled = get.isLabeled(obj)
            isLabeled = ~isempty(obj.getY);
        end
    end
    
    %Wrappers - getX, setX, getY, setY
    methods
        function [observations,targets] = getXY(obj,varargin)
            % getXY  Shortcut for getObservationsAndTargets
            observations = obj.getObservations(varargin{:});
            targets = obj.getTargets(varargin{:});
        end
        function observations = getX(obj,varargin)
            % getX Shortcut for GetObservations
            observations = obj.getObservations(varargin{:});
        end
        function targets = getY(obj,varargin)
            % getY Shortcut for getTargets
            targets = obj.getTargets(varargin{:});
        end
        function obj = setXY(obj,varargin)
            % setXY Shortcut for setObservationsAndTargets
            obj = obj.setObservationsAndTargets(varargin{:});
        end
        function obj = setX(obj,varargin)
            % setX Shortcut for setObservations
            obj = obj.setObservations(varargin{:});
        end
        function obj = setY(obj,varargin)
            % setY Shortcut for setTargets
            obj = obj.setTargets(varargin{:});
        end
    end
    
    %Methods for setting name, description
    methods
        function obj = set.name(obj, newName)
            if ~isa(newName,'char');
                error('prt:prtDataSetBase:dataSetNameNonString','name must but name must be a character array');
            end
            obj.name = newName;
        end
        function obj = set.description(obj, newDescr)
            if ~isa(newDescr,'char');
                error('prt:prtDataSetBase:dataSetNameNonString','description must be a character array');
            end
            obj.description = newDescr;
        end
    end
    
    %Methods for get, set, ObservationNames and FeatureNames
    methods
        function obj = prtDataSetBase
            obj.observationNames = prtUtilIntegerAssociativeArray;
            obj.targetNames = prtUtilIntegerAssociativeArray;
        end
        
        function obsNames = getObservationNames(obj,varargin)
            % getObservationNames - Return DataSet's Observation Names
            %
            %   featNames = getObservationNames(obj) Return a cell array of
            %   an object's observation names; if setObservationNames has not been
            %   called or the 'observationNames' field was not set at construction,
            %   default behavior is to return sprintf('Observation %d',i) for all
            %   observations.
            %
            %   featNames = getObservationNames(obj,indices) Return the observation
            %   names for only the specified indices.
            
            indices1 = prtDataSetBase.parseIndices(obj.nObservations,varargin{:});
            %parse returns logicals
            if islogical(indices1)
                indices1 = find(indices1);
            end
            
            obsNames = cell(length(indices1),1);
            
            for i = 1:length(indices1)
                obsNames{i} = obj.observationNames.get(indices1(i));
                if isempty(obsNames{i})
                    obsNames(i) = prtDataSetBase.generateDefaultObservationNames(indices1(i));
                end
            end
        end
        
        function targetNames = getTargetNames(obj,varargin)
            % getTargetNames  Return the target names of a dataset
            %
            
            indices2 = prtDataSetBase.parseIndices(obj.nTargetDimensions,varargin{:});
            %parse returns logicals
            if islogical(indices2)
                indices2 = find(indices2);
            end
            
            targetNames = cell(length(indices2),1);
            
            for i = 1:length(indices2)
                targetNames{i} = obj.targetNames.get(indices2(i));
                if isempty(targetNames{i})
                    targetNames(i) = prtDataSetBase.generateDefaultTargetNames(indices2(i));
                end
            end
        end
        
        function obj = setObservationNames(obj,obsNames,varargin)
            % setObservationNames  Set the observation names of a data set
            %
            %  dataSet = dataSet.setObservationNames(NAMES) Set an object's
            %  observation names to NAMES.
            %
            %  dataSet = dataSet.setObservationNames(NAMES, INDICES) Set the observation
            %  names for only the specified INDICES.
            
            if ~isa(obsNames,'cell') || ~isa(obsNames{1},'char')
                error('prt:dataSetStandard:setObservationNames','Input observation names must be a cell array of characters');
            end
            if ~isvector(obsNames)
                error('prt:dataSetStandard:setObservationNames','setObservationNames requires first input to be a n x 1 cell array');
            end
            obsNames = obsNames(:);
            
            indices1 = prtDataSetBase.parseIndices(obj.nObservations,varargin{:});
            %parse returns logicals; find the indices
            if islogical(indices1)
                indices1 = find(indices1);
            end
            
            for i = 1:length(indices1)
                obj.observationNames = obj.observationNames.put(indices1(i),obsNames{i});
            end
        end
        
        function obj = setTargetNames(obj,targetNames,varargin)
            % setTargetNames  Set the data set target names
            % 
            %  dataSet = dataSet.setTargetNames(NAMES) Set an object's
            %  target names to NAMES.
            %
            %  dataSet = dataSet.setTargetNames(NAMES, INDICES) Set the
            %  target names for only the specified INDICES.
            
            if ~isa(targetNames,'cell') || ~isa(targetNames{1},'char')
                error('prt:dataSetStandard:setTargetNames','Input target names must be a cell array of characters');
            end
            if ~isvector(targetNames)
                error('prt:dataSetStandard:setTargetNames','setTargetNames requires first input to be a n x 1 cell array');
            end
            targetNames = targetNames(:);
                        
            indices2 = prtDataSetBase.parseIndices(obj.nTargetDimensions,varargin{:});
            %parse returns logicals
            if islogical(indices2)
                indices2 = find(indices2);
            end
            if length(targetNames) ~= length(indices2)
                if nargin == 2
                    error('prt:prtDataSetStandard','Attempt to set target names for different number of targets (%d) than data set has (%d)',length(targetNames),length(max(indices2)));
                else
                    error('prt:prtDataSetStandard','Too many indices (%d) provided for number of target names provited (%d)',length(indices2),length(targetNames));
                end
            end
            %Put the default string names in there; otherwise we might end
            %up with empty elements in the cell array
            for i = 1:length(indices2)
                obj.targetNames = obj.targetNames.put(indices2(i),targetNames{i});
            end
        end
    end
    
    %isEmpty and size
    %     methods
    %         function bool = isempty(obj)
    %             bool = obj.nObservations == 0 || obj.nFeatures == 0;
    %         end
    %
    %         function s = size(obj)
    %             s = [obj.nObservations,obj.nFeatures];
    %         end
    %
    %     end
    
    
    %Private static functions for generating feature and observation names
    methods (Access = 'protected', Static = true, Hidden = true)
        function featNames = generateDefaultFeatureNames(indices2)
            featNames = prtUtilCellPrintf('Feature %d',num2cell(indices2));
            featNames = featNames(:);
        end
        function obsNames = generateDefaultObservationNames(indices2)
            obsNames = prtUtilCellPrintf('Observation %d',num2cell(indices2));
            obsNames = obsNames(:);
        end
        function targNames = generateDefaultTargetNames(indices2)
            targNames = prtUtilCellPrintf('Target %d',num2cell(indices2));
            targNames = targNames(:);
        end
    end
    
    %Protected static functions for modifying edge colors from face colors
    %should be elsewhere
    methods (Access = 'protected', Static = true, Hidden = true)
        function checkIndices(sz,varargin)
            
            nDims = numel(sz);
            if nDims ~= length(varargin)
                error('prt:prtDataSetStandard:invalidIndices','Specified indicies do not match te referenced dimensionality');
            end
            
            
            for iDim = 1:nDims
                cIndices = varargin{iDim};
                
                % No matter how you slize it the indices must be a vector
                if ~isvector(cIndices)
                    error('prt:prtDataSetStandard:invalidIndices','Indices must be a vector');
                end
                
                if islogical(cIndices)
                    if numel(cIndices) ~= sz(iDim)
                        error('prt:prtDataSetStandard:indexOutOfRange','Index size (%d) does not match the size of the reference (%d).',numel(cIndices),sz(iDim));
                    end
                else
                    % Numeric (ie integer) referencing
                    if any(cIndices < 1)
                        error('prt:prtDataSetStandard:indexOutOfRange','Some index elements (%d) are less than 1',min(cIndices));
                    end
                    
                    if any(cIndices > sz(iDim))
                        error('prt:prtDataSetStandard:indexOutOfRange','Some index elements out of range (%d > %d)',max(cIndices),sz(iDim));
                    end
                end
            end
            
        end
        
        function varargout = parseIndices(sz, varargin)
            
            nDims = numel(sz);
            indicesCell = cell(nDims,1);
            for iDim = 1:nDims
                if iDim > length(varargin)
                    indicesCell{iDim} = true(sz(iDim),1);
                else
                    indicesCell{iDim} = varargin{iDim};
                end
                
                if strcmpi(indicesCell{iDim},':')
                    indicesCell{iDim} = true(sz(iDim),1);
                end
            end
            
            prtDataSetBase.checkIndices(sz,indicesCell{:});
            
            varargout = indicesCell;
        end
        
    end
    
    %I don't think we need these anymore - addFeatureNames and
    %addObservationNames...  we may need "remove feature names" and "remove
    %Observation Names"
    methods (Access = 'protected', Hidden = true)
        function obj = catObservationNames(obj,newDataSet)
            
            for i = 1:newDataSet.nObservations;
                currObsName = newDataSet.observationNames.get(i);
                if ~isempty(currObsName)
                    obj.observationNames = obj.observationNames.put(i + obj.nObservations,currObsName);
                end
            end
        end
        
        %   Note: only call this from within retainObservations
        function obj = retainObservationNames(obj,varargin)
            
            
            retainIndices = prtDataSetBase.parseIndices(obj.nObservations,varargin{:});
            %parse returns logicals
            if islogical(retainIndices)
                retainIndices = find(retainIndices);
            end
            if isempty(obj.observationNames)
                return;
            else
                %copy the hash with new indices
                newHash = prtUtilIntegerAssociativeArray;
                for retainInd = 1:length(retainIndices);
                    if obj.observationNames.containsKey(retainIndices(retainInd));
                        newHash = newHash.put(retainInd,obj.observationNames.get(retainIndices(retainInd)));
                    end
                end
                obj.observationNames = newHash;
            end
        end
        
        %obj = catTargetNames(obj,newDataSet)
        function obj = catTargetNames(obj,newDataSet)
            
            for i = 1:newDataSet.nTargetDimensions;
                currTargetName = newDataSet.targetNames.get(i);
                if ~isempty(currTargetName)
                    obj.targetNames = obj.targetNames.put(i + obj.nTargetDimensions,currTargetName);
                end
            end
        end
 
        % Only call from retain tartets
        function obj = retainTargetNames(obj,varargin)
            
            retainIndices = prtDataSetBase.parseIndices(obj.nTargetDimensions,varargin{:});
            %parse returns logicals
            if islogical(retainIndices)
                retainIndices = find(retainIndices);
            end
            if isempty(obj.targetNames)
                return;
            else
                %copy the hash with new indices
                newHash = prtUtilIntegerAssociativeArray;
                for retainInd = 1:length(retainIndices);
                    if obj.targetNames.containsKey(retainIndices(retainInd));
                        newHash = newHash.put(retainInd,obj.targetNames.get(retainIndices(retainInd)));
                    end
                end
                obj.targetNames = newHash;
            end
        end
        
    end
    
    methods (Abstract)
        %all sub-classes must define these behaviors, this is the contract
        %that all "data sets" must follow
        
        %Return the data by indices
        data = getObservations(obj,indices1,indices2)
        targets = getTargets(obj,indices1,indices2)
        [data,targets] = getObservationsAndTargets(obj,indices1,indices2)
        
        
        obj = setObservations(obj,data,indices1,indices2)
        obj = setTargets(obj,targets,indices)
        obj = setObservationsAndTargets(obj,data,targets)
        
        obj = removeObservations(obj,indices)
        obj = removeTargets(obj,indices)
        
        obj = retainObservations(obj,indices)
        obj = retainTargets(obj,indices)
        
        obj = catObservations(obj,dataSet)
        obj = catTargets(obj,dataSet)
        
        handles = plot(obj)
        export(obj,prtExportObject)
        Summary = summarize(obj)
        
    end
end
