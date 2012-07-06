classdef prtDataSetStandard < prtDataSetInMem
   
    properties (Dependent, Hidden)
        featureNames
    end
    
    properties (Dependent)
        nFeatures             % The number of features
        featureInfo           % Additional data (structure) per feature
    end
    
    properties (GetAccess = 'protected',SetAccess = 'protected')
        featureInfoInternal
    end
    
    properties (GetAccess = 'protected', SetAccess = 'protected', Hidden = true)
        featureNameIntegerAssocArray = prtUtilIntegerAssociativeArray;
    end
    
    methods
        function self = set.featureInfo(self,fi)
            self = setFeatureInfo(self,fi);
        end
        function fi = get.featureInfo(self)
            fi = self.getFeatureInfo;
        end
        
        function self = set.featureNames(self,names)
            self = self.setFeatureNames(names);
        end
        function fn = get.featureNames(self)
            fn = self.getFeatureNames;
        end
    end
    
    methods (Access = 'protected',Hidden = true)
        
        function has = hasFeatures(obj)
            has = ~isempty(obj.featureNameIntegerAssocArray);
        end
        
        function obj = catFeatureNames(obj,dataSet2)
            if ~dataSet2.hasFeatures
                return;
            end
            for i = 1:dataSet2.nFeatures
                currFeatName = dataSet2.featureNameIntegerAssocArray.get(i);
                if ~isempty(currFeatName)
                    obj.featureNameIntegerAssocArray = obj.featureNameIntegerAssocArray.put(obj.nFeatures + i, currFeatName);
                end
            end
        end
    end
    
    methods
        
        function self = setFeatureNames(self,names,featureIndices)
            %dataSet = setFeatureNames(dataSet,names)
            %  Set the feature names using a cell array, names, of size
            %  1 x dataSet.nFeatures
            
            if isempty(names)
                %clear
                self.featureNameIntegerAssocArray = prtUtilIntegerAssociativeArray;
                return;
            end
            if nargin < 3
                featureIndices = 1:self.nFeatures;
            end
            if length(featureIndices) ~= length(names)
                error('prt:featureNames','Different numbers of features (%d) specified or available than feature names provided (%d)',length(featureIndices),length(names));
            end
            for i = 1:length(names)
                self.featureNameIntegerAssocArray = self.featureNameIntegerAssocArray.put(featureIndices(i),names{i});
            end
        end
        
        function featNames = getFeatureNames(obj,indices)
            %names = getFeatureNames(dataSet)
            %  Return the current feature names.
            
            if nargin == 1
                indices = 1:obj.nFeatures;
            end
            indices = prtDataSetBase.parseIndices(obj.nFeatures,indices);
            
            featNames = obj.featureNameIntegerAssocArray.get(indices);
            if ~isa(featNames,'cell')
                featNames = {featNames};
            end
            empty = cellfun(@(x)isempty(x),featNames);
            emptyInd = find(empty);
            featNames(emptyInd) = prtDataSetBase.generateDefaultFeatureNames(emptyInd);
        end
        
        function d = getObservations(self,varargin)
            %d = getObservations(dataSet)
            %  Return dataSet.data
            %
            if nargin == 1
                d = self.data;
                return;
            end
            
            try
                %default to 2-D for getObservations; we can make this 
                if length(varargin) == 1; 
                    varargin = [varargin(1),repmat({':'},1,ndims(self.data)-1)];
                end
                d = self.data(varargin{:});
            catch ME
                prtDataSetBase.parseIndices([self.nObservations,self.nFeatures],varargin{:});
                throw(ME);
            end
        end
        
        function n = get.nFeatures(self)
            n = self.getNumFeatures;
        end
        
        % Constructor
        function obj = prtDataSetStandard(varargin)
            if nargin == 0
                return;
            end
            if isa(varargin{1},'prtDataSetClass')
                obj = varargin{1};
                varargin = varargin(2:end);
            end
            
            %handle first input data:
            if length(varargin) >= 1 && (isnumeric(varargin{1}) || islogical(varargin{1}))
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
            varargin(1:2:end) = strrep(varargin(1:2:end),'Observations','data');
            varargin(1:2:end) = strrep(varargin(1:2:end),'observations','data');
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        
        function data = getFeatures(obj,varargin)
            % getFeatures   Return the features of a prtDataSetStandard
            % object
            %
            % data = dataSet.getFeatures() returns dataSet.data
            %
            % data = dataSet.getFeatures(indices) returns only the
            % features of the dataSet object specified by indices, e.g.,
            %  data = dataSet.data(:,indices);
            
            if nargin == 1
                featureIndices = 1:obj.nFeatures;
            else
                featureIndices = varargin{1};
            end
            try
                data = obj.data(:,featureIndices);
            catch ME
                prtDataSetBase.parseIndices(obj.nFeatures ,varargin{:});
                throw(ME);
            end
        end
        
        function obj = setFeatures(obj,data,varargin)
            % dsOut = setFeatures(dataSet,data,indices)
            %   Set the columns of dataSet.data corresponding to indices to
            %   the input matrix, data:
            %
            %   dsOut.data(:,indices) = data;
            %  
            
            obj.data(:,varargin{:}) = data;
            obj = obj.update;
        end
        
        function obj = catFeatures(obj, varargin)
            % dsOut = catFeatures(dataSet1,dataSet2)
            %  Return a data set formed from the horizontal concatenation
            %  of the features in dataSet1 and dataSet2.
            
            if nargin == 1
                return;
            end
            
            for i = 1:length(varargin)
                currInput = varargin{i};
                if ~isa(currInput,'prtDataSetStandard')
                    currInput = prtDataSetStandard(currInput);
                end
                    
                obj = obj.catFeatureNames(currInput);
                obj = obj.catFeatureInfo(currInput);
                obj.data = cat(2,obj.data,currInput.data);
            end
            
            % Updated chached data info
            %             obj = updateObservationsCache(obj);
            obj = obj.update;
        end
        
        function [obj,retainFeatureInds] = removeFeatures(obj,removeFeatureInds)
            % dsOut = removeFeatures(dataSet,removeFeatureInds)
            %  Return a data set formed by removing the specified features.
            
            if islogical(removeFeatureInds)
                removeFeatureInds = find(removeFeatureInds);
            end
            retainFeatureInds = setdiff(1:obj.nFeatures,removeFeatureInds);
            [obj,retainFeatureInds] = retainFeatures(obj,retainFeatureInds);
            obj = obj.update;
        end
        
        function [obj,retainFeatureInds] = retainFeatures(obj,retainFeatureInds)
            % dsOut = retainFeatures(dataSet,retainFeatureInds)
            %  Return a data set formed by retaining the specified features.
            
            try
                obj = obj.retainFeatureNames(retainFeatureInds);
                obj.data = obj.data(:,retainFeatureInds);
                if ~isempty(obj.featureInfo)
                    obj.featureInfo = obj.featureInfo(retainFeatureInds);
                end
            catch ME
                prtDataSetBase.parseIndices(obj.nFeatures, retainFeatureInds);
                throw(ME);
            end
            obj = obj.update;
        end
        
        function nFeatures = getNumFeatures(obj)
            nFeatures = size(obj.data,2);
        end
    end
    
    methods (Hidden = true)
        
        function obj = catFeatureInfo(obj, newDataSet)
            
            oldFeatureInfo = obj.featureInfo;
            newFeatureInfo = newDataSet.featureInfo;
            if isempty(oldFeatureInfo) && isempty(newFeatureInfo)
                % No featureInfo was set in either dataset so just exit
                % and accept the default empty
                return;
            elseif isempty(oldFeatureInfo)
                oldFeatureInfo = repmat(struct,obj.nFeatures,1);
            elseif isempty(newFeatureInfo)
                newFeatureInfo = repmat(struct,newDataSet.nFeatures,1);
            end
            obj.featureInfoInternal = prtUtilStructVCatMergeFields(oldFeatureInfo(:),newFeatureInfo(:))';
        end
        
        function obj = copyDescriptionFieldsFrom(obj,dataSet)
            %obj = copyDescriptionFieldsFrom(obj,dataSet)
            
            %No; do not copy featureNames; featureNames must be set by
            %Actions; the outputs of a Action are not guaranteed to have
            %the same number of features!
            
            obj.observationInfo = dataSet.observationInfo;
            obj = copyDescriptionFieldsFrom@prtDataSetBase(obj,dataSet);
        end
        
        function has = hasFeatureNames(obj)
            has = ~isempty(obj.featureNameIntegerAssocArray);
        end
        
        function v = export(obj,varargin) %#ok<STOUT,MANU>
            error('prt:Fixable','prtDataSetStandard does not implement an export() function; did you mean to use a prtDataSetClass or prtDataSetRegress?');
        end
        
        function h = plot(obj,varargin) %#ok<STOUT,MANU>
            error('prt:prtDataSetStandard:plot','prtDataSetStandard does not implement a plot() function; did you mean to use a prtDataSetClass or prtDataSetRegress?');
        end
        
        function Summary = summarize(Obj)
            % Summarize   Summarize the prtDataSetStandard object
            %
            % SUMMARY = dataSet.summarize() Summarizes the prtDataSetStandard
            % object and returns the result in the struct SUMMARY.
            
            Summary.upperBounds = max(Obj.data);
            Summary.lowerBounds = min(Obj.data);
            Summary.nFeatures = Obj.nFeatures;
            Summary.nTargetDimensions = Obj.nTargetDimensions;
            Summary.nObservations = Obj.nObservations;
        end
    end
    
    methods (Access = protected)
        
        function self = retainFeatureNames(self,retainFeatureInds)
            keys = 1:length(retainFeatureInds);
            names = self.featureNameIntegerAssocArray.get(retainFeatureInds);
            self.featureNameIntegerAssocArray = prtUtilIntegerAssociativeArray(keys,names);
        end
        
        function self = setFeatureInfo(self,info)
            if length(info) ~= self.nFeatures
                error('size mismatch');
            end
            %assorted error checking
            self.featureInfoInternal = info;
        end
        
        function featInfo = getFeatureInfo(self)            
            featInfo = self.featureInfoInternal;
        end
        
    end
    
% %     methods (Static)
% %         function featNames = generateDefaultFeatureNames(indices)
% %             featNames = prtUtilCellPrintf('Feature %d',num2cell(indices));
% %             featNames = featNames(:);
% %         end
% %     end
                
    
    
    % Easy of use methods. These assume that the data is in memory
    % therefore they are implemented here in prtDataSetStandard
  
    %         function obj = set.targetNames(obj,val)
    %             obj = obj.setTargetNames(val);
    %         end
    %         function val = get.targetNames(obj)
    %             val = obj.getTargetNames();
    %         end
    %     end
    
    methods (Static)
        function obj = loadobj(obj)
            
            if isstruct(obj)
                if ~isfield(obj,'version')
                    % Version 0 - we didn't even specify version
                    inputVersion = 0;
                else
                    inputVersion = obj.version;
                end
                
                currentVersionObj = prtDataSetStandard;
                
                if inputVersion == currentVersionObj.version
                    % Returning now will cause MATLAB to ignore this entire
                    % loadobj() function and perform the default actions
                    return
                end
                
                % The input version is less than the current version
                % We need to
                inObj = obj;
                obj = currentVersionObj;
                switch inputVersion
                    case 0
                        % The oldest version of prtDataSetBase
                        % We need to set the appropriate fields from the
                        % structure (inObj) into the prtDataSetClass of the
                        % current version
                        obj = obj.setObservationsAndTargets(inObj.dataDepHelper,inObj.targetsDepHelper);
                        obj.observationInfo = inObj.observationInfoDepHelper;
                        obj.featureInfo = inObj.featureInfoDepHelper;
                        if ~isempty(inObj.featureNamesDepHelper)
                            obj = obj.setFeatureNames(inObj.featureNamesDepHelper.cellValues,inObj.featureNamesDepHelper.integerKeys);
                        end
                        if ~isempty(inObj.observationNamesInternal.cellValues)
                            obj = obj.setObservationNames(inObj.observationNamesInternal.cellValues,inObj.observationNamesInternal.integerKeys);
                            %obj = obj.setObservationNames(inObj.observationNames.cellValues);
                        end
                        if ~isempty(inObj.targetNamesInternal)
                            obj = obj.setTargetNames(inObj.targetNamesInternal.cellValues);
                        end
                        
                        obj.name = inObj.name;
                        obj.description = inObj.description;
                        obj.userData = inObj.userData;
                        obj.actionData = inObj.actionData;
                        
                    otherwise
                        error('prt:prtDataSetStandard:loadObj','Unknown prtDataSetBase version %d, object cannot be laoded.',inputVersion);
                end
            else
                % Nothin special
            end
        end
    end
end