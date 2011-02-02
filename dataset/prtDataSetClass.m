classdef prtDataSetClass  < prtDataSetStandard
    % prtDataSetClass  Data set object for classification
    %
    %   DATASET = prtDataSetClass returns a prtDataSetClass object
    %
    %   DATASET = prtDataSetClass(PROPERTY1, VALUE1, ...) constructs a
    %   prtDataSetClass object DATASET with properties as specified by
    %   PROPERTY/VALUE pairs.
    %
    %   A prtDataSetClass object inherits all properties from the
    %   prtDataSetStandard class. In addition, it has the following properties:
    %
    %   nClasses             - The number of classes
    %   uniqueClasses        - An array of the integer class labels
    %   isUnary              - True if the number of classes = 1
    %   isBinary             - True if the number of classes = 2
    %   isMary = nan         - True if the number of classes > 2
    %   isZeroOne            - True if the unique classes are 0 and 1
    %   nObservationsByClass - The number of observations per class.
    %
    %   A prtDataSetClass inherits all methods from the prtDataSetStandard
    %   class. In addition, it has the following methods:
    %
    %   getObservationsByClass     - Return the observations per class
    %   getObservationsByClassInd  - Return the observations by class and index
    %   getTargetsAsBinaryMatrix   - Return a binary matrix of targets.
    %   explore                    - Explore the prtDataSetClass object
    %   plot                       - Plot the data set
    %   plotbw                     - Plot the data set in a manner that
    %                                will remain clear in black and white
    %   plotStar                   - Create a star plot to visualize higher
    %                                dimensional data
    %   plotAsTimeSeries           - Plot the prtDataSetClass object as a
    %                                time series
    %   plotPairs                  - Plot a grid of plots containing each
    %                                set of two-features with density
    %                                estimates on the diagonals
    %   plotDensity                - Plot the density of each feature
    %                                independently as a volume
    % 
    %   See also, prtDataSetBase, prtDataSetStandard, prtDataSetRegress,
    %   prtDataSetFile
    
    % Copyright 2011, New Folder Consulting, L.L.C.
    
    properties (Dependent)
        nClasses        % The number of classes
        uniqueClasses   % The unique class
        nObservationsByClass %  The number of observations per class
        
        isUnary                % True if the number of classes = 1
        isBinary               % True if the number of classes = 2
        isMary                 % True if the number of classes > 2
        isZeroOne              % True if the uniqueClasses are 0 and 1
    end
    
    properties (Access = 'private')
        classNames
    end
    
    properties (Hidden=true, Access='private')
        targetsCacheUnique = [];
        targetsCacheHist = []; 
        targetsCacheNClasses = 1;
    end
    
    properties (Hidden = true)
        PlotOptions = prtDataSetClass.initializePlotOptions();
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
        function nUT = get.nClasses(obj)
            nUT = obj.targetsCacheNClasses;
        end
    end
    
    methods (Access = 'private',Static = true, Hidden = true);
        function classNames = generateDefaultClassNames(uY)
            if isa(uY,'cell')
                classNames = uY;
            else
                classNames = prtUtilCellPrintf('H_{%d}',num2cell(uY));
            end
        end
        function classNames = generateDefaultClassNamesNoTex(uY)
            if isa(uY,'cell')
                classNames = uY;
            else
                classNames = prtUtilCellPrintf('H%d',num2cell(uY));
            end
        end
        
        function obj = catClassNames(obj,newDataSet)
            
            newUniqueClasses = newDataSet.uniqueClasses;
            for i = 1:length(newUniqueClasses);
                %if the current data set doesn't have this key, and the
                %other data set does, well, use the other data set's name
                %for this class
                if ~obj.classNames.containsKey(newUniqueClasses(i)) && newDataSet.classNames.containsKey(newUniqueClasses(i));
                    obj.classNames = obj.classNames.put(newUniqueClasses(i),newDataSet.classNames.get(newUniqueClasses(i)));
                    %If both the data sets have the key, and the strings
                    %don't match...
                elseif (obj.classNames.containsKey(newUniqueClasses(i)) && newDataSet.classNames.containsKey(newUniqueClasses(i))) && ...
                        ~strcmpi(newDataSet.classNames.get(newUniqueClasses(i)),obj.classNames.get(newUniqueClasses(i)))
                    warning('prt:prtDataSetClass:IncompatibleClassNames','Incompatible class names encountered; retaining original data sets class names');
                end
            end
        end
    end
    
    methods
        
        function obj = prtDataSetClass(varargin)
            
            obj.classNames = prtUtilIntegerAssociativeArray;
            if nargin == 0
                return;
            end
            if isa(varargin{1},'prtDataSetClass')
                obj = varargin{1};
                varargin = varargin(2:end);
            end
            
            if length(varargin) >= 1 && (isnumeric(varargin{1}) || islogical(varargin{1}))
                obj = obj.setObservations(varargin{1});
                varargin = varargin(2:end);
                
                if length(varargin) >= 1 && ~isa(varargin{1},'char')
                    if (isa(varargin{1},'double') || isa(varargin{1},'logical'))
                        obj = obj.setTargets(varargin{1});
                        varargin = varargin(2:end);
                    else
                        error('prtDataSet:InvalidTargets','Targets must be a double or logical array; but targets provided is a %s',class(varargin{1}));
                    end
                end
            end
            
            %handle public access to observations and targets, via their
            %pseudonyms.  If these were public, this would be simple... but
            %they are not public.
            dataIndex = find(strcmpi(varargin(1:2:end),'observations'));
            targetIndex = find(strcmpi(varargin(1:2:end),'targets'));
            stringIndices = 1:2:length(varargin);
            
            if ~isempty(dataIndex) && ~isempty(targetIndex)
                obj = prtDataSetClass(varargin{stringIndices(dataIndex)+1},varargin{stringIndices(targetIndex)+1});
                newIndex = setdiff(1:length(varargin),[stringIndices(dataIndex),stringIndices(dataIndex)+1,stringIndices(targetIndex),stringIndices(targetIndex)+1]);
                varargin = varargin(newIndex);
            elseif ~isempty(dataIndex)
                obj = prtDataSetClass(varargin{dataIndex+1});
                newIndex = setdiff(1:length(varargin),[stringIndices(dataIndex),stringIndices(dataIndex)+1]);
                varargin = varargin(newIndex);
            elseif ~isempty(targetIndex)
                obj = obj.setTargets(varargin{stringIndices(targetIndex)+1});
                newIndex = setdiff(1:length(varargin),[stringIndices(targetIndex),stringIndices(targetIndex)+1]);
                varargin = varargin(newIndex);
            end
            
            removeInd = [];
            for i = 1:2:length(varargin)
                if strcmpi(varargin{i},'featureNames')
                    obj = obj.setFeatureNames(varargin{i+1});
                    removeInd = cat(2,removeInd,i,i+1);
                elseif strcmpi(varargin{i},'classNames')
                    obj = obj.setClassNames(varargin{i+1});
                    removeInd = cat(2,removeInd,i,i+1);
                elseif strcmpi(varargin{i},'observationNames')
                    obj = obj.setObservationNames(varargin{i+1});
                    removeInd = cat(2,removeInd,i,i+1);
                end
            end
            keepInd = setdiff(1:length(varargin),removeInd);
            varargin = varargin(keepInd);
            
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                    Access methods                               %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function tn = getClassNamesByClassInd(obj,varargin)
            % getClassNamesByClassInd  Return the class names 
            %
            %    NAMES = dataSet.getClassNamesByClassInd(IDX) returns the
            %    class names corresponding to the index IDX.
            
            indices1 = prtDataSetBase.parseIndices(obj.nClasses, varargin{:});
            
            if ~obj.isLabeled
                tn = {'Unlabeled'};
                return
            end
            
            uniqueClasses = obj.uniqueClasses;
            if isa(indices1,'logical')
                indices1 = find(indices1);
            end
            
            tn = cell(length(indices1),1);
            for i = 1:length(indices1)
                if obj.classNames.containsKey(uniqueClasses(indices1(i)))
                    tn{i} = obj.classNames.get(uniqueClasses(indices1(i)));
                else
                    tn(i) = prtDataSetClass.generateDefaultClassNames(uniqueClasses(indices1(i)));
                end
            end
        end
        
        function obj = setTargets(obj,targets,varargin)
            assert(isempty(targets) || size(targets,2) == 1,'prt:prtDataSetClass:setTargets','targets for prtDataSetClass must be size n x 1, but targets are size n x %d',size(targets,2));
            obj = setTargets@prtDataSetStandard(obj,targets,varargin{:});
        end
        function obj = setClassNamesByClassInd(obj,classNames,varargin)
            % setClassNamesByClassInd   Sets the class names
            %
            % dataSet = dataSet.setClassNamesByClassInd(NAMES, IDX) set the
            % class names of dataSet to the strings contained in NAMES at
            % the corresponding indices IDX.
            
            if ~isa(classNames,'cell') || ~isa(classNames{1},'char')
                error('prt:dataSetStandard:setClassNamesByClassInd','Input class names must be a cell array of characters');
            end
            if ~isvector(classNames)
                error('prt:dataSetStandard:setClassNamesByClassInd','setClassNamesByClassInd requires first input to be a n x 1 cell array');
            end
            
            indices1 = prtDataSetBase.parseIndices(obj.nClasses, varargin{:});
            uniqueClasses = obj.uniqueClasses;
            
            for i = 1:length(indices1)
                obj.classNames = obj.classNames.put(uniqueClasses(indices1(i)),classNames{i});
            end
        end
        
        function tn = getClassNames(obj,classes)
            % getClassNames  Returns the class names
            %
            % NAMES = dataSet.getClassNames() returns the class names.
            
            if nargin < 2
                classes = obj.uniqueClasses;
            end
            uniqueClasses = obj.uniqueClasses;
            if ~isempty(setdiff(classes,uniqueClasses))
                error('Input classes array (%s) contains class numbers not in uniqueClasses (%s)',mat2str(classes),mat2str(uniqueClasses));
            end
            [~,~,ib] = intersect(classes,uniqueClasses);
            tn = getClassNamesByClassInd(obj,ib);
        end
        
        function obj = setClassNames(obj,names,classes)
            % setClassNames  Sets the class names
            %
            %   dataSet = dataSet.setClassNames(NAMES) sets the class names
            %   to the strings contained in NAMES. NAMES must be a cell
            %   array of strings that has the same length as the number of
            %   classes in the dataSet object.
            
            if isa(names,'char') && (obj.nClasses == 1)
                names = {names};
            end
            if ~isa(names,'cell') || ~isa(names{1},'char')
                error('prt:dataSetClass:setClassNames','Input class names must be a cell array of characters');
            end
            if ~isvector(names)
                error('prt:dataSetClass:setClassNames','setClassNamesByClassInd requires first input to be a n x 1 cell array');
            end
            names = names(:);
            if nargin < 3
                classes = obj.uniqueClasses;
                if size(names,1) ~= length(classes)
                    error('prt:dataSetClass:setClassNames','setClassNames with one input requires that size(names,1) (%d) equals number of unique classes (%d)',size(names,1),length(classes));
                end
            end
            uniqueClasses = obj.uniqueClasses;
            
            if ~isempty(setdiff(classes,uniqueClasses))
                error('classes contains classes not in uniqueClasses');
            end
            [~,~,ib] = intersect(classes,uniqueClasses);
            
            obj = setClassNamesByClassInd(obj,names,ib);
        end
        
        
        function d = getObservationsByClass(obj, class, featureIndices)
            % getObservationsByClass  Return the observations by class
            %
            %  OBS = dataSet.getObservationsByClass(CLASS) returns the
            %  observations of the dataSet object correspoding to the class
            %  CLASS. CLASS must be an integer index corresponding to one
            %  of the values contained in dataSet.uniqueClasses
            
            if nargin < 3 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            utInd = find(obj.uniqueClasses == class,1);
            if isempty(utInd)
                d = [];
                return
            end
            d = getObservationsByClassInd(obj, utInd, featureIndices);
        end
        
        function uT = get.uniqueClasses(obj)
            % uniqueClasses  Return the unique classes
            %
            % CLASSES = dataSet.uniqueClasses returns the unique classes of
            % a dataSet object.
            uT = obj.targetsCacheUnique;
        end
        
        function obj = catObservations(obj,varargin)
            % catObservations   Concatenate the observations of a prtDataSetClass object
            %
            %   dataSet = dataSet.catObservations(OBS) concatenates the
            %   OBS to the observations of the dataSet object. OBS must
            %   have the same number of features as the dataSet object.
            %   dataSet must be an unlabled prtDataSetClass object.
            
            if isempty(varargin)
                objIn = obj;
                obj = objIn(1);
                varargin = num2cell(objIn(2:end));
            end
            
            for i = 1:length(varargin)
                if isa(varargin{i},'prtDataSetClass')
                    obj = prtDataSetClass.catClassNames(obj,varargin{i});
                end
            end
            obj = catObservations@prtDataSetStandard(obj,varargin{:});
        end
        
        
        function d = getObservationsByClassInd(obj, classInd, featureIndices)
            % getObservationsByClassInd   Return the observations by class index
            %
            %   OBS = dataSet.getObservationsByClassInd(IDX) returns the
            %   observations OBS of the prtDataSetClass object specified by
            %   the index IDX.
            
            if nargin < 3 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            if ~obj.isLabeled
                if classInd == 1
                    d = obj.getObservations(:,featureIndices);
                else
                    error('prt:prtDataSetClass:getObservationsByClassInd','This dataSet is unlabeled and therefore contains only one class.');
                end
            else
                d = obj.getObservations(obj.getTargets == obj.uniqueClasses(classInd),featureIndices);
            end
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
        
        function binaryMatTargets = getTargetsAsBinaryMatrix(obj,indices1,indices2)
            % binaryMatTargets  Return the targets as a binary matrix
            %
            % MAT = dataSet.binaryMatTargets() returns the targets as a
            % binary matrix instead of integer class labels. Each row
            % corresponds to one observation. A 1 in the jth column
            % indicates that the observation is a member of the jth class.
            
            binaryMatTargets = zeros(obj.nObservations,obj.nClasses);
            for i = 1:obj.nClasses
                binaryMatTargets(:,i) = obj.getTargets == obj.uniqueClasses(i);
            end
            
            if nargin == 1
                return
            end
            
            % Else select only some of the matrix
            if nargin < 2 || strcmpi(indices1,':')
                indices1 = 1:obj.nObservations;
            end
            if nargin < 3 || strcmpi(indices2,':')
                indices2 = 1:obj.nClasses;
            end
            
            if max(indices1) > obj.nObservations
                error('prt:prtDataSetBase:incorrectInput','max(indices1) (%d) must be <= nObservations (%d)',max(indices1),obj.nObservations);
            end
            if max(indices2) > obj.nClasses
                error('prt:prtDataSetBase:incorrectInput','max(indices2) (%d) must be <= nClasses (%d)',max(indices1),obj.nClasses);
            end
            
            binaryMatTargets = binaryMatTargets(indices1,indices2);
            
        end
        
        function explore(obj, AdditionalOptions)
            % explore  Explore the prtDataSetObject
            %
            %   dataSet.explore() opens the prtDataSetObject explorer for
            %   visualizing high dimensional data sets.
            
            if nargin < 2
                AdditionalOptions = [];
            end
            
            try
                prtPlotUtilDataSetExploreGuiWithNavigation(obj,AdditionalOptions);
            catch %#ok<CTCH>
                error('prt:prtDataSetClassExplore','An unexpected error was encountered with explore(). If this error persists you may want to try using exploreSimple().')
            end
        end
        function exploreSimple(obj)
            % exploreSimple Explore the prtDataSetObject using basic
            % controls
            %
            %   dataSet.exploreSimple() opens the prtDataSetObject
            %   explorer for visualizing high dimensional data sets.
            prtPlotUtilDataSetExploreGuiSimple(obj)
        end
        
        
        function varargout = plotAsTimeSeries(obj,featureIndices,xData)
            % plotAsTimeSeries  Plot the data set as time series data
            %
            % dataSet.plotAsTimeSeries() plots the data contained in
            % dataSet as if it were a time series.
            
            if ~obj.isLabeled
                obj = obj.setTargets(zeros(obj.nObservations,1));
                obj = obj.setClassNames({'Unlabeled'});
            end
            
            if nargin < 2 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            
            nClasses = obj.nClasses;
            classColors = obj.PlotOptions.colorsFunction(obj.nClasses);
            lineWidth = obj.PlotOptions.symbolLineWidth;
            
            handleArray = zeros(nClasses,1);
            
            holdState = get(gca,'nextPlot');
            
            % Loop through classes and plot
            for i = 1:nClasses
                %Use "i" here because it's by uniquetargetIND
                cX = obj.getObservationsByClassInd(i, featureIndices);
                
                if nargin < 3
                    xInd = 1:size(cX,2);
                else
                    xInd = xData;
                end
                
                h = prtPlotUtilLinePlot(xInd,cX,classColors(i,:),lineWidth);
                handleArray(i) = h(1);
                if i == 1
                    hold on;
                end
            end
            set(gca,'nextPlot',holdState);
            % Set title
            title(obj.name);
            
            % Create legend
            if obj.isLabeled
                legendStrings = getClassNames(obj);
                legend(handleArray,legendStrings,'Location','SouthEast');
            end
            
            
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {handleArray,legendStrings};
            end
        end
        
        function varargout = plotDensity(ds,varargin)
            % Plot the density of each feature independently as a volume.
            %
            % plotDensity(ds)
            % patchHandles = plotDensity(ds);
            %
            % plotDensity(ds,'PARMNAME',PARAMVALUE)
            %   Additional parameters:
            %       nDensitySamples        - Number of linearly spaced 
            %                                samples used to construct the 
            %                                density estimate. Default 500.
            %       faceAlpha              - Face alpha value of the patch
            %                                for each density. Must be a
            %                                value between 0 and 1. Default
            %                                0.7.
            %       minimumKernelBandwidth - minimumBandwidth parameter of 
            %                                prtRvKde that is used to
            %                                estimate each density. default
            %                                eps.
            %
            % Example:
            %    ds = prtDataGenMary;
            %    plotDensity(ds)
            %
            %    ds = prtDataGenIris;
            %    plotDensity(ds,'minimumKernelBandwidth',5e-3);
            % 
            Options.nDensitySamples = 500;
            Options.faceAlpha = 0.7;
            Options.minimumKernelBandwidth = eps;
            
            if nargin > 1
                assert(mod(length(varargin),2)==0,'Additional inputs must be string value pairs')
                
                paramNames = varargin(1:2:end);
                paramValues = varargin(2:2:end);
                
                optionFieldNames = fieldnames(Options);
                for iPair = 1:length(paramNames)
                    assert(ismember(paramNames{iPair},optionFieldNames),'%s is not a valid parameter name for plotDensity() (These parameters are case sensitive.)',paramNames{iPair});
                    Options.(paramNames{iPair}) = paramValues{iPair};
                end
            end
            
            Summary = ds.summarize();
            nClasses = Summary.nClasses;
            if isempty(nClasses)
                nClasses = 1;
            end
            
            patchH = zeros(Summary.nFeatures,nClasses);
            colors = prtPlotUtilClassColors(nClasses);
            holdState = get(gca,'NextPlot');
            
            if strcmpi(get(gcf,'NextPlot'),'New')
                figure
            end
            
            if strcmp(holdState,'replace')
                cla; % Clear axes since patch doesn't automatically
            end
            
            for iFeature = 1:Summary.nFeatures
                low = Summary.lowerBounds(iFeature);
                high = Summary.upperBounds(iFeature);
                
                range = high-low;
                low = low - range/10;
                high = high + range/10;
                
                xLoc = linspace(low, high, Options.nDensitySamples);
                xLoc = sort(cat(1,xLoc(:),ds.getObservations(:,iFeature)),'ascend');
                
                F = zeros([length(xLoc), nClasses]);
                for cY = 1:nClasses
                    F(:,cY) = pdf(mle(prtRvKde('minimumBandwidth',Options.minimumKernelBandwidth),ds.getObservationsByClassInd(cY,iFeature)),xLoc(:));
                end
                
                F = F./max(F(:))/2;
                xLoc = (xLoc-mean(xLoc))./std(xLoc);
                
                for cY = 1:nClasses
                    cPatch = cat(2,cat(1,-F(:,cY),flipud(F(:,cY))), cat(1,xLoc, flipud(xLoc)));
                    patchH(cY) = patch(cPatch(:,1)+iFeature, cPatch(:,2), colors(cY,:),'edgecolor','none');
                end
            end
            
            set(patchH,'FaceAlpha',Options.faceAlpha);
            
            set(gca,'NextPlot',holdState,'YTick',[]);
            
            xlabel('Feature');
            ylabel('Normalized Feature Value');
            
            % Create legend
            if ds.isLabeled
                legendStrings = getClassNames(ds);
                legend(patchH(1,:),legendStrings,'Location','SouthEast');
            end
            
            if Summary.nFeatures < 10
                set(gca,'XTick',1:Summary.nFeatures,'XTickLabel',ds.getFeatureNames());
            end
            
            if nargout
                varargout = {patchH};
            end
            
        end
        function varargout = plotFeatureDensity(obj,featureInd)
            % plotFeatureDensity - Plot the densities of a single feature
            % as a function of class. With one input the supplied dataset
            % must have only a single feature. Otherwise, the second input
            % specifies which feature to plot.
            %
            % plotHandles = plotFeatureDensity(prtDataSetClassObj)
            % plotHandles = plotFeatureDensity(prtDataSetClassObj, featureInd)
            
            if nargin > 1 && featureInd
                assert(prtUtilIsPositiveScalarInteger(featureInd) && featureInd <= obj.nFeatures,'prt:prtDataSetClass:plotFeatureDensity','featureInd must be a scalar, positive integer less than prtDataSetClass.nFeatures')
                obj = obj.retainFeatures(featureInd);
            end
            
            assert(obj.nFeatures==1,'prt:prtDataSetClass:plotFeatureDensity','prtDataSetClass must have only one feature');
            
            nKSDsamples = 500;
            
            Summary = obj.summarize();
            nClasses = obj.nClasses;
            colors = obj.PlotOptions.colorsFunction(nClasses);
            
            xLoc = linspace(Summary.lowerBounds, Summary.upperBounds, nKSDsamples);
                        
            F = zeros([nKSDsamples, nClasses]);
            for cY = 1:nClasses;
                F(:,cY) = pdf(mle(prtRvKde,obj.getObservationsByClassInd(cY)),xLoc(:));
            end
                        
            hs = plot(xLoc,F);
            for iLine = 1:length(hs)
                set(hs(iLine),'color',colors(iLine,:));
            end
            xlim([Summary.lowerBounds, Summary.upperBounds]);
            
            grid on;
            xlabel(obj.getFeatureNames{1});
            
            % Create legend
            if obj.isLabeled
                legendStrings = getClassNames(obj);
                legend(hs,legendStrings,'Location','NorthEast');
            end
            
            if nargout
                varargout = {hs};
            end
        end
        function varargout = plotPairs(obj,containingHandle)
            % plotPairs() - Plot each pair of features in feature space
            %   along the diagonals the densities of the two features are
            %   plotted. A DataSet.nFeatures x DataSet.nFeatures array of
            %   axes are created for the plots.
            %
            % [plotHandles, axesHandles] = plotPairs(prtDataSetClassObj)
            % [...] = plotPairs(prtDataSetClassObj, containingHandle);
            %       containingHandle should be a valid parent for a MATLAB
            %       axes object such as a uipanel or a figure. The default
            %       is gcf.
            
            if nargin < 2 || isempty(containingHandle)
                containingHandle = gcf;
            end
            
            assert(ishghandle(containingHandle),'prt:prtDataSetClass:prtPlotPairs','containingHandle must be a MATLAB handle graphics handle that is a valid parent for MATLAB axes');
            
            N = obj.nFeatures;
            Summary = obj.summarize();
            
            fNames = obj.getFeatureNames();
            
            borderH = 0.1;
            interBorderH = 0.005;
            borderV = 0.1;
            interBorderV = 0.005;
  
            containerPos = get(containingHandle,'Position');
            containerAspect = containerPos(3)/containerPos(4);
            borderV = borderV*containerAspect;
            interBorderV = interBorderV*containerAspect;
            
            sizeH = (1 - borderH*2 - interBorderH*2*(N-1))/N;
            sizeV = (1 - borderV*2 - interBorderV*2*(N-1))/N;
            
            axesStartsH = borderH:(sizeH+interBorderH*2):(1-borderH);
            axesStartsV = fliplr(borderV:(sizeV+interBorderV*2):(1-borderV));
            
            hs = cell(N);
            axesHandles = zeros(N,N);
            for iFeature = 1:N
                for jFeature = 1:N
                    axesHandles(iFeature,jFeature) = axes('Parent',containingHandle,'Position',[axesStartsH(iFeature) axesStartsV(jFeature) sizeH sizeV]);
                    
                    if iFeature == jFeature
                        hs{iFeature,jFeature} = plotFeatureDensity(obj, iFeature);
                    else
                        hs{iFeature,jFeature} = obj.plot([iFeature jFeature]);
                        axis([Summary.lowerBounds(iFeature), Summary.upperBounds(iFeature) Summary.lowerBounds(jFeature), Summary.upperBounds(jFeature)])
                    end
                    
                    ylabel('');
                    xlabel('');
                    title('');
                    
                    legend('off')
                    grid on;
                    if iFeature == 1 || iFeature == N
                        ylabel(fNames{jFeature})
                    end
                    if ~(iFeature == 1 || iFeature == N)
                        set(gca,'YTickLabel',{});
                    end
                    if iFeature == N && N>1
                        set(gca,'YAxisLocation','Right')
                    end
                    if jFeature == N  || jFeature == 1
                        xlabel(fNames{iFeature})
                    end
                    if ~(jFeature == 1 || jFeature == N)
                        set(gca,'XTickLabel',{});
                    end
                    if (jFeature == 1)  && N>1
                        set(gca,'XAxisLocation','Top')
                    end                    
                    
                    if (iFeature==N && jFeature==N)
                        % Create legend
                        if obj.isLabeled
                            legendStrings = getClassNames(obj);
                            legendHandle = legend(hs{iFeature,jFeature},legendStrings,'Location','SouthEast'); %#ok<NASGU>
                        else
                            legendHandle = []; %#ok<NASGU>
                        end
                    end
                    
                end
            end
            
            if nargout
                varargout = {hs,axesHandles};
            end
        end
         function varargout = plotStar(obj,featureIndices)
            % plotStar   Create a star plot
            %
            %   dataSet.plotStar() creates a star plot of the data
            %   contained in the prtDataSetClass dataSet. Star plots can be
            %   useful in visulaizing higher dimensional data sets.
            
            if nargin < 2 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            if islogical(featureIndices)
                featureIndices = find(featureIndices);
            end
            
            nPlotDimensions = length(featureIndices);
            if nPlotDimensions < 1
                warning('prt:plot:NoPlotDimensionality','No plot dimensions requested.');
                return
            end
            if nPlotDimensions < 3
                warning('prt:plotStar:TooFewDimensions','Star plots with fewer than 3 dimensions will look like lines or dots; star plots are best suited for data sets with > 2 features');
            end
            
            theta = linspace(0,2*pi,length(featureIndices)+1);
            theta = theta(1:end-1);
            cT = cos(theta);
            sT = sin(theta);
            maxVal = max(abs(obj.getObservations(:,featureIndices)));
            
            nFeats = length(featureIndices);
            classColors = obj.PlotOptions.colorsFunction(obj.nClasses);
            
            uClasses = obj.uniqueClasses;
            holdState = get(gca,'nextPlot');
            hold on
            for i = 1:obj.nObservations;
                centerI = 0;
                centerJ = 0;
                
                currObs = obj.getObservations(i,featureIndices)./(maxVal*2);
                points = bsxfun(@plus,[cT.*currObs;sT.*currObs],[centerI;centerJ]);
                
                ppoints = cat(2,points,points(:,1));
                
                h = plot([repmat(centerI,nFeats,1),points(1,:)']',[repmat(centerJ,nFeats,1),points(2,:)']',ppoints(1,:)',ppoints(2,:)','lineWidth',obj.PlotOptions.starLineWidth);
                classInd = obj.getTargets(i) == uClasses;
                set(h,'color',classColors(classInd,:));
            end
            title(obj.name);
            
            % Plot axes and text:
            %textRotationAngles = rem(theta-pi/2,2*pi)/pi*180;
            axesLength = .6;

            if obj.nFeatures < 100
                plot(axesLength*cat(1,zeros(1,length(cT)),cT),axesLength*cat(1,zeros(1,length(sT)),sT),'color',[0 0 0],'lineWidth',2)
                
                fNames = obj.getFeatureNames();
                
                textOffSet = 0.2;
                textRadius = axesLength+textOffSet;
                
                textRotationAngles = zeros(size(theta));
                for iAxes = 1:length(cT)
                    text(textRadius*cT(iAxes),textRadius*sT(iAxes), fNames{iAxes}, 'rotation', textRotationAngles(iAxes),'HorizontalAlignment','Center','VerticalAlignment','Middle');
                end
            end
            axis([-1 1 -1 1]*(axesLength + 0.4));
            
            handleArray = zeros(obj.nClasses,1);
            for iClass = 1:obj.nClasses
                handleArray(iClass) = plot(nan,nan,'color',classColors(iClass,:));
            end
            
            % Create legend
            if obj.isLabeled
                legendStrings = getClassNames(obj);
                legend(handleArray,legendStrings,'Location','SouthEast');
            end
            
            set(gca,'XTick',[],'YTick',[],'Box','on')
            
            set(gca,'nextPlot',holdState);
            
            if nargout > 0
                varargout = {handleArray};
            end
        end
        
        function varargout = plotStarIndividual(obj,featureIndices)
            % plotStarIndividual   Create a star plot
            %
            %   dataSet.plotStarIndividual() creates a star plot of the data
            %   contained in the prtDataSetClass dataSet. Star plots can be
            %   useful in visulaizing higher dimensional data sets.
            %   plotStarIndividual plots each observation by itself.
            
            if nargin < 2 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            if islogical(featureIndices)
                featureIndices = find(featureIndices);
            end
            
            nPlotDimensions = length(featureIndices);
            if nPlotDimensions < 1
                warning('prt:plot:NoPlotDimensionality','No plot dimensions requested.');
                return
            end
            if nPlotDimensions < 3
                warning('prt:plotStar:TooFewDimensions','Star plots with fewer than 3 dimensions will look like lines or dots; star plots are best suited for data sets with > 2 features');
            end
            
            M = ceil(sqrt(obj.nObservations));
            
            theta = linspace(0,2*pi,length(featureIndices)+1);
            theta = theta(1:end-1);
            cT = cos(theta);
            sT = sin(theta);
            maxVal = max(abs(obj.getObservations(:,featureIndices)));
            
            nFeats = length(featureIndices);
            classColors = obj.PlotOptions.colorsFunction(obj.nClasses);
            
            uClasses = obj.uniqueClasses;
            holdState = get(gca,'nextPlot');
            for i = 1:obj.nObservations;
                [centerI,centerJ] = ind2sub([M,M],i);
                centerJ = M - centerJ;
                
                currObs = obj.getObservations(i,featureIndices)./(maxVal*2);
                points = bsxfun(@plus,[cT.*currObs;sT.*currObs],[centerI;centerJ]);
                
                ppoints = cat(2,points,points(:,1));
                
                h = plot([repmat(centerI,nFeats,1),points(1,:)']',[repmat(centerJ,nFeats,1),points(2,:)']',ppoints(1,:)',ppoints(2,:)','lineWidth',obj.PlotOptions.starLineWidth);
                classInd = obj.getTargets(i) == uClasses;
                if isempty(classInd) %unlabeled dataset
                    classInd = 1;
                end
                
                set(h,'color',classColors(classInd,:));
                hold on;
            end
            handleArray = zeros(obj.nClasses,1);
            for iClass = 1:obj.nClasses
                handleArray(iClass) = plot(nan,nan,'color',classColors(iClass,:));
            end
            
            % Create legend
            if obj.isLabeled
                legendStrings = getClassNames(obj);
                legend(handleArray,legendStrings,'Location','SouthEast');
            end
            
            set(gca,'nextPlot',holdState);
            set(gca,'xtick',[]);
            set(gca,'ytick',[]);
            
            title(obj.name);
            if nargout > 0
                varargout = {h};
            end
        end
        
        %PLOT:
        function varargout = plot(obj, featureIndices)
            % Plot   Plot the prtDataSetClass object
            %
            %   dataSet.plot() Plots the prtDataSetClass object.
            
            if nargin < 2 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            if islogical(featureIndices)
                featureIndices = find(featureIndices);
            end
            
            nPlotDimensions = length(featureIndices);
            if nPlotDimensions < 1
                warning('prt:plot:NoPlotDimensionality','No plot dimensions requested.');
                return
            elseif nPlotDimensions > 3
                %Too many dimensions; default to explore()
                explore(obj);
                return;
            end
            nClasses = obj.nClasses;
            
            classColors = obj.PlotOptions.colorsFunction(obj.nClasses);
            classSymbols = obj.PlotOptions.symbolsFunction(obj.nClasses);
            lineWidth = obj.PlotOptions.symbolLineWidth;
            markerSize = obj.PlotOptions.symbolSize;
            
            handleArray = zeros(nClasses,1);
            
            holdState = get(gca,'nextPlot');
            % This call to gca will create a figure if it doesn't already
            % exist
            
            % Loop through classes and plot
            for i = 1:nClasses
                cX = obj.getObservationsByClassInd(i, featureIndices);
                classEdgeColor = obj.PlotOptions.symbolEdgeModificationFunction(classColors(i,:));
                
                handleArray(i) = prtPlotUtilScatter(cX,obj.getFeatureNames(featureIndices),classSymbols(i),classColors(i,:),classEdgeColor,lineWidth, markerSize);
                
                if i == 1
                    hold on;
                end
            end
            set(gca,'nextPlot',holdState);
            % Set title
            title(obj.name);
            
            % Create legend
            legendStrings = [];
            if obj.isLabeled
                legendStrings = getClassNames(obj);
                legend(handleArray,legendStrings,'Location','SouthEast');
            end
            
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {handleArray,legendStrings};
            end
        end
        
        function Summary = summarize(Obj)
            % Summarize   Summarize the prtDataSetClass object
            %
            % SUMMARY = dataSet.summarize() Summarizes the dataSetClass
            % object and returns the result in the struct SUMMARY.
            
            Summary.upperBounds = max(Obj.getObservations());
            Summary.lowerBounds = min(Obj.getObservations());
            Summary.nFeatures = Obj.nFeatures;
            Summary.nTargetDimensions = Obj.nTargetDimensions;
            Summary.nObservations = Obj.nObservations;
            
            Summary.nClasses = Obj.nClasses;
            Summary.isMary = Obj.isMary;
        end
        
        function [Out, newObsInds] = bootstrapByClass(Obj,N)
            % BOOTSTRAPBYCLASS Generate bootstrap samples from prtDataSetClass object
            %       
            %
            %   OUT = dataSet.bootstrapByClass(N) Bootstrap sample N data
            %   points from each of the unique class labels.  If N is a
            %   scalar, N samples are drawn from each unique class in
            %   dataSet.  If N is a vector of the same length as
            %   uniqueClasses, the N(i) samples are drawn from the class
            %   corresponding to the i'th unique element in dataSet.
            %
            %   OUT = dataSet.bootstrapByClass(TARGETS) Bootstrap sample
            %   data from dataset extracting the same number of samples
            %   from each class as there are in the TARGETS. TARGETS must
            %   be a vector of class labels. For example, if targets = [1 1
            %   1 0 0 0 0 ]', dataSet.boostrapByClass(TARGETS) will return
            %   3 samples from class 1 and 4 samples from class 0.
            %
      
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
            if (any(N < 1) || any(N ~= round(N)))
                error('All number of samples in N must be integers and greater than 0, N = %s',mat2str(N));
            end
            if length(N) ~= nClasses
                error('Number of samples (N) must be either scalar integer or a vector integer of dataSet.nClasses (%d), N is a %s %s',nClasses,mat2str(size(N)),class(N));
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
        
        function classHist = get.nObservationsByClass(Obj)
            % nObservationsByClass Return the number of observations per class
            % 
            %   N = dataSet.nObservationsByClass() returns a vector
            %   consisting of the number of observations per class.
            
            classHist = Obj.targetsCacheHist;
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
    end
    methods (Static, Hidden = true)
        function PlotOptions = initializePlotOptions()
            PlotOptions = prtOptionsGet('prtOptionsDataSetClassPlot');
        end
    end
    methods (Hidden = true)
        function obj = copyDescriptionFieldsFrom(obj,dataSet)
            if dataSet.hasClassNames && obj.isLabeled
                obj = obj.setClassNames(dataSet.getClassNames);
            end
            obj = copyDescriptionFieldsFrom@prtDataSetStandard(obj,dataSet);
        end
        function has = hasClassNames(obj)
            has = ~isempty(obj.classNames);
        end
    end
    methods (Hidden=true, Access='protected')
        function obj = updateTargetsCache(obj)
            % This is an overload from prtDataSetClass so that we can 
            % Cache unique targets
            % This is called automatically in prtDataSetStandard anytime
            % targets are (re)set
            %
            % see also updateObservationsCache (not overloaded here)
            if isempty(obj.targets)
                obj.targetsCacheUnique = [];
                obj.targetsCacheNClasses = 1; % If unlabeled we really have one class
                obj.targetsCacheHist = obj.nObservations;
            else
                obj.targetsCacheUnique = unique(obj.targets,'rows');
                obj.targetsCacheNClasses = length(obj.targetsCacheUnique);
                obj.targetsCacheHist = histc(obj.targets,obj.targetsCacheUnique);
            end
        end
        function obj = updateObservationsCache(obj)
            % This is an overload from prtDataSetClass so that we can
            % cache things about the observations
            % This is called automatically in prtDataSetStandard anytime
            % data is (re)set
            
            % Here we modify the targets cache if we don't have targets
            % This is because we have to infer targetsCacheHist as the
            % number of observations changes
            if isempty(obj.targets)
                obj.targetsCacheHist = obj.nObservations;
            end
        end
    end
    methods (Hidden)
        %PLOTBW:
        function varargout = plotbw(obj, featureIndices)
            % plotbw   Plots the prtDataSetClass object
            %
            %   dataSet.plotbw() Plots the prtDataSetClass object in a
            %   manner that will display well when converted to black and
            %   white.
            
            if nargin < 2 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            if islogical(featureIndices)
                featureIndices = find(featureIndices);
            end
            
            nPlotDimensions = length(featureIndices);
            if nPlotDimensions < 1
                warning('prt:plot:NoPlotDimensionality','No plot dimensions requested.');
                return
            end
            nClasses = obj.nClasses;
            classColors = obj.PlotOptions.colorsFunctionBw(obj.nClasses);
            classSymbols = obj.PlotOptions.symbolsFunctionBw(obj.nClasses);
            
            lineWidth = obj.PlotOptions.symbolLineWidth;
            markerSize = obj.PlotOptions.symbolSize;
            
            handleArray = zeros(nClasses,1);
            
            holdState = get(gca,'nextPlot');
            % Loop through classes and plot
            for i = 1:nClasses
                %Use "i" here because it's by uniquetargetIND
                cX = obj.getObservationsByClassInd(i, featureIndices);
                classEdgeColor = classColors(i,:);
                
                handleArray(i) = prtPlotUtilScatter(cX,obj.getFeatureNames(featureIndices),classSymbols(i),classColors(i,:),classEdgeColor,lineWidth, markerSize);
                
                if i == 1
                    hold on;
                end
            end
            set(gca,'nextPlot',holdState);
            % Set title
            title(obj.name);
            grid on
            
            % Create legend
            if obj.isLabeled
                legendStrings = getClassNames(obj);
                legend(handleArray,legendStrings,'Location','SouthEast');
            end
            
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {handleArray};
            end
        end
    end
end
