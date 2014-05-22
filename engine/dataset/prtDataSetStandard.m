classdef prtDataSetStandard < prtDataSetInMem

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


	properties (Dependent, Hidden)
		featureNames
		featureNameModificationFunction;
		featureNameModificationMask;
	end
	
	properties (Dependent)
		nFeatures             % The number of features
		featureInfo           % Additional data (structure) per feature
	end
	
	properties (GetAccess = 'protected',SetAccess = 'protected')
		featureInfoInternal
		featureNameModificationFunctionInternal
		featureNameModificationMaskInternal
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
		
		function self = set.featureNameModificationFunction(self, val)
			self.featureNameModificationFunctionInternal = val;
		end
		function val = get.featureNameModificationFunction(self)
			val = self.featureNameModificationFunctionInternal;
		end
		
		function self = set.featureNameModificationMask(self, val)
			self.featureNameModificationMaskInternal = val;
		end
		function val = get.featureNameModificationMask(self)
			val = self.featureNameModificationMaskInternal;
		end
		
		
		
	end
	
	methods (Access = 'protected',Hidden = true)
		
		function obj = catFeatureNames(obj,dataSet2)
			nOldFeatures = obj.nFeatures;
			% concatenate explicit featureNames
			for i = 1:dataSet2.nFeatures
				currFeatName = dataSet2.featureNameIntegerAssocArray.get(i);
				if ~isempty(currFeatName)
					obj.featureNameIntegerAssocArray = obj.featureNameIntegerAssocArray.put(obj.nFeatures + i, currFeatName);
				end
			end
			% pad featureNameModificationMasks with zeros to prepare for
			% concatenation
			if iscell(obj.featureNameModificationFunction)
				for iCell = 1:length(obj.featureNameModificationFunction)
					if ~isempty(obj.featureNameModificationFunction{iCell})
						obj.featureNameModificationMask{iCell} = cat(1,obj.featureNameModificationMask{iCell},zeros(dataSet2.nFeatures,1));
					end
				end
			else
				if ~isempty(obj.featureNameModificationFunction)
					obj.featureNameModificationMask = cat(1,obj.featureNameModificationMask,zeros(dataSet2.nFeatures,1));
				end
			end
			if iscell(dataSet2.featureNameModificationFunction)
				for iCell = 1:length(dataSet2.featureNameModificationFunction)
					if ~isempty(dataSet2.featureNameModificationFunction{iCell})
						dataSet2.featureNameModificationMask{iCell} = cat(1,zeros(nOldFeatures,1),dataSet2.featureNameModificationMask{iCell});
					end
				end
			else
				if ~isempty(dataSet2.featureNameModificationFunction)
					dataSet2.featureNameModificationMask = cat(1,zeros(nOldFeatures,1),dataSet2.featureNameModificationMask);
				end
			end
			% concatenate featureNameModificationFunctions and
			% featureNameModificationMasks
			if iscell(obj.featureNameModificationFunction)
				if iscell(dataSet2.featureNameModificationFunction)
					obj.featureNameModificationFunction = cat(1,obj.featureNameModificationFunction,dataSet2.featureNameModificationFunction);
					obj.featureNameModificationMask = cat(1,obj.featureNameModificationMask,dataSet2.featureNameModificationMask);
				else
					obj.featureNameModificationFunction = cat(1,obj.featureNameModificationFunction,{dataSet2.featureNameModificationFunction});
					obj.featureNameModificationMask = cat(1,obj.featureNameModificationMask,{dataSet2.featureNameModificationMask});
				end
			else
				if iscell(dataSet2.featureNameModificationFunction)
					obj.featureNameModificationFunction = cat(1,{obj.featureNameModificationFunction},dataSet2.featureNameModificationFunction);
					obj.featureNameModificationMask = cat(1,{obj.featureNameModificationMask},dataSet2.featureNameModificationMask);
				else
					obj.featureNameModificationFunction = {obj.featureNameModificationFunction;dataSet2.featureNameModificationFunction};
					obj.featureNameModificationMask = {obj.featureNameModificationMask;dataSet2.featureNameModificationMask};
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
				self.featureNameModificationFunction = [];
				self.featureNameModificationMask = [];
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
			self.featureNameModificationFunction = [];
			self.featureNameModificationMask = [];
		end
		
		function featNames = getFeatureNames(obj,indices)
			%names = getFeatureNames(dataSet)
			%  Return the current feature names.
			
			if nargin == 1
				indices = 1:obj.nFeatures;
			end
			indices = prtDataSetBase.parseIndices(obj.nFeatures,indices);
			
			% The code below requires indices not logicals.
			if islogical(indices)
				indices = find(indices);
			end
			
% 			for iCell = 1:length(obj.featureNameModificationFunction)
% 				if ~isempty(obj.featureNameModificationFunction{iCell})
% 					indices{iCell} = cumsum(obj.featureNameModificationMask{iCell});
% 				else
% 					indices{iCell};
% 				end
% 			end
			
			featNames = obj.featureNameIntegerAssocArray.get(indices);
			if ~isa(featNames,'cell')
				featNames = {featNames};
			end
			empty = cellfun(@(x)isempty(x),featNames);
			emptyInd = find(empty);
			featNames(emptyInd) = prtUtilGenerateDefaultFeatureNames(indices(emptyInd));
			
			% No modifications present
			if isempty(obj.featureNameModificationFunction)
				return
			end
			
			% Make feature names appear correctly by evaluating
			% modification function
            for iFeat = 1:length(indices)
                try
                    if iscell(obj.featureNameModificationFunction)
                        for iCell = 1:length(obj.featureNameModificationFunction)
                            if ~isempty(obj.featureNameModificationFunction{iCell}) && obj.featureNameModificationMask{iCell}(iFeat)
                                %featNames{iFeat} = obj.featureNameModificationFunction{iCell}(featNames{iFeat}, indices(iFeat));
                                featNames{iFeat} = obj.featureNameModificationFunction{iCell}(featNames{iFeat}, sum(obj.featureNameModificationMask{iCell}(1:iFeat)));
                            end
                        end
                    else
                        if ~isempty(obj.featureNameModificationFunction) && obj.featureNameModificationMask(iFeat)
                            featNames{iFeat} = obj.featureNameModificationFunction(featNames{iFeat}, indices(iFeat));
                        end
                    end
                catch ME
                end
            end
		end
		
		function d = getObservations(self,varargin)
			%d = getObservations(dataSet)
			%  Return dataSet.data
			
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
                if isa(featureIndices,'char')
                    featureIndices = {featureIndices};
                end
                if isa(featureIndices,'cell')
                    featureNames = obj.featureNames;
                    for i = 1:length(featureIndices)
                        cName = featureIndices{i};
                        featureIndices{i} = find(strcmpi(featureNames,cName));
                        if isempty(featureIndices{i})
                            error('prt:getFeatures:invalidFeature','The feature name provided: %s, does not match any of the available feature names',cName);
                        elseif ~isscalar(featureIndices{i})
                            warning('prt:getFeatures:duplicateFeature','The feature name provided: %s, matches more than one feature in the data set',cName);
                        end
                    end
                    featureIndices = cell2mat(featureIndices);
                end
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
			
            if isa(retainFeatureInds,'char')
                retainFeatureInds = {retainFeatureInds};
            end
            
            if isa(retainFeatureInds,'cell')
                origFeatureNames = retainFeatureInds;
                [isActuallyAClass, retainFeatureInds] = ismember(origFeatureNames,obj.getFeatureNames); %#ok<ASGLU>
                if any(~isActuallyAClass)
                    invalid = find(~isActuallyAClass);
                    error('prtDataSetStandard:retainFeatures:invalidString','The string %s did not match any feature names of the data set',origFeatureNames{invalid(1)});
                end
            end
            
% 			try
				obj = obj.retainFeatureNames(retainFeatureInds);
				obj.data = obj.data(:,retainFeatureInds);
				if ~isempty(obj.featureInfo)
					obj.featureInfo = obj.featureInfo(retainFeatureInds);
				end
% 			catch ME
% 				prtDataSetBase.parseIndices(obj.nFeatures, retainFeatureInds);
% 				throw(ME);
% 			end
			obj = obj.update;
		end
		
		function obj = permuteFeatures(obj,permuteFeatureInds)
			% dsOut = permuteFeatures(dataSet,permuteFeatureInds)
			%  Return a data set formed by independently, randomly
			%  permuting each of the specified features across
			%  observations.
			
			for i = 1:numel(permuteFeatureInds)
				newObsInds = randperm(obj.nObservations);
				obj.data(:,permuteFeatureInds(i)) = obj.data(newObsInds,permuteFeatureInds(i));
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
            if islogical(retainFeatureInds)
                retainFeatureInds = find(retainFeatureInds);
            end
			keys = 1:length(retainFeatureInds);
			names = self.featureNameIntegerAssocArray.get(retainFeatureInds);
			self.featureNameIntegerAssocArray = prtUtilIntegerAssociativeArray(keys,names);
            try
                if iscell(self.featureNameModificationFunction)
                    for iCell = 1:length(self.featureNameModificationMask)
                        if ~isempty(self.featureNameModificationMask{iCell})
                            self.featureNameModificationMask{iCell} = self.featureNameModificationMask{iCell}(retainFeatureInds);
                        end
                    end
                else
                    if ~isempty(self.featureNameModificationFunction)
                        self.featureNameModificationMask = self.featureNameModificationMask(retainFeatureInds);
                    end
                end
            catch ME
                % ME
            end
			% This could leave featureNameModificationFunctions that are
			% applied to no features. Is it worthwhile checking for this?
		end
    end
    
    methods
        function self = setFeatureInfo(self,varargin)
            
            if isempty(varargin{1})
                self.featureInfoInternal = varargin{1};
                return;
            end
            if length(varargin) == 1
                val = varargin{1};
            else
                origStruct = self.featureInfoInternal;
                val = prtUtilSimpleStruct(origStruct,varargin{:});
            end
            if ~isa(val,'struct')
                error('featureInfo must be a structure array');
            end
            if ~isvector(val)
                error('featureInfo must be a structure array');
            end
            if length(val) ~= self.nFeatures && self.nFeatures ~= 0
                error('featureInfo is length %d; should be a structure array of length %d',length(val),self.nFeatures);
            end
            self.featureInfoInternal = val(:)';
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
		function obj = loadobj(obj, baseClass)
			% We allow input baseClass here so that we can make a class of
			% the specified object 
			
			if isstruct(obj)
				if ~isfield(obj,'version')
					% Version 0 - we didn't even specify version
					inputVersion = 0;
				else
					inputVersion = obj.version;
				end
				
				%currentVersionObj = prtDataSetStandard;
				currentVersionObj = eval(baseClass); % Sorry about the eval
				
				if inputVersion > currentVersionObj.version
					% Version newer than current version!
					warning('prt:prtDataSetClass:loadNewVersion','Attempt to load an updated prtDataSetClass from file. This prtDataSetClass was saved using a new version of the PRT. This dataset may not load properly.')
				end
				
				inObj = obj;
				obj = currentVersionObj;
				switch inputVersion
					case {0,1}
						
						obj = obj.setObservationsAndTargets(inObj.dataDepHelper, inObj.targetsDepHelper);
						
						obj.observationInfo = inObj.observationInfoDepHelper;
						
						if ~isempty(inObj.featureInfoDepHelper);
							obj.featureInfo = inObj.featureInfoDepHelper;
						end
						
						if ~isempty(inObj.featureNamesDepHelper)
							obj = obj.setFeatureNames(inObj.featureNamesDepHelper.cellValues,inObj.featureNamesDepHelper.integerKeys);
						end
						
						if ~isempty(inObj.observationNamesInternal.cellValues)
							obj = obj.setObservationNames(inObj.observationNamesInternal.cellValues,inObj.observationNamesInternal.integerKeys);
						end
						
						if ~isempty(inObj.targetNamesInternal)
							obj = obj.setTargetNames(inObj.targetNamesInternal.cellValues);
						end
						
						obj.name = inObj.name;
						obj.description = inObj.description;
						obj.userData = inObj.userData;
						
						
					case 2
						obj = obj.setObservationsAndTargets(inObj.internalData ,inObj.internalTargets);
						obj.observationInfo = inObj.observationInfoInternal;
						
						if ~isempty(inObj.featureInfoInternal);
							obj.featureInfo = inObj.featureInfoInternal;
						end
						
						if ~isempty(inObj.featureNameIntegerAssocArray)
							obj = obj.setFeatureNames(inObj.featureNameIntegerAssocArray.cellValues,inObj.featureNameIntegerAssocArray.integerKeys);
						end
						
						if ~isempty(inObj.observationNamesInternal.cellValues)
							obj = obj.setObservationNames(inObj.observationNamesInternal.cellValues,inObj.observationNamesInternal.integerKeys);
						end
						
						if ~isempty(inObj.targetNamesInternal)
							obj = obj.setTargetNames(inObj.targetNamesInternal.cellValues);
						end
						
						obj.name = inObj.name;
						obj.description = inObj.description;
						obj.userData = inObj.userData;
					
					case 3
						
						obj.plotOptions = inObj.plotOptions;
						
						obj = obj.setObservationsAndTargets(inObj.internalData ,inObj.internalTargets);
						obj.observationInfo = inObj.observationInfoInternal;
						
						if ~isempty(inObj.featureInfoInternal);
							obj.featureInfo = inObj.featureInfoInternal;
						end
						
						if ~isempty(inObj.featureNameIntegerAssocArray)
							obj = obj.setFeatureNames(inObj.featureNameIntegerAssocArray.cellValues,inObj.featureNameIntegerAssocArray.integerKeys);
						end
						
						if ~isempty(inObj.observationNamesInternal.cellValues)
							obj = obj.setObservationNames(inObj.observationNamesInternal.cellValues,inObj.observationNamesInternal.integerKeys);
						end
						
						if ~isempty(inObj.targetNamesInternal)
							obj = obj.setTargetNames(inObj.targetNamesInternal.cellValues);
						end
						
						obj.name = inObj.name;
						obj.description = inObj.description;
						obj.userData = inObj.userData;
				end
				
			else
				% Nothin special hopefully?
				% How did this happen?
				% Hopefully it works out.
			end
		end
	end
	
	
	methods (Hidden)
		function dsOut = crossValidateCombineFoldResults(dsTestCell_first, dsTestCell, testIndices)
			% dsOut = crossValidateCombineFoldResults(dsTestCell_first, dsTestCell, testIndices)
			%
			% Combine the results of crossVal folds into one output dataset
			
			% This is overloaded from prtDataSetBase to provide more useful
			% error messages
			
			assert(length(unique(cellfun(@(c)c.nFeatures,dsTestCell)))==1,'The number of features is different across the output of the cross-validation folds. This may indicate a problem with the cross-validation keys or perhaps the action.');
			dsOut = crossValidateCombineFoldResults@prtDataSetBase(dsTestCell_first, dsTestCell, testIndices);
		end
		
		function self = modifyNonDataAttributesFrom(self, action)
			% Modify the non-data attributes of dataset self given an
			% action.
			%
			% This allows actions to set feature names 
			
 			modFun = action.getFeatureNameModificationFunction();
            currentModFun = self.featureNameModificationFunction;
			currentModMask = self.featureNameModificationMask;
 			if ~isempty(modFun)
 				if isempty(currentModFun)
 					self.featureNameModificationFunction = modFun;
					self.featureNameModificationMask = ones(self.nFeatures,1);
                elseif iscell(currentModFun)
                    self.featureNameModificationFunction = cat(1,currentModFun,{modFun});
					self.featureNameModificationMask = cat(1,currentModMask,{ones(self.nFeatures,1)});
                else % Currently a single function handle (hopefully)
                    self.featureNameModificationFunction = {currentModFun;modFun};
					self.featureNameModificationMask = {currentModMask;ones(self.nFeatures,1)};
				end
			end
            
            %           % Nested function handles get very slow to make
            %           % This method was replaced with cell array method
            % 			modFun = action.getFeatureNameModificationFunction();
            %           currentModFun = self.featureNameModificationFunction;
            % 			if ~isempty(modFun)
            % 				if isempty(currentModFun)
            % 					self.featureNameModificationFunction = modFun;
            % 				else
            % 					self.featureNameModificationFunction = @(nameIn, index)modFun(currentModFun(nameIn, index),index);
            % 				end
            % 			end
            
			self = modifyNonDataAttributesFrom@prtDataSetBase(self, action);
		end
	end
end
