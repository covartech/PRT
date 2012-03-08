classdef prtDataSetStandard < prtDataSetInMem
   
    properties (Dependent, Hidden)
        featureNames
    end
    
    properties (Dependent)
        nFeatures             % The number of features
    end
    
    properties
        featureInfo           % Additional data (structure) per feature
    end
    
    properties (GetAccess = 'protected', SetAccess = 'protected', Hidden = true)
        featureNameIntegerAssocArray = prtUtilIntegerAssociativeArray;
    end
    
    methods
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
        
        function d = getObservations(self,varargin)
            
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
            % FEATURES = dataSet.getFeatures() returns the features of the
            % dataSet object
            %
            % FEATURES = dataSet.getFeatures(INDICES) returns only the
            % features of the dataSet object specified by INDICES
            
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
            % setFeatures   Set the features of a prtDataSetStandard object
            
            obj.data(:,varargin{:}) = data;
            obj = obj.update;
        end
        
        function obj = catFeatures(obj, varargin)
            
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
            
            if islogical(removeFeatureInds)
                removeFeatureInds = find(removeFeatureInds);
            end
            retainFeatureInds = setdiff(1:obj.nFeatures,removeFeatureInds);
            [obj,retainFeatureInds] = retainFeatures(obj,retainFeatureInds);
            obj = obj.update;
        end
        
        function [obj,retainFeatureInds] = retainFeatures(obj,retainFeatureInds)
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
        
        %         function obj = set.featureInfo(obj,Struct)
        %             error('not done');
        %             obj.featureInfoDepHelper = Struct(:)';
        %         end
        %
        %         function val = get.featureInfo(obj)
        %             val = obj.featureInfoDepHelper;
        %         end
        
        %         function [obj,keep] = select(obj, selectFunction)
        %             % Select observations to retain by specifying a function
        %             %   The specified function is evaluated on each obesrvation.
        %             %
        %             % selectedDs = ds.select(selectFunction);
        %             %
        %             % There are two ways to define selectionFunction
        %             %   One input, One logical vector output
        %             %       selectFunction recieves the input data set and must
        %             %       output a nObservations by 1 logical vector.
        %             %   One input, One logical scalar output
        %             %       selectFunction recieves the ObservatioinInfo structure
        %             %       of a single observation.
        %             %
        %             % Examples:
        %             %   ds = prtDataGenIris;
        %             %   ds = ds.setobservationInfo('asdf',randn(ds.nObservations,1));
        %             %
        %             %   dsSmallobservationInfoSelect = ds.select(@(ObsInfo)ObsInfo.asdf > 0.5);
        %             %
        %             %   dsSmallObservationSelect = ds.select(@(inputDs)inputDs.getObservations(:,1)>6);
        %
        %             assert(isa(selectFunction, 'function_handle'),'selectFunction must be a function handle.');
        %             assert(nargin(selectFunction)==1,'selectFunction must be a function handle that take a single input.');
        %
        %             try
        %                 keep = selectFunction(obj);
        %                 assert(size(keep,1)==obj.nObservations);
        %                 assert(islogical(keep) || (isnumeric(keep) && all(ismember(keep,[0 1]))));
        %             catch %#ok<CTCH>
        %                 if isempty(obj.observationInfo)
        %                     error('prt:prtDataSetStandard:select','selectFunction did not return a logical vector with nObservation elements and this data set object does not contain observationInfo. Therefore this selecFunction is not valid.')
        %                 end
        %
        %                 try
        %                     keep = arrayfun(@(s)selectFunction(s),obj.observationInfo);
        %                 catch %#ok<CTCH>
        %                     % Try the loopy version
        %                     keep = false(obj.nObservations,1);
        %                     for iObs = 1:obj.nObservations
        %                         try
        %                             cOut = selectFunction(obj.observationInfo(iObs));
        %                         catch %#ok<CTCH>
        %                             error('prt:prtDataSetStandard:select','selectFunction did not return a logical vector with nObservation elements and there was an evaluation error using this function. See help prtDataSetStandard/select');
        %                         end
        %                         assert(numel(cOut)==1,'selectFunction did not return a logical vector with nObservation elements but also did not return scalar logical.');
        %                         assert((islogical(cOut) || (isnumeric(cOut) && (cOut==0 || cOut==1))),'selectFunction that returns one output must output a 1x1 logical.');
        %
        %                         keep(iObs) = cOut;
        %                     end
        %                 end
        %             end
        %             obj = obj.retainObservations(keep);
        %         end
        %
        %         function val = getObservationInfo(obj,fieldName)
        %             % Allow for fast retrieval of observation info by specifying
        %             % the field name(fieldName)
        %             %
        %             % DS = prtDataGenIris;
        %             % DS = DS.setObservationInfo('asdf',randn(DS.nObservations,1),'qwer',randn(DS.nObservations,1),'poiu',randn(DS.nObservations,10),'lkjh',mat2cell(randn(DS.nObservations,1),ones(DS.nObservations,1),1),'mnbv',mat2cell(randn(DS.nObservations,10),ones(DS.nObservations,1),10));
        %             % vals = DS.getObservationInfo('asdf');
        %
        %             if nargin == 1
        %                 val = obj.observationInfo;
        %                 return
        %             end
        %
        %             assert(nargin==2,'prt:prtDataSetStandard:getObservationInfo','invalid number of input arguments, only one input argument should be specified.');
        %
        %             assert(ischar(fieldName),'prt:prtDataSetStandard:getObservationInfo','fieldName must be a string');
        %
        %             assert(isfield(obj.observationInfo,fieldName),'prt:prtDataSetStandard:getObservationInfo','%s is not a field name of observationInfo for this dataset',fieldName);
        %
        %             try
        %                 val = cat(1,obj.observationInfo.(fieldName));
        %             catch %#ok<CTCH>
        %                 % This failed because of invalid matrix dimensions
        %                 val = [];
        %             end
        %             if size(val,1) == obj.nObservations
        %                 % Everything worked out, value in observationInfo
        %                 % is a row vector of contstant size
        %                 % leave now
        %                 return
        %             else
        %                 % Failure, or invalid size, so we return a cell
        %                 try
        %                     val = {obj.observationInfo.(fieldName)}';
        %                 catch %#ok<CTCH>
        %                     error('prt:prtDataSetStandard:getObservationInfo','getObservationInfo failed to retrieve the necessary field for an unknown reason');
        %                 end
        %             end
        %         end
        
        %         function val = getFeatureInfo(obj,fieldName)
        %             % Allow for fast retrieval of feature info by specifying
        %             % the field name(fieldName)
        %             %
        %             % DS = prtDataGenIris;
        %             % DS = DS.setFeatureInfo('asdf',randn(DS.nFeatures,1),'qwer',randn(DS.nFeatures,1),'poiu',randn(10,DS.nFeatures),'lkjh',mat2cell(randn(1,DS.nFeatures),1,ones(1,DS.nFeatures)),'mnbv',mat2cell(randn(10,DS.nFeatures),10,ones(DS.nFeatures,1)));
        %             % vals = DS.getFeatureInfo('asdf');
        %
        %             assert(nargin==2,'prt:prtDataSetStandard:getFeatureInfo','invalid number of input arguments, only one input argument should be specified.');
        %
        %             assert(ischar(fieldName),'prt:prtDataSetStandard:getFeatureInfo','fieldName must be a string');
        %
        %             assert(isfield(obj.featureInfo,fieldName),'prt:prtDataSetStandard:getFeatureInfo','%s is not a field name of featureInfo for this dataset',fieldName);
        %
        %             try
        %                 val = cat(2,obj.featureInfo.(fieldName));
        %             catch %#ok<CTCH>
        %                 % This failed because of invalid matrix dimensions
        %                 val = [];
        %             end
        %             if size(val,2) == obj.nFeatures
        %                 % Everything worked out, value in observationInfo
        %                 % is a row vector of contstant size
        %                 % leave now
        %                 return
        %             else
        %                 % Failure, or invalid size, so we return a cell
        %                 try
        %                     val = {obj.featureInfo.(fieldName)};
        %                 catch %#ok<CTCH>
        %                     error('prt:prtDataSetStandard:getFeatureInfo','getFeatureInfo failed to retrieve the necessary field for an unknown reason');
        %                 end
        %             end
        %         end
        
        %         function obj = setObservationInfo(obj,varargin)
        %             % Allow setting of observation info by specifying string value
        %             % pairs
        %             %
        %             % DS = prtDataGenIris;
        %             % DS = DS.setObservationInfo('asdf',randn(DS.nObservations,1),'qwer',randn(DS.nObservations,1),'poiu',randn(DS.nObservations,10),'lkjh',mat2cell(randn(DS.nObservations,1),ones(DS.nObservations,1),1),'mnbv',mat2cell(randn(DS.nObservations,10),ones(DS.nObservations,1),10));
        %
        %             nIn = length(varargin);
        %             if nIn == 1
        %                 % should be a struct. if it isn't will just
        %                 % let set.observationInfo() spit the error
        %                 obj.observationInfo = varargin{1};
        %                 return
        %             end
        %
        %             errorMsg = 'Invalid input. If more than one input is specified, the inputs must be string value pairs.';
        %             assert(mod(length(varargin),2)==0, errorMsg)
        %             paramNames = varargin(1:2:end);
        %             params = varargin(2:2:end);
        %
        %             assert(iscellstr(paramNames), errorMsg)
        %
        %             cStruct = obj.observationInfo;
        %             if isempty(cStruct)
        %                 startingFieldNames = {};
        %             else
        %                 startingFieldNames = fieldnames(cStruct);
        %             end
        %
        %             for iParam = 1:length(paramNames)
        %
        %                 cVal = params{iParam};
        %                 cName = paramNames{iParam};
        %                 assert(isvarname(cName),'observationInfo fields must be valid MATLAB variable names. %s is not.',cName);
        %
        %                 if ismember(cName,startingFieldNames)
        %                     % warning('prt:observationInfoNameCollision','An observationInfo field named %s already exists. The data is now overwritten.', cName)
        %                     % This warning is unnecessary
        %                 end
        %                 assert(size(cVal,1) == obj.nObservations,'observationInfo values must have nObservations rows.');
        %
        %                 if iscellstr(cVal)
        %                     cValSet = cVal;
        %                 else
        %                     cValSet = mat2cell(cVal,ones(size(cVal,1),1),size(cVal,2));
        %                 end
        %
        %                 if isempty(cStruct)
        %                     cStruct = struct(cName,cValSet);
        %                 else
        %                     for iObs = 1:obj.nObservations
        %                         cStruct(iObs).(cName) = cValSet{iObs,:};
        %                     end
        %                 end
        %             end
        %
        %             obj.observationInfo = cStruct;
        %         end
        %
        %         function obj = setFeatureInfo(obj,varargin)
        %             % Allow setting of feature info by specifying string value
        %             % pairs
        %             %
        %             % DS = prtDataGenIris;
        %             % DS = DS.setFeatureInfo('asdf',randn(DS.nFeatures,1),'qwer',randn(DS.nFeatures,1),'poiu',randn(10,DS.nFeatures),'lkjh',mat2cell(randn(1,DS.nFeatures),1,ones(1,DS.nFeatures)),'mnbv',mat2cell(randn(10,DS.nFeatures),10,ones(DS.nFeatures,1)));
        %
        %             nIn = length(varargin);
        %             if nIn == 1
        %                 % should be a struct. if it isn't we'll just
        %                 % let set.featureInfo() spit the error
        %                 obj.featureInfo = varargin{1};
        %                 return
        %             end
        %
        %             errorMsg = 'Invalid input. If more than one input is specified, the inputs must be string value pairs.';
        %             assert(mod(length(varargin),2)==0, errorMsg)
        %             paramNames = varargin(1:2:end);
        %             params = varargin(2:2:end);
        %
        %             assert(iscellstr(paramNames), errorMsg)
        %
        %             cStruct = obj.featureInfo;
        %             if isempty(cStruct)
        %                 startingFieldNames = {};
        %             else
        %                 startingFieldNames = fieldnames(cStruct);
        %             end
        %
        %             for iParam = 1:length(paramNames)
        %
        %                 cVal = params{iParam};
        %                 cName = paramNames{iParam};
        %                 assert(isvarname(cName),'featureInfo fields must be valid MATLAB variable names. %s is not.',cName);
        %
        %                 if ismember(cName,startingFieldNames)
        %                     % warning('prt:observationInfoNameCollision','An observationInfo field named %s already exists. The data is now overwritten.', cName)
        %                     % This warning is unnecessary
        %                 end
        %                 if isvector(cVal)
        %                     cVal = cVal(:)';
        %                 end
        %                 assert(size(cVal,2) == obj.nFeatures,'featureInfo values must have nFeatures columns.');
        %
        %                 cValSet = mat2cell(cVal,size(cVal,1),ones(1,size(cVal,2)));
        %
        %                 if isempty(cStruct)
        %                     cStruct = struct(cName,cValSet);
        %                 else
        %                     for iFeat = 1:obj.nFeatures
        %                         cStruct(iFeat).(cName) = cValSet{:,iFeat};
        %                     end
        %                 end
        %             end
        %
        %             obj.featureInfo = cStruct;
        %         end
        %
        %         function obj = catTargets(obj, varargin)
        %             % catTargets  Concatenate the targets of a prtDataSetStandard
        %             % object
        %             %
        %             % dataSet = dataSet.catTargets(TARGETS) concatenates the
        %             % targets with TARGETS. TARGETS must have the same number of
        %             % observations as dataSet.
        %
        %             if nargin == 1
        %                 return;
        %             end
        %             for argin = 1:length(varargin)
        %                 currInput = varargin{argin};
        %                 if isa(currInput,class(obj.getTargetsAsMatrix))
        %                     obj = obj.setTargetsFromMatrix(cat(2, obj.getTargetsAsMatrix, currInput));
        %                 elseif isa(currInput,'prtDataSetStandard')
        %                     obj = obj.catTargetNames(currInput);
        %                     obj = obj.setTargetsFromMatrix(cat(2, obj.getTargetsAsMatrix, currInput.getTargetsAsMatrix));
        %                 end
        %             end
        %             % Updated chached target info
        %             obj = updateTargetsCache(obj);
        %         end
        %
        %
        %         function [obj,retainedTargets] = removeTargets(obj,removeIndices)
        %             % removeTargets  Remove targets from a prtDataSetStandard
        %             % object.
        %             %
        %             % dataSet = dataSet.retainTargets(INDICES) removes the targets
        %             % from the dataSet object specified by INDICES
        %
        %             warning('prt:Fixable','Does not handle feature names');
        %
        %             removeIndices = prtDataSetBase.parseIndices(obj.nTargetDimensions,removeIndices);
        %
        %             if islogical(removeIndices)
        %                 keepFeatures = ~removeIndices;
        %             else
        %                 keepFeatures = setdiff(1:obj.nFeatures,removeIndices);
        %             end
        %             [obj,retainedTargets] = retainTargets(obj,keepFeatures);
        %         end
        %
        %         function [obj,retainedTargets] = retainTargets(obj,retainedTargets)
        %             % retainTargets  Retain targets from a prtDataSetStandard
        %             % object.
        %             %
        %             % dataSet = dataSet.retainTargets(INDICES) removes all targets
        %             % from the dataSet object except those specified by INDICES
        %
        %             retainedTargets = prtDataSetBase.parseIndices(obj.nTargetDimensions ,retainedTargets);
        %             obj = obj.retainTargetNames(retainedTargets);
        %             obj.t = obj.setTargetsFromMatrix(obj.getTargetsAsMatrix(:,retainedTargets));
        %
        %             % Updated chached target info
        %             obj = updateTargetsCache(obj);
        %         end
        
        %this might could be moved to prtDataInterfaceCategorical...
        function keys = getKFoldKeys(DataSet,K)
            if DataSet.isLabeled
                keys = prtUtilEquallySubDivideData(DataSet.getTargets(),K);
            else
                %can cross-val on unlabeled data, too!
                keys = prtUtilEquallySubDivideData(ones(DataSet.nObservations,1),K);
            end
        end
        
    end
    %
    %     methods (Hidden=true, Access='protected')
    %         function obj = updateTargetsCache(obj)
    %             % By default do nothing
    %             % This is can be overloaded in sub-classes
    %             % For example. this is overloaded in prtDataSetClass to cache
    %             % unique(targets) amounst other things
    %         end
    %         function obj = updateObservationsCache(obj)
    %             % By default do nothing
    %             % This is can be overloaded in sub-classes
    %         end
    %
    %         function obj = catObservationInfo(obj, oldObservationInfo, newDataSet)
    %
    %             if isempty(oldObservationInfo) || (isempty(fieldnames(oldObservationInfo)) && isempty(fieldnames(newDataSet.observationInfo)))
    %                 % No observationInfo was set in either dataset so just exit
    %                 % and accept the default empty
    %                 return;
    %             end
    %
    %             obj.observationInfo = prtUtilStructVCatMergeFields(oldObservationInfo,newDataSet.observationInfo);
    %         end
    %
    
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
            obj.featureInfo = prtUtilStructVCatMergeFields(oldFeatureInfo(:),newFeatureInfo(:))';
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
        
        function self = setFeatureNames(self,names,featureIndices)
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
                        if ~isempty(inObj.featureNames.cellValues)
                            obj = obj.setFeatureNames(inObj.featureNames.cellValues);
                        end
                        if ~isempty(inObj.observationNames.cellValues)
                            obj = obj.setObservationNames(inObj.observationNames.cellValues);
                        end
                        if ~isempty(inObj.targetNames.cellValues)
                            obj = obj.setTargetNames(inObj.targetNames.cellValues);
                        end
                        obj.plotOptions = inObj.plotOptions;
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