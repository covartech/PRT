classdef prtDataInterfaceCategoricalTargetsBig
    

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


    properties (Hidden)
        classNamesArray = prtUtilIntegerAssociativeArrayClassNames;
        internalUniqueClasses = [];
        
        targetCache = struct('uniqueClasses',[],'hist',[],'nClasses',1,'hasNans',false,'nNans',0);
    end
    
    properties
        targetCacheInitialized = false;
    end
    
    properties (Dependent)
        nClasses
        uniqueClasses
        nObservationsByClass   % histogram of samples x class
        classNames = {};
    end
    
    properties (Dependent, SetAccess = 'protected')
        isUnary                % True if the number of classes = 1
        isBinary               % True if the number of classes = 2
        isMary                 % True if the number of classes > 2
        isZeroOne              % True if the uniqueClasses are 0 and
        hasUnlabeled           % True if any of the labels are nan
    end
    
    properties (Hidden)
        plotInterpStringFunction = @(s) strrep(s,'_','\_'); %by default, escape underscores
    end
    
    methods
        function Summary = summarize(self,Summary)
            if nargin == 1
                Summary = struct;
            end
            Summary.uniqueClasses = self.uniqueClasses;
            Summary.nClasses = self.nClasses;
            Summary.isMary = self.isMary;
        end
    end
    
    methods
        function hasUnlab = get.hasUnlabeled(self)
            if ~self.targetCacheInitialized
                hasUnlab = nan;
                return;
            end
            hasUnlab = self.targetCache.hasNans;
        end
        
        function isBin = get.isBinary(self)
            if ~self.targetCacheInitialized
                isBin = nan;
                return;
            end
            isBin = self.nClasses == 2;
        end
        function isUnary = get.isUnary(self)
            if ~self.targetCacheInitialized
                isUnary = nan;
                return;
            end
            isUnary = self.nClasses == 1;
        end
        function isMary = get.isMary(self)
            if ~self.targetCacheInitialized
                isMary = nan;
                return;
            end
            isMary = self.nClasses > 2;
        end
        function isZO = get.isZeroOne(self)
            if ~self.targetCacheInitialized
                isZO = nan;
                return;
            end
            isZO = isequal(self.uniqueClasses,[0 1]');
        end
    end
    
    methods (Hidden)
        function cn = getClassNamesInterp(self)
            % Get the classnames, but run self.plotInterpStringFunction on
            % them first to make them suitable for MATLAB figure
            % interpretation
            cn = self.getClassNames;
            cn = self.plotInterpStringFunction(cn);
        end
    end
    
    methods
        function cn = get.classNames(self)
            cn = self.getClassNames;
        end
        
        function self = set.classNames(self,in)
            self = self.setClassNames(in);
        end
    end
    
    methods (Hidden)
        function dsFoldOut = crossValidateCheckFoldResultsWarnNumberOfClassesBad(dsIn, dsTrain, dsTest, dsFoldOut) %#ok<INUSL>
            if dsTrain.nClasses ~= dsIn.nClasses
                warning('prt:prtAction:crossValidateNClasses','A cross validation fold yielded a training data set with %d class(es) but the input data set contains %d classes. This may result in errors. It may be possible to resolve this by modifying the cross-validation keys.', dsTrain.nClasses, dsIn.nClasses);
            end
        end
    end
    
    methods
        
        function ut = getUniqueClasses(self)
            ut = self.targetCache.uniqueClasses;
        end
        
        function nClasses = numClasses(self)
            nClasses = length(self.uniqueClasses);
        end
        
        function self = setClassNames(self,varargin)
            %ds = ds.setClassNames({'fasdf','asdf','asdfdsfdsf'});
            %ds = ds.setClassNames({{1,'fasdf'},{2,'fasdc'}})
            cellIn = varargin{1};
            if isa(cellIn,'char')
                cellIn = {cellIn};
            end
            if isa(cellIn{1},'char')
                targets = self.uniqueClasses;
                for i = 1:length(targets)
                    self.classNamesArray = self.classNamesArray.put(targets(i),cellIn{i});
                end
            else
                for i = 1:length(cellIn)
                    self.classNamesArray = self.classNamesArray.put(cellIn{i}{1},cellIn{i}{2});
                end
            end
        end
        
        function n = get.nClasses(self)
            if ~self.targetCacheInitialized
                n = nan;
                return;
            end
            n = self.numClasses;
        end
        
        function u = get.uniqueClasses(self)
            if ~self.targetCacheInitialized
                u = nan;
                return;
            end
            u = self.getUniqueClasses;
        end
        
        function cn = getClassNamesByClassInd(self,indices)
            
            if nargin == 1
                indices = 1:length(self.uniqueClasses);
            end
            
            trueClass = self.uniqueClasses(indices);
            cn = self.classNamesArray.get(trueClass);
        end
        
        function cn = getClassNames(self,indices)
            %cn = getClassNames(self,indices)
            
            if nargin == 1
                indices = self.uniqueClasses;
            end
            
            cn = self.classNamesArray.get(indices);
        end
        
        function y = getBinaryTargetsAsZeroOne(self)
            % getBinaryTargetsAsZeroOne  Return the target vector from a
            % binary prtDataSetClass as a vector of zeros (lower class
            % index) and ones (higher class index).
            %
            bm = self.getTargetsAsBinaryMatrix;
            y = zeros(size(bm,1),1);
            y(logical(bm(:,1))) = 0;
            y(logical(bm(:,2))) = 1;
        end
        
        function [binaryMatTargets,uniqueTargets] = getTargetsAsBinaryMatrix(self,varargin)
            % binaryMatTargets  Return the targets as a binary matrix
            %
            % MAT = dataSet.binaryMatTargets() returns the targets as a
            % binary matrix instead of integer class labels. Each row
            % corresponds to one observation. A 1 in the jth column
            % indicates that the observation is a member of the jth class.
            
            uniqueTargets = self.uniqueClasses;
            binaryMatTargets = zeros(self.nObservations,self.nClasses);
            for i = 1:self.nClasses
                binaryMatTargets(:,i) = self.getTargets == self.uniqueClasses(i);
            end
            
            if nargin == 1
                return
            else
                binaryMatTargets = binaryMatTargets(varargin{:});
            end
            
        end
        
        function self = catClasses(self,varargin)
            %self = catClasses(self,ds1,ds2,...)
            
            %We need to know what indices to start changing, which means we
            %need to know the length of the original data set. but we get
            %the *new* data set.  We need to reverse engineer the length of
            %the original one.
            totalAdd = 0;
            for i = 1:length(varargin)
                totalAdd = totalAdd + varargin{i}.nObservations;
            end
            startObs = self.nObservations-totalAdd+1;
            
            anySwaps = false;
            for argin = 1:length(varargin)
                ds = varargin{argin};
                currentObsInds = startObs:startObs+ds.nObservations-1;
                if isa(ds,'prtDataSetBase') && ds.isLabeled
                    %                     try
                    %                         self.classNamesArray = merge(self.classNamesArray,ds.classNamesArray);
                    %                     catch ME
                    %                         warning('prt:catClasses','Combine class descriptions with incompatible names; output target indices may not match input target indices');
                    %                         [self.classNamesArray,integerSwaps] = combine(self.classNamesArray,ds.classNamesArray);
                    %                         targets = self.targets(currentObsInds);
                    %                         for swapInd = 1:size(integerSwaps,1)
                    %                             targets(targets == integerSwaps(swapInd,1)) = integerSwaps(swapInd,2);
                    %                         end
                    %                         self.targets(currentObsInds) = targets;
                    %                     end
                    [self.classNamesArray,integerSwaps] = combine(self.classNamesArray,ds.classNamesArray);
                    targets = self.targets(currentObsInds);
                    for swapInd = 1:size(integerSwaps,1)
                        anySwaps = true;
                        targets(targets == integerSwaps(swapInd,1)) = integerSwaps(swapInd,2);
                    end
                    self.targets(currentObsInds) = targets;
                end
                if anySwaps
                    warning('prt:catClasses','Tried to combine class descriptions with incompatible names; output target indices may not match input target indices');
                end
                startObs = startObs+ds.nObservations;
            end
        end
        
    end
    
    methods
        
        function classInds = classNamesToClassInd(self,classNames)
            % classInds = classNamesToClassInd(dataSet,classNames)
            %   Return the class indices corresponding to the classes
            %   specified in the character array or cell of strings,
            %   classNames.
            %
            %   Note that the classInd is not necessarily the same as the
            %   target value.
            %
            %  ds = prtDataGenIris;
            %  ds.classNamesToClassInd('Iris-setosa'); %Setosa is the first
            
            
            if isa(classNames,'char')
                classNames = {classNames};
            end
            
            uClasses = self.classNames;
            classInds = nan(length(classNames),1);
            for j = 1:length(classNames)
                currentInd = find(strcmpi(classNames{j},uClasses));
                if ~isempty(currentInd)
                    classInds(j) = currentInd;
                end
            end
        end
        
    end
    
    methods
        
        function classHist = get.nObservationsByClass(self)
            % nObservationsByClass Return the number of observations per class
            %
            %   N = dataSet.nObservationsByClass() returns a vector
            %   consisting of the number of observations per class.
            if ~self.targetCacheInitialized
                classHist = nan;
                return;
            end
            classHist = self.targetCache.hist;
        end
        
    end
    
    methods (Hidden)
        function self = acquireCategoricalTargetsNonDataAttributes(self, dataSet)
            if isa(dataSet,'prtDataInterfaceCategoricalTargets') && dataSet.hasClassNames && ~self.hasClassNames
                self = self.setClassNames(dataSet.getClassNames);
            end
        end
        function has = hasClassNames(self)
            has = ~isempty(self.classNamesArray);
        end
    end
end
