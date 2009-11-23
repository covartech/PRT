classdef prtDataSetClass < prtDataSetInMemoryLabeled & prtDataSetBaseClass
    % Standard prtDataSet for data with categorical labels (integer targets)
    
    properties %(GetAccess = 'protected') %why so protected?
        classNames = {} % strcell, 1 x nClasses
    end
    properties (Dependent)
        uniqueClasses = {};
    end
    methods
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function prtDataSet = prtDataSetClass(varargin)
            % prtDataSet = prtDataSetClass
            % prtDataSet = prtDataSetClass(prtDataSetClassIn, {paramName1, paramVal2, ...})
            % prtDataSet = prtDataSetClass(data, targets, {paramName1, paramVal2, ...})
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Empty Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % prtDataSet = prtDataSetClass %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if nargin == 0
                % Empty constructor
                % Nothing to do
                return
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % All Other Constructors %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % prtDataSet = prtDataSetClass(prtDataSetIn, {paramName1, paramVal2, ...})
            % prtDataSet = prtDataSetClass(data, targets, {paramName1, paramVal2, ...})
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(varargin{1}, 'prtDataSetClass')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Copy Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % prtDataSet = prtDataSetClass(prtDataSetClassIn, {paramName1, paramVal2, ...})
                % Will be the same as other constructors after this..
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                prtDataSet = varargin{1};
                varargin = varargin(2:end);
            elseif isa(varargin{1}, 'prtDataSetUnLabeled')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Label Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % prtDataSet = prtDataSetClass(prtDataSetUnLabeledIn, targets, {paramName1, paramVal2, ...})
                % Will be the same as other constructors after this..
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                keyboard
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Regular Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % prtDataSet = prtDataSetClass(data, targets, {paramName1, paramVal2, ...})
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if nargin < 2
                    error('prt:prtDataSetClass:invalidInputs','both data and targets must be specified.');
                end
                if size(varargin{1},1) ~= size(varargin{2},1)
                    error('prt:prtDataSetClass:dataTargetsMismatch','size(data,1) (%d) must match size(targets,1) (%d)',size(varargin{1},1), size(varargin{2},1));
                end
                prtDataSet = prtDataSet.setDataAndTargets(varargin{1},varargin{2});
                
                varargin = varargin(3:end);
            end
            
            % At this point we have varargin as string value pairs and
            % prtDataSet with data and targets set
            
            % Quick exit if no more inputs.
            if isempty(varargin)
                return
            end
            
            % Check Parameter string, value pairs
            inputError = false;
            if mod(length(varargin),2)
                inputError = true;
            end
            paramNames = varargin(1:2:(end-1));
            if ~iscellstr(paramNames)
                inputError = true;
            end
            paramValues = varargin(2:2:end);
            if inputError
                error('prt:prtDataSetLabeled:invalidInputs','Additional input arguments must be specified as parameter string, value pairs.')
            end
            
            % Now we loop through and apply the properties
            for iPair = 1:length(paramNames)
                prtDataSet.(paramNames{iPair}) = paramValues{iPair};
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
    
    methods (Access = 'private',Static = true);
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
        
    end
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Set Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = set.classNames(obj, newClassNames)
            if isempty(newClassNames)
                obj.classNames = newClassNames;
                return;
            end
            if  length(newClassNames) ~= obj.nClasses
                error('prt:prtDataSetLabeled:ClassNamesInput','obj.nClasses (%d) must match length(newClassNames) (%d)', obj.nClasses, length(newClassNames));
            end
            if ~iscellstr(newClassNames)
                error('prt:prtDataSetLabeled:ClassNamesInput','newClassNames must be a cell array of strings.');
            end
            obj.classNames = newClassNames;
        end

        function tn = get.classNames(obj)
            % We choose not to generate the default names here to save
            % time. Because the GetAccess is protected we generate these in
            % uniqueClassNames(). This means internally or in sub-classes
            % you will sometimes get an {} if nothing has been set whereas
            % uniqueClassNames() will generate the default feature names.
            tn = obj.classNames;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Access methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function tn = getClassNames(obj)
            if isempty(obj.classNames)
                tn = prtDataSetClass.generateDefaultClassNames(obj.uniqueClasses);
            else
                tn = obj.classNames;
            end
        end
        
        function obj = setClassNames(obj,names)
            obj.classNames = names;
        end
        
        function d = getObservationsByClass(obj, class, featureIndices)
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
            % This can be slow, but we can't make this persistent.
            % We don't know when if labels have changed
            uT = unique(obj.targets);
        end
        
        function d = getObservationsByClassInd(obj, classInd, featureIndices)
            if nargin < 3 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            
            d = obj.getObservations(obj.getTargets == obj.uniqueClasses(classInd),featureIndices);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function prtDataSet = setTargets(obj,targets)
            %prtDataSet = setTargets(obj,targets)
            if iscellstr(targets)
                [classes,uniqueClasses] = prtUtilStringsToClassNumbers(targets);
            else
                classes = targets;
                uniqueClasses = {};
            end
            prtDataSet = setTargets@prtDataSetInMemoryLabeled(obj,classes);
            prtDataSet.classNames = uniqueClasses;
        end
        
        
        function binaryMatTargets = getTargetsAsBinaryMatrix(obj)
            %binaryMatTargets = getTargetsAsBinaryMatrix(obj)
            binaryMatTargets = zeros(obj.nObservations,obj.nClasses);
            for i = 1:obj.nClasses
                binaryMatTargets(:,i) = obj.getTargets == obj.uniqueClasses(i);
            end
        end
        
        function explore(obj)
            prtDataSetClass.makeExploreGui(obj,obj.getFeatureNames);
        end
        
        function varargout = plotAsTimeSeries(obj,featureIndices)
            if nargin < 2 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            
            nClasses = obj.nClasses;
            classColors = obj.plottingColors;
            handleArray = zeros(nClasses,1);
            
            holdState = get(gca,'nextPlot');
            % Loop through classes and plot
            for i = 1:nClasses
                %Use "i" here because it's by uniquetargetIND
                cX = obj.getObservationsByClassInd(i, featureIndices);                
                
                xInd = 1:size(cX,2);
                linewidth = .1;
                h = prtDataSetBase.plotLines(xInd,cX,classColors(i,:),linewidth);
                handleArray(i) = h(1);
                if i == 1
                    hold on;
                end
            end
            set(gca,'nextPlot',holdState);
            % Set title
            title(obj.name);
            
            % Create legend
            legendStrings = getClassNames(obj);
            legend(handleArray,legendStrings,'Location','SouthEast');
                        
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {handleArray,legendStrings};
            end
        end
        
        function varargout = starPlot(obj,featureIndices)
            %varargout = starPlot(obj,featureIndices)
            
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
            
            M = ceil(sqrt(obj.nObservations));
            %plotGrid = linspace(0,1,M);
            
            theta = linspace(0,2*pi,length(featureIndices)+1);
            theta = theta(1:end-1);
            cT = cos(theta);
            sT = sin(theta);
            maxVal = max(abs(obj.getObservations(:,featureIndices)));
            
            nFeats = length(featureIndices);
            classColors = obj.plottingColors;
            uClasses = obj.uniqueClasses;
            for i = 1:obj.nObservations;
                [centerI,centerJ] = ind2sub([M,M],i);
                centerJ = M - centerJ;
                
                currObs = obj.getObservations(i,featureIndices)./(maxVal*2);
                points = bsxfun(@plus,[cT.*currObs;sT.*currObs],[centerI;centerJ]);
                
                ppoints = cat(2,points,points(:,1));
                
                h = plot([repmat(centerI,nFeats,1),points(1,:)']',[repmat(centerJ,nFeats,1),points(2,:)']',ppoints(1,:)',ppoints(2,:)');
                classInd = obj.getTargets(i) == uClasses;
                set(h,'color',classColors(classInd,:));
                hold on;
            end
            hold off;
            title(obj.name);
            if nargout > 0
                varargout = {h};
            end
        end
        
        %PLOT:
        function varargout = plot(obj, featureIndices)
            
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
            classColors = obj.plottingColors;
            classSymbols = obj.plottingSymbols;
            handleArray = zeros(nClasses,1);
            
            holdState = get(gca,'nextPlot');
            % Loop through classes and plot
            for i = 1:nClasses
                %Use "i" here because it's by uniquetargetIND
                cX = obj.getObservationsByClassInd(i, featureIndices);                
                classEdgeColor = prtDataSetBase.edgeColorMod(classColors(i,:));
                
                linewidth = .1;
                handleArray(i) = prtDataSetBase.plotPoints(cX,obj.getFeatureNames(featureIndices),classSymbols(i),classColors(i,:),classEdgeColor,linewidth);
                if i == 1
                    hold on;
                end
            end
            set(gca,'nextPlot',holdState);
            % Set title
            title(obj.name);
            
            % Create legend
            legendStrings = getClassNames(obj);
            legend(handleArray,legendStrings,'Location','SouthEast');
                        
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {handleArray,legendStrings};
            end
        end
        
    end
end
