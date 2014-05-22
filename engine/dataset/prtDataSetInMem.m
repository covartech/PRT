classdef prtDataSetInMem < prtDataSetBase
    % prtDataSetInMem
    %   Extends prtDataSetBase to include data, targets, and observation
    %   info that are assumed to be in memory. It also addes observation
    %   and target names
    %
    % Properties:
    %   observationInfo - Structure array holding additional
    %                     data per related to each observation
    %
    % Methods:
    %   getObservationNames - get the observation names
    %   setObservationNames - set the observation names
    %
    %   getTargetNames      - get the target names
    %   setTargetNames      - set the target names
    %
    
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
    
    
    properties (SetAccess = protected,GetAccess = protected)
        internalData
        internalTargets
        internalSizeConsitencyCheck = true;
    end
    
    properties (Dependent)
        data
        targets
    end
    
    properties (Dependent, Hidden)
        observationNames      % Dependent variable providing access to observation names
        targetNames           % Dependent variable providing access to target names
    end
    properties (Dependent)
        observationInfo       % Struct of observation information
    end
    
    properties (Hidden)
        targetInfo            % Struct of target information
    end
    
    % Only prtDataSetBase knows about these, use getObs... and getFeat.. to
    % get and set these, they handle the dirty stuff
    properties (GetAccess = 'protected',SetAccess = 'protected')
        observationNamesInternal    % The observations names
        observationInfoInternal     % The observation info struct
        targetNamesInternal         % The target names.
    end
    
    methods
        function self = prtDataSetInMem
            self.observationNamesInternal = prtUtilIntegerAssociativeArray;
            self.targetNamesInternal = prtUtilIntegerAssociativeArray;
        end
    end
    
    
    % Observation and Target info and names
    methods
        
        function obsNames = get.targetNames(self)
            obsNames = self.getTargetNames;
        end
        
        function self = set.targetNames(self,vals)
            self = self.setTargetNames(vals);
        end
        
        function obsNames = get.observationNames(self)
            obsNames = self.getObservationNames;
        end
        
        function self = set.observationNames(self,vals)
            self = self.setObservationNames(vals);
        end
        
        function self = set.observationInfo(self,val)
            self = self.setObservationInfo(val);
        end
        
        function val = get.observationInfo(self)
            val = self.observationInfoInternal;
        end
        
        function val = getObservationInfo(self,varargin)
            %obsInfo = getObservationInfo(dataSet)
            % Return the observationInfo structure from the dataSet.
            %
            % observationInfo can be used to store arbitrary information
            % about a data set.
            %
            
            if nargin < 2
                val = self.observationInfoInternal;
                return;
            elseif nargin == 2
                if isa(varargin{1},'char')
                    try
                        val = cat(1,self.observationInfoInternal.(varargin{1}));
                        if ~(size(val,1) == self.nObservations)
                            error('Going to catch');
                        end
                    catch %#ok<CTCH>
                        val = {self.observationInfoInternal.(varargin{1})}';
                    end
                    
                    return;
                else
                    val = self.observationInfoInternal(varargin{:});
                end
            end
        end
        
        function self = setObservationInfo(self,varargin)
            %dataSet = setObservationInfo(dataSet,obsInfoStruct)
            % Set the observationInfo field of the data set to the
            % structure array obsInfoStruct.  obsInfoStruct should be
            % dataSet.nObservations x 1.
            %
            % observationInfo can be used to store arbitrary information
            % about a data set.
            %
            if isempty(varargin{1})
                self.observationInfoInternal = varargin{1};
                return;
            end
            if length(varargin) == 1
                val = varargin{1};
            else
                origStruct = self.observationInfoInternal;
                val = prtUtilSimpleStruct(origStruct,varargin{:});
            end
            if ~isa(val,'struct')
                error('observationInfo must be a structure array');
            end
            if ~isvector(val)
                error('observationInfo must be a structure array');
            end
            if numel(val) ~= self.nObservations && self.nObservations ~= 0
                error('observationInfo is length %d; should be a structure array of length %d',length(val),self.nObservations);
            end
            self.observationInfoInternal = val(:);
        end
        
    end
    
    % get. and set. methods that call get* and set*
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
    end
    
    methods
        function self = retainObservations(self,indices)
            % dsOut = removeObservations(dataSet,indices)
            %   Return a data set, dsOut, created by retaining the
            %   observations specified by indices from the input dataSet.
            %
            
            self = self.retainObservationInfo(indices);
            self = self.retainObservationData(indices);
            self = self.update;
        end
        
        function self = catObservations(self,varargin)
            % dsOut = catObservations(dataSet1,dataSet2)
            %   Return a data set, dsOut, created by concatenating the
            %   data and observationInfo in dataSet1 and dataSet2.  The
            %   output data set, dsOut, will have nObservations =
            %   dataSet1.nObservations + dataSet2.nObservations.
            %
            if nargin == 1 && length(self) > 1
                varargin = num2cell(self(2:end));
                self = self(1);
            end
            self = self.catObservationInfo(varargin{:});
            self = self.catObservationData(varargin{:});
            self = self.update;
        end
        
        function self = setObservations(self,data,varargin)
            % dataSet = setObservations(dataSet,data)
            %  This is outdated, use dataSet.data = ...;
            self = self.setData(data,varargin{:});
        end
        
        function self = setObservationsAndTargets(self,data,targets)
            %dataSet = setObservationsAndTargets(dataSet,data,targets)
            % Replace both the data and targets in a data set with new
            % "data" and "targets".  The inputs should have the same size
            % in the first dimension.
            %
            % setObservationsAndTargets is useful when the size of a data
            % set has to change.
            %
            
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
            %d = getObservations(dataSet)
            %  This is outdated, use dataSet.data(...)
            %
            try
                d = self.data(varargin{:});
            catch ME
                prtDataSetBase.parseIndices(self.nObservations,varargin{:});
                throw(ME);
            end
            
        end
        
        function self = removeTargets(self,indices)
            % dsOut = removeTargets(dataSet,indices)
            %   Remove the target columns specified by indices from the
            %   dataSet target matrix.
            %
            if islogical(indices)
                indices = ~indices;
            else
                indices = setdiff(1:self.nTargetDimensions,indices);
            end
            self = self.retainTargets(self,indices);
        end
        
        function self = retainTargets(self,indices)
            % dsOut = retainTargets(dataSet,indices)
            %   Retain the target columns specified by indices in the
            %   dataSet target matrix.
            %
            self.Y = self.Y(:,indices);
            self.targetNamesInternal = self.targetNamesInternal.retain(indices);
            self = self.update;
        end
        
        function self = catTargets(self,varargin)
            % dsOut = catTargets(dataSet1,dataSet2)
            %   Return a new data set with targets formed by the
            %   concatenation of dataSet1.targets and dataSet2.targets.
            %
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
        
        function nTargets = getNumTargetDimensions(self)
            %nTargets = getNumTargetDimensions(dataSet)
            % Return the size(dataSet.targets,2)
            %
            nTargets = size(self.targets,2);
        end
        
        function n = getNumObservations(self)
            %nObs = getNumObservations(dataSet)
            % Return the number of observations
            %
            if isempty(self.data)
                n = size(self.targets,1);
            else
                n = size(self.data,1);
            end
        end
        
        function data = getData(self,varargin)
            % data = getData(dataSet)
            %  Return dataSet.data
            
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
            % targets = getTargets(dataSet)
            %  Return dataSet.targets
            
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
            %dsOut = setData(dataSet,dataIn)
            % Return a new data set, dsOut, with data specified by dataIn.
            %
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
            %dsOut = setTargets(dataSet,dataIn)
            % Return a new data set, dsOut, with targets specified by dataIn.
            %
            
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
        
        function obsNames = getObservationNames(self,varargin)
            % getObservationNames - Return DataSet's Observation Names
            %
            %   obsNames = getObservationNames(self) Return a cell array of
            %   an object's observation names; if setObservationNames has not been
            %   called or the 'observationNames' field was not set at construction,
            %   default behavior is to return sprintf('Observation %d',i) for all
            %   observations.
            %
            %   obsNames = getObservationNames(self,indices) Return the observation
            %   names for only the specified indices.
            
            indices1 = prtDataSetBase.parseIndices(self.nObservations,varargin{:});
            %parse returns logicals
            if islogical(indices1)
                indices1 = find(indices1);
            end
            
            obsNames = cell(length(indices1),1);
            
            for i = 1:length(indices1)
                obsNames{i} = self.observationNamesInternal.get(indices1(i));
                if isempty(obsNames{i})
                    obsNames(i) = prtUtilGenerateDefaultObservationNames(indices1(i));
                end
            end
        end
        
        function targetNames = getTargetNames(self,varargin)
            % getTargetNames  Return the target names from a dataset
            %
            
            indices2 = prtDataSetBase.parseIndices(self.nTargetDimensions,varargin{:});
            %parse returns logicals
            if islogical(indices2)
                indices2 = find(indices2);
            end
            
            targetNames = cell(length(indices2),1);
            
            for i = 1:length(indices2)
                targetNames{i} = self.targetNamesInternal.get(indices2(i));
                if isempty(targetNames{i})
                    targetNames(i) = prtUtilGenerateDefaultTargetNames(indices2(i));
                end
            end
        end
        
        function self = setObservationNames(self,obsNames,varargin)
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
            
            indices1 = prtDataSetBase.parseIndices(self.nObservations,varargin{:});
            %parse returns logicals; find the indices
            if islogical(indices1)
                indices1 = find(indices1);
            end
            
            if length(obsNames) ~= length(indices1)
                error('prt:dataSetStandard:setObservationNames','Size mismatch between indices and observation names.');
            end
            
            for i = 1:length(indices1)
                self.observationNamesInternal = self.observationNamesInternal.put(indices1(i),obsNames{i});
            end
        end
        
        function self = setTargetNames(self,targetNames,varargin)
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
            
            indices2 = prtDataSetBase.parseIndices(self.nTargetDimensions,varargin{:});
            %parse returns logicals
            if islogical(indices2)
                indices2 = find(indices2);
            end
            if length(targetNames) ~= length(indices2)
                if nargin == 2
                    error('prt:prtDataSetBase','Attempt to set target names for different number of targets (%d) than data set has (%d)',length(targetNames),length(max(indices2)));
                else
                    error('prt:prtDataSetBase','Too many indices (%d) provided for number of target names provited (%d)',length(indices2),length(targetNames));
                end
            end
            %Put the default string names in there; otherwise we might end
            %up with empty elements in the cell array
            for i = 1:length(indices2)
                self.targetNamesInternal = self.targetNamesInternal.put(indices2(i),targetNames{i});
            end
        end
    end
    
    % Other useful methods
    methods
        function [obj,keep] = select(obj, selectFunction)
            % Select observations to retain by specifying a function
            %   The specified function is evaluated on each obesrvation.
            %
            % selectedDs = ds.select(selectFunction);
            %
            % There are two ways to define selectionFunction
            %   One input, One logical vector output
            %       selectFunction recieves the input data set and must
            %       output a nObservations by 1 logical vector.
            %   One input, One logical scalar output
            %       selectFunction recieves the ObservatioinInfo structure
            %       of a single observation.
            %
            % Examples:
            %   ds = prtDataGenIris;
            %   ds = ds.setObservationInfo(struct('asdf',num2cell(randn(ds.nObservations,1))));
            %
            %   dsSmallobservationInfoSelect = ds.select(@(ObsInfo)ObsInfo.asdf > 0.5);
            %
            %   dsSmallObservationSelect = ds.select(@(inputDs)inputDs.getObservations(:,1)>6);
            
            assert(isa(selectFunction, 'function_handle'),'selectFunction must be a function handle.');
            assert(nargin(selectFunction)==1,'selectFunction must be a function handle that take a single input.');
            
            if isempty(obj.observationInfo)
                error('prtDataSetBase:select','Attempt to apply a select function to an empty observationInfo');
            end
            
            try
                keep = selectFunction(obj);
                assert(size(keep,1)==obj.nObservations);
                assert(islogical(keep) || (isnumeric(keep) && all(ismember(keep,[0 1]))));
            catch %#ok<CTCH>
                if isempty(obj.observationInfo)
                    error('prt:prtDataSetStandard:select','selectFunction did not return a logical vector with nObservation elements and this data set object does not contain observationInfo. Therefore this selecFunction is not valid.')
                end
                
                try
                    keep = arrayfun(@(s)selectFunction(s),obj.observationInfo);
                catch %#ok<CTCH>
                    % Try the loopy version
                    keep = false(obj.nObservations,1);
                    for iObs = 1:obj.nObservations
                        try
                            cOut = selectFunction(obj.observationInfo(iObs));
                        catch %#ok<CTCH>
                            error('prt:prtDataSetStandard:select','selectFunction did not return a logical vector with nObservation elements and there was an evaluation error using this function. See help prtDataSetStandard/select');
                        end
                        assert(numel(cOut)==1,'selectFunction did not return a logical vector with nObservation elements but also did not return scalar logical.');
                        assert((islogical(cOut) || (isnumeric(cOut) && (cOut==0 || cOut==1))),'selectFunction that returns one output must output a 1x1 logical.');
                        
                        keep(iObs) = cOut;
                    end
                end
            end
            obj = obj.retainObservations(keep);
        end
    end
    
    % Internal required or helper methods
    methods (Hidden = true)
        %Don't call these; they get called internally
        
        function Summary = summarize(self,Summary)
            % Summarize   Summarize the prtDataSetStandard object
            %
            % SUMMARY = dataSet.summarize() Summarizes the prtDataSetStandard
            % object and returns the result in the struct SUMMARY.
            if nargin == 1
                Summary = struct;
            end
            Summary.nObservations = self.nObservations;
        end
        
        function self = catObservationData(self, varargin)
            % dsOut = catObservationData(dataSet1,dataSet2)
            %
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
        
        function self = retainObservationData(self,indices)
            
            self.internalSizeConsitencyCheck = false;
            try
                if self.nFeatures > 0 % No data?
                    self.data = self.data(indices,:);
                end
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
    
    % Methods for retaining and cating observation and target names and
    % observation info
    methods (Access = 'protected', Hidden = true)
        % self = catObservationNames(self, newDataSet)
        function self = catObservationNames(self,newDataSet)
            % dsOut = catObservationNames(self,varargin)
            if isempty(newDataSet.observationNamesInternal)
                return;
            end
            for i = 1:newDataSet.nObservations;
                currObsName = newDataSet.observationNamesInternal.get(i);
                if ~isempty(currObsName)
                    self.observationNamesInternal = self.observationNamesInternal.put(i + self.nObservations,currObsName);
                end
            end
        end
        
        %   Note: only call this from within retainObservations
        function self = retainObservationNames(self,varargin)
            % dsOut = retainObservationNames(self,varargin)
            if isempty(self.observationNamesInternal)
                return;
            end
            
            retainIndices = prtDataSetBase.parseIndices(self.nObservations,varargin{:});
            %parse returns logicals
            if islogical(retainIndices)
                retainIndices = find(retainIndices);
            end
            if isempty(self.observationNamesInternal)
                return;
            else
                %copy the hash with new indices
                newHash = prtUtilIntegerAssociativeArray;
                for retainInd = 1:length(retainIndices);
                    if self.observationNamesInternal.containsKey(retainIndices(retainInd));
                        newHash = newHash.put(retainInd,self.observationNamesInternal.get(retainIndices(retainInd)));
                    end
                end
                self.observationNamesInternal = newHash;
            end
        end
        
        %self = catTargetNames(self,newDataSet)
        function self = catTargetNames(self,newDataSet)
            % dsOut = catTargetNames(self,varargin)
            for i = 1:newDataSet.nTargetDimensions;
                currTargetName = newDataSet.targetNamesInternal.get(i);
                if ~isempty(currTargetName)
                    self.targetNamesInternal = self.targetNamesInternal.put(i + self.nTargetDimensions,currTargetName);
                end
            end
        end
        
        % Only call from retain tartets
        function self = retainTargetNames(self,varargin)
            % dsOut = retainTargetNames(self,varargin)
            
            retainIndices = prtDataSetBase.parseIndices(self.nTargetDimensions,varargin{:});
            %parse returns logicals
            if islogical(retainIndices)
                retainIndices = find(retainIndices);
            end
            if isempty(self.targetNamesInternal)
                return;
            else
                %copy the hash with new indices
                newHash = prtUtilIntegerAssociativeArray;
                for retainInd = 1:length(retainIndices);
                    if self.targetNamesInternal.containsKey(retainIndices(retainInd));
                        newHash = newHash.put(retainInd,self.targetNamesInternal.get(retainIndices(retainInd)));
                    end
                end
                self.targetNamesInternal = newHash;
            end
        end
        
        function self = catObservationInfo(self,varargin)
            
            for argin = 1:length(varargin)
                currInput = varargin{argin};
                if ~isa(currInput,'prtDataSetBase')
                    %do nothing; nothing to cat.
                else
                    self = catObservationNames(self,currInput);
                    if isempty(self.observationInfo) && isempty(currInput.observationInfo)
                        %do nothing
                    elseif isempty(self.observationInfo) && ~isempty(currInput.observationInfo)
                        self.observationInfo = repmat(struct,self.nObservations,1);
                        self.observationInfoInternal = prtUtilStructVCatMergeFields(self.observationInfo,currInput.observationInfo(:));
                    elseif ~isempty(self.observationInfo) && isempty(currInput.observationInfo)
                        currInput.observationInfo = repmat(struct,currInput.nObservations,1);
                        self.observationInfoInternal = prtUtilStructVCatMergeFields(self.observationInfo(:),currInput.observationInfo);
                    else
                        self.observationInfoInternal = prtUtilStructVCatMergeFields(self.observationInfo(:),currInput.observationInfo(:));
                    end
                end
            end
            
        end
        
        function self = retainObservationInfo(self,indices)
            
            if self.hasObservationNames
                %self.observationNames = self.observationNames(indices);
                self = self.retainObservationNames(indices);
            end
            if ~isempty(self.observationInfo)
                self.observationInfoInternal = self.observationInfoInternal(indices);
            end
            
        end
        
    end
    
    methods (Hidden = true)
        function self = acquireNonDataAttributesFrom(self, dataSet)
            if ~isempty(dataSet.targets) && isempty(self.targets)
                self.targets = dataSet.targets;
            end
            
            if ~isempty(dataSet.observationInfo) && isempty(self.observationInfo)
                self.observationInfo = dataSet.observationInfo;
            end
            
            if ~isempty(dataSet.targetInfo) && isempty(self.targetInfo)
                self.targetInfo = dataSet.targetInfo;
            end
            
            if dataSet.hasObservationNames && ~self.hasObservationNames
                self = self.setObservationNames(dataSet.getObservationNames);
            end
            
            if dataSet.hasTargetNames && ~self.hasTargetNames
                self = self.setTargetNames(dataSet.getTargetNames);
            end
            
            self.name = dataSet.name;
            self.description = dataSet.description;
            self.userData = dataSet.userData;
        end
        
        function has = hasObservationNames(self)
            has = ~isempty(self.observationNamesInternal);
        end
        function has = hasTargetNames(self)
            has = ~isempty(self.targetNamesInternal);
        end
    end
    
    %Private static functions for checking sizes of data and targets
    methods (Access = 'protected', Static)
        function checkConsistency(data,targets)
            if ~(isempty(data) || isempty(targets)) && size(data,1) ~= size(targets,1)
                error('prt:DataTargetsSizeMisMatch','Neither targets nor data is empty, and the number of observations in data (%d) does not match the number of observations in targets (%d)',size(data,1),size(targets,1));
            end
        end
    end
end
