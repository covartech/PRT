classdef prtDataInterfaceCategoricalTargets < prtDataInterfaceTargets
    
    properties (Access = private)
        classNamesArray = prtUtilIntegerAssociativeArrayClassNames;
        internalUniqueClasses = [];
        
        targetCache = struct('uniqueClasses',[],'hist',[],'nClasses',1,'hasNans',false,'nNans',0);
    end
    
    
    properties (Dependent)
        nClasses
        uniqueClasses
        nObservationsByClass   % histogram of samples x class
        classNames
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
        isZeroOne              % True if the uniqueClasses are 0 and 1
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
    
    methods
        function cn = get.classNames(self)
            cn = self.getClassNames;
        end
        function self = set.classNames(self,in)
            self = self.setClassNames(in);
        end
    end
    
    
    methods (Hidden)
        %this is used by some class objects, but breaks encapsulation. Hide
        %it from 99% of users
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
            self.targetCache.hist = histc(targets,self.uniqueClasses);
            self.targetCache.nClasses = length(self.targetCache.uniqueClasses);
            self.targetCache.hasNans = any(isnan(self.targetCache.uniqueClasses));
            if self.targetCache.hasNans
                self.targetCache.nNans = sum(isnan(targets));
            else
                self.targetCache.nNans = 0;
            end
        end
    end
    
    methods
        
        function d = getDataUnlabeled(obj,varargin)
            if ~obj.isLabeled
                d = obj.getData(:,varargin{:});
            else
                d = obj.getData(isnan(obj.getTargets(:)),varargin{:});
            end
        end
        
        
        function d = getDataByClass(obj, class, varargin)
            % getDataByClass  Return the Data by class
            %
            
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
        
        %Note, things like this break encapsulation; this should actually
        %be implemented in prtDataSetClass because it allows
        %featureIndices.  That or we need to enforce "getNumColumns" as a
        %default for getNumFeatures for everything that's inMem
        function d = getDataByClassInd(obj, classInd, varargin)
            
            if ~obj.isLabeled
                varargin = {':',varargin{1}};
                if classInd == 1
                    d = obj.getData(varargin{:});
                else
                    error('prt:prtDataSetClass:getDataByClassInd','This dataSet is unlabeled and therefore contains only one class.');
                end
            else
                assert(classInd <= obj.nClasses & classInd > 0,'prt:prtDataSetClass:getDataByClassInd','This requested class index (%d) exceeds the number of classes in this dataSet (%d).',classInd,obj.nClasses);
                d = obj.getData(obj.getTargets == obj.uniqueClasses(classInd),varargin{:});
            end
        end
         
        
        function ut = getUniqueClasses(self)
            if isempty(self.targetCache.uniqueClasses)
                ut = unique(self.targets);
            else
                ut = self.targetCache.uniqueClasses;
            end
        end
        
        function nClasses = numClasses(self)
            nClasses = length(self.uniqueClasses);
        end
        
        function self = setClassNames(self,varargin)
            %ds = ds.setClassNames({'fasdf','asdf','asdfdsfdsf'});
            %ds = ds.setClassNames({{1,'fasdf'},{2,'fasdc'}})
            cellIn = varargin{1};
            
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
            
            trueClass = self.uniqueClasses(indices);
            cn = self.classNamesArray.get(trueClass);
            % Slow:
            %             cn = cell(length(indices),1);
            %             for i = 1:length(indices)
            %                 trueClass = self.uniqueClasses(indices(i));
            %                 cn{i} = self.classNamesArray.get(trueClass);
            %             end
        end
        
        function cn = getClassNames(self,indices)
            %cn = getClassNames(self,indices)
            
            if nargin == 1
                indices = self.uniqueClasses;
            end
            
            cn = self.classNamesArray.get(indices);
            % Slow:
            %             cn = cell(length(indices),1);
            %             for i = 1:length(indices)
            %                 cn{i} = self.classNamesArray.get(indices(i));
            %             end
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
            
            for argin = 1:length(varargin)
                if isa(varargin{argin},'prtDataSetBase') && varargin{argin}.isLabeled
                    %self = mergeClassDefinitions(self,varargin{argin});
                    try
                        self.classNamesArray = merge(self.classNamesArray,varargin{argin}.classNamesArray);
                    catch ME
                        error('prt:catClasses','Attempted to combine class descriptions with incompatible names');
                    end
                end
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
            %
            
            
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
        
        function obj = retainClasses(obj,classes)
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
            
            obj = retainClassesByInd(obj,classInds);
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
        
        function obj = retainClassesByInd(obj,classInds)
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
            
            allClassInds = 1:obj.nClasses;
            classInds = classInds(~isnan(classInds));
            classInds = allClassInds(classInds);
            
            obj = obj.retainObservations(ismember(obj.getTargetsClassInd,classInds));
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
            
            obj = obj.retainClassesByInd(classInds);
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
        end
        
        
        function d = getObservationsUnlabeled(obj,varargin)
            %             warning('use getDataUnlabeled');
            d = getDataUnlabeled(obj,varargin{:});
        end
            
        function d = getObservationsByClass(obj,varargin)
            %             warning('use getDataByClass');
            d = getDataByClass(obj, varargin{:});
        end
        
        function d = getObservationsByClassInd(obj,varargin)
            %             warning('use getDataByClassInd');
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
end