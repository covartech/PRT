classdef prtDataSetBase
    % prtDataSetBase    Base class for all prt data sets.
    %
    % This is an abstract class from which all prt data sets inherit from.
    % It can not be instantiated. It contains the following properties:
    %
    %   name            - Data set descriptive name
    %   description     - Description of the data set
    %   userData        - Structure for holding additional related to the
    %                     data set
    %
    %   observationInfo - Structure array holding additional
    %                     data per related to each observation
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


    
    properties (Dependent)
        nObservations         % The number of observations
        nTargetDimensions     % The number of target dimensions
        isLabeled             % Whether or not the data has target labels
    end
    
    properties (Dependent, Hidden)
        X
        Y
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
    
    properties
        name = ''             % A string naming the data set
        description = ''      % A string with a verbose description of the data set
        userData = struct;    % Additional data per data set
    end
    
    properties (Hidden, Access = protected)
        version = 3;
    end
    
    % Only prtDataSetBase knows about these, use getObs... and getFeat.. to
    % get and set these, they handle the dirty stuff
    properties (GetAccess = 'protected',SetAccess = 'protected')
        observationNamesInternal    % The observations names
        observationInfoInternal
        
        targetNamesInternal         % The target names.
    end
    
    methods
        function self = set.observationInfo(self,val)
            self = self.setObservationInfo(val);
        end
        
        function val = get.observationInfo(self)
            val = self.observationInfoInternal;
        end
        function X = get.X(self)
            X = self.getX();
        end
        function self = set.X(self,val)
            self = self.setX(val);
        end
        function Y = get.Y(self)
            Y = self.getY();
        end
        function self = set.Y(self,val)
            self = self.setY(val);
        end
    end
    
    methods (Abstract)
        
        n = getNumObservations(self)
        nTargets = getNumTargetDimensions(self)
        data = getData(self,indices)
        targets = getTargets(self,indices)
        
        self = retainObservationData(self,indices)
        self = catObservationData(self,varargin)
    end
    
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
        
        function nObs = get.nObservations(self)
            nObs = self.getNumObservations;
        end
        
        function nTargets = get.nTargetDimensions(self)
            nTargets = self.getNumTargetDimensions;
        end
        
        function isLabeled = get.isLabeled(self)
            isLabeled = ~isempty(self.getTargets);
        end
    end
    
    %Wrappers - getX, setX, getY, setY
    methods
        function [observations,targets] = getXY(self,varargin)
            % getXY  Shortcut for getObservationsAndTargets
            observations = self.getObservations(varargin{:});
            targets = self.getTargets(varargin{:});
        end
        function observations = getX(self,varargin)
            % getX Shortcut for GetObservations
            observations = self.getObservations(varargin{:});
        end
        function targets = getY(self,varargin)
            % getY Shortcut for getTargets
            targets = self.getTargets(varargin{:});
        end
        function self = setXY(self,varargin)
            % setXY Shortcut for setObservationsAndTargets
            self = self.setObservationsAndTargets(varargin{:});
        end
        function self = setX(self,varargin)
            % setX Shortcut for setObservations
            self = self.setObservations(varargin{:});
        end
        function self = setY(self,varargin)
            % setY Shortcut for setTargets
            self = self.setTargets(varargin{:});
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
            if length(val) ~= self.nObservations && self.nObservations ~= 0
                error('observationInfo is length %d; should be a structure array of length %d',length(val),self.nObservations);
            end
            self.observationInfoInternal = val;
        end
        
    end
    
    methods 
        function x = getObservations(self,varargin)
            x = self.getData(varargin{:});
        end
    end
    
    %Methods for setting name, description
    methods
        function self = set.name(self, newName)
            if ~isa(newName,'char');
                error('prt:prtDataSetBase:dataSetNameNonString','name must but name must be a character array');
            end
            self.name = newName;
        end
        function self = set.description(self, newDescr)
            if ~isa(newDescr,'char');
                error('prt:prtDataSetBase:dataSetNameNonString','description must be a character array');
            end
            self.description = newDescr;
        end
    end
    
    %Methods for get, set, ObservationNames and FeatureNames
    methods
        
        function self = prtDataSetBase
            self.observationNamesInternal = prtUtilIntegerAssociativeArray;
            self.targetNamesInternal = prtUtilIntegerAssociativeArray;
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
                    obsNames(i) = prtDataSetBase.generateDefaultObservationNames(indices1(i));
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
                    targetNames(i) = prtDataSetBase.generateDefaultTargetNames(indices2(i));
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
   
    
    methods (Access = 'protected', Hidden = true)
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
        
    end
    
    methods
        function keys = getKFoldKeys(DataSet,K)
            % keys = getKFoldKeys(dataSet,K)
            %   Return a vector of integers specifying fold indices.  THis
            %   is used in prtAction.kfolds, for example.
            %
            if DataSet.isLabeled
                keys = prtUtilEquallySubDivideData(DataSet.getTargets(),K);
            else
                %can cross-val on unlabeled data, too!
                keys = prtUtilEquallySubDivideData(ones(DataSet.nObservations,1),K);
            end
        end  
        
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
        
        function [self, sampleIndices] = bootstrap(self,nSamples,p)
            % dsBoot = bootstrap(dataSet,nSamples)
            %   Bootstrap (sample with replacement) nSamples from the data
            %   set dataSet, and return the new data in dsBoot.
            %
            % [dsBoot,indices] = bootstrap(dataSet,nSamples) also returns
            % the indices of the extracted data points in dataSet.
            %
            % [...] = bootstrap(dataSet,nSamples,p) sample from a
            % non-uniform distribution specified by the nObservations x 1
            % vector p.  p should "approximately" sum to 1, e.g.
            %    prtUtilApproxEqual(sum(p),1,eps(self.nObservations))
            % Should return "true"
            %
            % 
            
            if nargin < 3
                p = ones(self.nObservations,1)./self.nObservations;
            end
            
            assert(isvector(p) & all(p) <= 1 & all(p) >= 0 & prtUtilApproxEqual(sum(p),1,eps(self.nObservations)) & length(p) == self.nObservations,'prt:prtDataSetStandard:bootstrap','invalid input probability distribution; distribution must be a vector of size self.nObservations x 1, and must sum to 1')
            
            if self.nObservations == 0
                error('prtDataSetStandard:BootstrapEmpty','Cannot bootstrap empty data set');
            end
            
            if nargin < 2 || isempty(nSamples)
                nSamples = self.nObservations;
            end
            
            % We could do this
            % >>rv = prtRvMultinomial('probabilities',p(:));
            % >>sampleIndices = rv.drawIntegers(nSamples);
            % but there is overhead associated with RV self creation.
            % For some actions, TreebaggingCap for example, we need to
            % rapidly bootstrap so we do not use the self
            sampleIndices = prtRvUtilRandomSample(p,nSamples);
            
            self = self.retainObservations(sampleIndices);
        end
        
        function self = removeObservations(self,indices)
            % dsOut = removeObservations(dataSet,indices)
            %   Return a data set, dsOut, created by removing the
            %   observations specified by indices from the input dataSet.
            %
            
            if islogical(indices)
                indices = ~indices;
            else
                indices = setdiff(1:self.getNumObservations,indices);
            end
            self = self.retainObservations(indices);
        end
        
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
            
            self = self.catObservationInfo(varargin{:});
            self = self.catObservationData(varargin{:});
            self = self.update;
        end
    end
    
    methods (Access = protected)
        function self = retainObservationInfo(self,indices)
            
            if self.hasObservationNames
                %self.observationNames = self.observationNames(indices);
                self = self.retainObservationNames(indices);
            end
            if ~isempty(self.observationInfo)
                self.observationInfoInternal = self.observationInfoInternal(indices);
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
    end
    
    methods (Access = protected)
        function self = update(self)
            %default behaviour is to do nothing
        end
        function self = updateObservationsCache(self)
            %default behaviour is to do nothing
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
        
		function self = modifyNonDataAttributesFrom(self, action) %#ok<INUSD>
			% Modify the non-data attributes of dataset self given an
			% aciton.
			%
			% This allows actions to set feature names for
			% prtDataSetStandard. This can be overloaded (as in
			% prtDataSetStandard) to modify other properties for patricular
			% action classes.
			
			% Here we do nothing.
		end
		
		function dsFoldOut = crossValidateCheckFoldResults(dsIn, dsTrain, dsTest, dsFoldOut) %#ok<INUSL>
			% dsTest = crossValidateCheckFoldResults(dsIn, dsTrain, dsTest, dsFoldOut) %#ok<MANU,INUSL>
			%
			% Cheack the folds and the out used during crossvalidation
			
			if dsFoldOut.nObservations ~= dsTest.nObservations
				error('prt:prtDataSetBase:crossValidateCheckFoldResults','Cross-validation returned a dataset with a different number of observations than the test dataset.')
			end
		end
		
		function dsOut = crossValidateCombineFoldResults(dsTestCell_first, dsTestCell, testIndices) %#ok<MANU>
			% dsOut = crossValidateCombineFoldResults(dsTestCell_first, dsTestCell, testIndices)
			%
			% Combine the results of crossVal folds into one output dataset
			
			% Combine all of the folds via catObservations
			dsOut = catObservations(dsTestCell{:});
			
			% Resort to the original order using retainObservations
			[sortedTestIndices, unsortingInds] = sort(cat(1,testIndices{:}),'ascend');
			dsOut = dsOut.retainObservations(unsortingInds(:));
		end
		
        function has = hasObservationNames(self)
            has = ~isempty(self.observationNamesInternal);
        end
        function has = hasTargetNames(self)
            has = ~isempty(self.targetNamesInternal);
        end
        
    end
end
