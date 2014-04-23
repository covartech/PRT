classdef prtDataInterfaceCategoricalTargets
    % prtDataInterfaceCategoricalTargets
    %  Super class for data sets with discrete number of possible labels.
    %
    %  Handles all logic involving classn names, class indices, etc.,
    %
    %  Also enables use of NAN as unlabeled data; use
    %     hasUnlabeled
    %     retainUnlabeled
    %     removeUnlabeled
    %     retainLabeled(obj)
    %     removeLabeled(obj)
    %
    %  to handle unlabeled observations.
    %
    %  Note: NAN labels do not count towards the nClasses and will
    %  not appear in uniqueClasses.  It is not possible to set the name of
    %  the class corresponding to NAN.
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


    properties (Hidden)
        classNamesArray = prtUtilIntegerAssociativeArrayClassNames;
        internalUniqueClasses = [];
        
        targetCache = struct('uniqueClasses',[],'hist',[],'nClasses',1,'hasNans',false,'nNans',0);
    end
    
    
    properties (Dependent)
        nClasses
        uniqueClasses
        nObservationsByClass   % histogram of samples x class
        classNames = {};
    end
    
    methods (Abstract)
        %prtDataInterfaceCategoricalTargets needs these in order to be able
        %to do getDataByClass, removeClasses, retainClasses, and bootstrapByClass
        targets = getTargets(object,indices)
        object = retainObservations(object,indices)
    end
    
    properties (Dependent, SetAccess = 'protected')
        isUnary                % True if the number of classes = 1
        isBinary               % True if the number of classes = 2
        isMary                 % True if the number of classes > 2
        isZeroOne              % True if the uniqueClasses are 0 and
        hasUnlabeled           % True if any of the labels are nan
        nUnlabeled
        isFullyUnlabeled
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
        function hasUnlab = get.hasUnlabeled(obj)
            hasUnlab = obj.targetCache.hasNans;
        end
        function val = get.isFullyUnlabeled(obj)
            val = (obj.nObservations > 0) & (obj.nObservations == obj.nUnlabeled);
        end
        function val = get.nUnlabeled(obj)
            val = obj.targetCache.nNans;
        end
        
        function isBin = get.isBinary(obj)
            isBin = obj.nClasses == 2;
        end
        function isUnary = get.isUnary(obj)
            isUnary = obj.nClasses == 1;
        end
        function isMary = get.isMary(obj)
            isMary = obj.nClasses > 2;
        end
        function isZO = get.isZeroOne(obj)
            isZO = isequal(obj.uniqueClasses,[0 1]');
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
        function self = updateTargetCache(self)
            targets = double(self.getTargets);
            if isempty(targets)
                self.targetCache.uniqueClasses = [];
                self.targetCache.hist = [];
                self.targetCache.nClasses = [];
                self.targetCache.hasNans = false;
                self.targetCache.nNans = 0;
                return
            end
            
            self.targetCache.uniqueClasses = unique(targets);
            self.targetCache.uniqueClasses = self.targetCache.uniqueClasses(~isnan(self.targetCache.uniqueClasses));
            self.targetCache.hist = histc(targets,self.uniqueClasses);
            self.targetCache.nClasses = length(self.targetCache.uniqueClasses);
            self.targetCache.hasNans = any(isnan(unique(targets)));
            
            if self.targetCache.hasNans
                self.targetCache.nNans = sum(isnan(targets));
            else
                self.targetCache.nNans = 0;
            end
        end
        
        function dsFoldOut = crossValidateCheckFoldResultsWarnNumberOfClassesBad(dsIn, dsTrain, dsTest, dsFoldOut) %#ok<INUSL>
            if dsTrain.nClasses ~= dsIn.nClasses
                warning('prt:prtAction:crossValidateNClasses','A cross validation fold yielded a training data set with %d class(es) but the input data set contains %d classes. This may result in errors. It may be possible to resolve this by modifying the cross-validation keys.', dsTrain.nClasses, dsIn.nClasses);
            end
        end
    end
    
    methods
        
        function [d, isNans] = getDataUnlabeled(obj,varargin)
            if ~obj.isLabeled
                d = obj.getData(:,varargin{:});
                if nargout > 1
                    isNans = true(size(d,1),1);
                end
            else
                isNans = isnan(obj.getTargets(:));
                d = obj.getData(isNans,varargin{:});
            end
        end
        
        function d = getDataByClass(obj, class, varargin)
            % getDataByClass  Return the Data by class
            
            if isnan(class)
                utInd = find(isnan(obj.uniqueClasses));
            else
                utInd = find(obj.uniqueClasses == class,1);
            end
            if isempty(utInd)
                d = [];
                return
            end
            d = getDataByClassInd(obj, utInd, varargin{:});
        end
        
        function [d,isThisClass] = getDataByClassInd(obj, classInd, varargin)
            
            if ~obj.isLabeled
                varargin = {':',varargin{1}};
                if classInd == 1
                    d = obj.getData(varargin{:});
                    if nargin > 1
                        isThisClass = true(size(d,1),1);
                    end
                else
                    error('prt:prtDataSetClass:getDataByClassInd','This dataSet is unlabeled and therefore contains only one class.');
                end
            else
                assert(classInd <= obj.nClasses & classInd > 0,'prt:prtDataSetClass:getDataByClassInd','This requested class index (%d) exceeds the number of classes in this dataSet (%d).',classInd,obj.nClasses);
                isThisClass = obj.getTargets == obj.uniqueClasses(classInd);
                d = obj.getData(isThisClass,varargin{:});
            end
        end
        
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
            n = self.numClasses;
        end
        
        function u = get.uniqueClasses(self)
            u = self.getUniqueClasses;
        end
        
        function cn = getClassNamesByClassInd(self,indices)
            
            if nargin == 1
                indices = 1:length(self.uniqueClasses);
            end
            trueClass(isnan(indices)) = nan;
            trueClass(~isnan(indices)) = self.uniqueClasses(indices(~isnan(indices)));
            cn = self.classNamesArray.get(trueClass);
        end
        
        function cn = getClassNames(self,indices)
            %cn = getClassNames(self,indices)
            
            if nargin == 1
                indices = self.uniqueClasses;
            end
            
            cn = self.classNamesArray.get(indices);
        end
        
        function y = getBinaryTargetsAsZeroOne(obj)
            % getBinaryTargetsAsZeroOne  Return the target vector from a
            % binary prtDataSetClass as a vector of zeros (lower class
            % index) and ones (higher class index).
            %
            bm = obj.getTargetsAsBinaryMatrix;
            y = zeros(size(bm,1),1);
            y(logical(bm(:,1))) = 0;
            y(logical(bm(:,2))) = 1;
        end
        
        function [binaryMatTargets,uniqueTargets] = getTargetsAsBinaryMatrix(obj,varargin)
            % binaryMatTargets  Return the targets as a binary matrix
            %
            % MAT = dataSet.binaryMatTargets() returns the targets as a
            % binary matrix instead of integer class labels. Each row
            % corresponds to one observation. A 1 in the jth column
            % indicates that the observation is a member of the jth class.
            
            uniqueTargets = obj.uniqueClasses;
            binaryMatTargets = zeros(obj.nObservations,obj.nClasses);
            for i = 1:obj.nClasses
                binaryMatTargets(:,i) = obj.getTargets == obj.uniqueClasses(i);
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
        
        function obj = retainUnlabeled(obj)
            obj = obj.retainObservations(isnan(obj.Y));
        end
        function obj = removeUnlabeled(obj)
            obj = obj.removeObservations(isnan(obj.Y));
        end
        
        function [obj,retainInd] = retainLabeled(obj)
            retainInd = ~isnan(obj.Y);
            obj = obj.retainObservations(retainInd);
        end
        function [obj,removed] = removeLabeled(obj)
            removed = ~isnan(obj.Y);
            obj = obj.removeObservations(removed);
        end
        
        function [obj,retain] = retainClasses(obj,classes)
            % retainClasses retain observations corresponding to specified
            % classes
            %
            %   subDataSet = dataSet.retainClasses(classes) returns a
            %   data set subDataSet containing only the observations that
            %   have targets equal to the specied values
            %
            %   classes can be specified as an array of class values,
            %   or as a cell array of strings containing the class names.
            %
            %   ds = prtDataGenIris;
            %   ds12 = ds.retainClasses([1:2]);
            %
            %   ds12_v2 = ds.retainClasses({'Iris-setosa','Iris-versicolor'});
            
            
            if isa(classes,'cell') || isa(classes,'char')
                classInds = obj.classNamesToClassInd(classes);
            else
                assert(isnumeric(classes) && isvector(classes),'classes must be a numeric vector or cell array of strings');
                [isActuallyAClass, classInds] = ismember(classes,obj.uniqueClasses); %#ok<ASGLU>
            end
            
            % I am not sure if we want to enforce this.
            % I don't think we do.
            % assert(all(isActuallyAClass),'all classes to retain must be represented in dataSet')
            
            [obj,retain] = retainClassesByInd(obj,classInds);
        end
        
        function obj = removeClasses(obj,classes)
            % removeClasses remove observations corresponding to
            % specified classes
            %
            %   subDataSet = dataSet.removeClasses(classes) returns a
            %   data set subDataSet containing only the observations that
            %   have DO NOT have targets equal to the specied values
            %
            %   classes can be specified as an array of class values,
            %   or as a cell array of strings containing the class names.
            %
            %   ds = prtDataGenIris;
            %   ds12 = ds.removeClasses(3);
            %
            %   ds12_v2 = ds.removeClasses({'Iris-virginica'});
            
            if isa(classes,'cell') || isa(classes,'char')
                classInds = obj.classNamesToClassInd(classes);
            else
                assert(isnumeric(classes) && isvector(classes),'classes must be a numeric vector or cell array of strings');
                [isActuallyAClass, classInds] = ismember(classes,obj.uniqueClasses); %#ok<ASGLU>
            end
            
            % I am not sure if we want to enforce this.
            % I don't think we do.
            % assert(all(isActuallyAClass),'all classes to retain must be represented in dataSet')
            
            obj = obj.removeClassesByInd(classInds);
        end
        
        function [obj,retain] = retainClassesByInd(obj,classInds)
            % retainClassesByInd retain observations corresponding to
            % specified class indexes
            %
            %   subDataSet = dataSet.retainClassesByInd(classInds) returns
            %   a data set subDataSet containing only the observations that
            %   have targets with values that corresped to the specified
            %   class indexes.
            
            % Allows for logical indexing into classInds
            % Also performance error checking
            %             classInds = prtDataSetBase.parseIndices(obj.nClasses, classInds);
            if ~obj.isLabeled || obj.isFullyUnlabeled
                retain = false(obj.nObservations,1);
            else
                allClassInds = 1:obj.nClasses;
                classInds = classInds(~isnan(classInds));
                classInds = allClassInds(classInds);
                retain = ismember(obj.getTargetsClassInd,classInds);
            end
            obj = obj.retainObservations(retain);
        end
        
        function obj = removeClassesByInd(obj,classInds)
            % removeClasses remove observations corresponding to
            % specified class indexes
            %
            %   subDataSet = dataSet.removeClassesByInd(classInds) returns
            %   a data set subDataSet containing only the observations that
            %   DO NOT have targets with values that corresped to the
            %   specified class indexes.
            
            % Allows for logical indexing into classInds
            % Also performance error checking
            %             classInds = prtDataSetBase.parseIndices(obj.nClasses, classInds);
            
            % Flip logical representation so we can call retainClassesByInd
            if islogical(classInds)
                classInds = ~classInds;
            else
                classInds = setdiff(1:obj.nClasses,classInds);
            end
            
            % We used to call retainClassesByInd here but instead we have
            % to do somethign different because of unlabeled data
            %obj = obj.retainClassesByInd(classInds);
            
            classIndsByObs = obj.getTargetsClassInd;
            retain = ismember(classIndsByObs,classInds) | isnan(obj.targets);
            obj = obj.retainObservations(retain);
            
        end
        
        function classInds = getTargetsClassInd(obj,varargin)
            % getTargetsClassIndex  Return the targets by class index
            %
            %   TARGETS = dataSet.getTargetsClassInd(IDX) returns the
            %   targets TARGETS as indexed IDX
            
            targets = getTargets(obj,varargin{:});
            
            [dontNeed, classInds] = max(bsxfun(@eq,targets,obj.uniqueClasses(:)'),[],2); %#ok<ASGLU>
            
            % The above is about twice as fast as
            % >> [dontNeed, classInds] = ismember(targets,obj.uniqueClasses);
            % but requires storing an nObs by nUniqueTargets matrix
            % it's a logical matrix though so I don't think that matters
            % too much.

            % Must make sure nans do not pass the max index of 1 along
            if obj.hasUnlabeled 
                classInds(isnan(targets)) = nan;
            end
        end
        
        function d = getObservationsUnlabeled(obj,varargin)
            d = getDataUnlabeled(obj,varargin{:});
        end
        
        function d = getObservationsByClass(obj,varargin)
            d = getDataByClass(obj, varargin{:});
        end
        
        function d = getObservationsByClassInd(obj,varargin)
            d = getDataByClassInd(obj, varargin{:});
        end
        
    end
    
    methods
        
        function classHist = get.nObservationsByClass(Obj)
            % nObservationsByClass Return the number of observations per class
            %
            %   N = dataSet.nObservationsByClass() returns a vector
            %   consisting of the number of observations per class.
            
            classHist = Obj.targetCache.hist;
        end
        
        function [Out, newObsInds] = bootstrapByClass(Obj,N)
            
            if nargin < 2 || isempty(N)
                N = Obj.nObservationsByClass;
            end
            nClasses = Obj.nClasses;
            
            if isscalar(N) && isnumeric(N)
                N = N*ones(nClasses,1);
            end
            if ~isvector(N)
                error('N must be a vector, but N is size %s',mat2str(size(N)));
            end
            if (any(N < 0) || any(N ~= round(N)))
                error('All number of samples in N must be non negative integers, N = %s',mat2str(N));
            end
            if length(N) ~= nClasses
                error('Number of samples (N) must be either scalar integer or a vector integer of dataSet.nClasses (%d), N is a %s %s',nClasses,mat2str(size(N)),class(N));
            end
            
            if ~Obj.isLabeled
                % nClasses will return one but we do not need to look at
                % targets; instead rely on good olde bootstrap
                [Out, newObsInds] = bootstrap(Obj,N);
                return
            end
            
            targetInds = Obj.getTargetsClassInd;
            obsInds = (1:Obj.nObservations)';
            newObsInds = nan(sum(N),1);
            classStartingInds = cat(1,1,cumsum(N(:))+1);
            classStartingInds = classStartingInds(1:end-1);
            for iClass = 1:nClasses
                cInds = targetInds==iClass;
                cObsInds = obsInds(cInds);
                
                cNewInds = classStartingInds(iClass)+(1:N(iClass))-1;
                
                % We could do this
                % >>rv = prtRvMultinomial('probabilities',p(:));
                % >>sampleIndices = rv.drawIntegers(nSamples);
                % but there is overhead associated with RV object creation.
                % For some actions, TreebaggingCap for example, we need to
                % rapidly bootstrap so we do not use the object.
                sampleIndices = prtRvUtilRandomSample(Obj.nObservationsByClass(iClass),N(iClass));
                newObsInds(cNewInds) = cObsInds(sampleIndices);
            end
            
            Out = retainObservations(Obj,newObsInds);
        end
        
    end
    methods (Hidden)
        function self = acquireCategoricalTargetsNonDataAttributes(self, dataSet)
            if isa(dataSet,'prtDataInterfaceCategoricalTargets') && dataSet.hasClassNames && ~self.hasClassNames
                % self = self.setClassNames(dataSet.getClassNames);
                % Fix 2013.09.23 - Deep copy of classNamesArray
                self.classNamesArray = dataSet.classNamesArray;
            end
        end
        function has = hasClassNames(self)
            has = ~isempty(self.classNamesArray);
        end
    end
end
