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
    %   nObservations     - Number of observations in the data set
    %   nTargetDimensions - Number of target dimensions
    %   isLabeled         - Whether or not the data set is labeled
    %
    % The prtDataSetBase class has the following methods
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
        isEmpty
    end
    
    properties (Dependent, Hidden)
        X
        Y
    end
    
    properties
        name = ''             % A string naming the data set
        description = ''      % A string with a verbose description of the data set
        userData = struct;    % Additional data per data set
    end
    
    properties (Hidden, Access = protected)
        version = 3;
    end
    
    methods
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
    
    % get. methods that call get* methods
    methods
        function nObs = get.nObservations(self)
            nObs = self.getNumObservations;
        end
        
        function nTargets = get.nTargetDimensions(self)
            nTargets = self.getNumTargetDimensions;
        end
        
        function isLabeled = get.isLabeled(self)
            isLabeled = getIsLabeled(self);
        end
        function val = get.isEmpty(self)
            val = self.nObservations == 0;
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
   
        % Rename of method from getObservations to getData
        function x = getObservations(self,varargin)
            x = self.getData(varargin{:});
        end
        function b = getIsLabeled(self)
            b = ~isempty(self.targets);
        end
    end
    
    %Methods for setting name, description
    methods
        function self = set.name(self, newName)
            if ~isa(newName,'char');
                error('prt:prtDataSetBase:dataSetNameNonString','name must be a character array');
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
    
    methods
        function self = prtDataSetBase
            % Nothing to do
        end
    end
    
    
    %Protected static functions for checking indices arguments
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
   
    
    % Useful methods
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
            
            self = self.retainObservationData(indices);
            self = self.update;
        end
        
        function self = catObservations(self,varargin)
            % dsOut = catObservations(dataSet1,dataSet2)
            %   Return a data set, dsOut, created by concatenating the data
            %   in dataSet1 and dataSet2.  The output data set, dsOut, will
            %   have nObservations = dataSet1.nObservations +
            %   dataSet2.nObservations.
            %
            if nargin == 1 && length(self) > 1
                varargin = num2cell(self(2:end));
                self = self(1);
            end
            
            self = self.catObservationData(varargin{:});
            self = self.update;
        end
    end
    
    methods
        %         function ds1 = plus(ds1,ds2)
        %             % ds1 = ds1 + ds2;
        %             %   ds1 = catObservations(ds1,ds2);
        %
        %             ds1 = ds1.catObservations(ds2);
        %         end
        
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
            if ~isempty(dataSet.name) && isempty(self.name)
                self.name = dataSet.name;
            end
            if ~isempty(dataSet.description) && isempty(self.description)
                self.description = dataSet.description;
            end
            if ~isempty(dataSet.userData) && isempty(self.userData)
                self.userData = dataSet.userData;
            end
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
    end
end
