classdef prtDataSetClass  < prtDataSetInMemory
    % prtDataSetClass  < prtDataSetInMemory
    %
    % properties (Dependent)
    %       nClasses
    %       uniqueClasses
    %
    %       isUnary = nan          % logical, true if nClasses == 1
    %       isBinary = nan         % logical, true if nClasses == 2
    %       isMary = nan           % logical, true if nClasses > 2
    %       isZeroOne = nan        % true if isequal(uniqueClasses,[0 1])
    %
    % properties
    %       classNames - should this be a cell array?  not clear
    %
    % methods
    %       getObservationsByClass
    %       getObservationsByClassInd
    %       getTargetsAsBinaryMatrix
    %
    %       explore
    %       plotAsTimeSeries
    %       starPlot
    %       plot
    %       plotbw
    %

    properties (Dependent)
        nClasses
        uniqueClasses
        
        isUnary                % logical, true if nClasses == 1
        isBinary               % logical, true if nClasses == 2
        isMary                 % logical, true if nClasses > 2
        isZeroOne              % true if isequal(uniqueClasses,[0 1])
    end
    
    properties 
        classNames = {};
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
            isZO = isequal(obj.uniqueClasses,[0 1]);
        end
        function nUT = get.nClasses(obj)
            nUT = length(obj.uniqueClasses);
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
        
        function obj = prtDataSetClass(varargin)
            if nargin == 0
                return;
            end
            if isa(varargin{1},'prtDataSetClass')
                obj = prtDataSetClass;
                varargin = varargin(2:end);
            end
            if isa(varargin{1},'double')
                obj = obj.setObservations(varargin{1});
                varargin = varargin(2:end);
                
                if nargin >= 2 && (isa(varargin{1},'double') || isa(varargin{1},'logical'))
                    obj = obj.setTargets(varargin{1});
                end
                varargin = varargin(2:end);
            end
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Set Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = set.classNames(obj, newClassNames)
            if isempty(newClassNames) || obj.nClasses == 0
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
        %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %         function prtDataSet = setTargets(obj,targets)
        %             %prtDataSet = setTargets(obj,targets)
        %             if iscellstr(targets)
        %                 [classes,uniqueClasses] = prtUtilStringsToClassNumbers(targets);
        %             else
        %                 classes = targets;
        %                 uniqueClasses = {};
        %             end
        %             %prtDataSet = setTargets@prtDataSetInMemoryLabeled(obj,classes);
        %             prtDataSet.classNames = uniqueClasses;
        %         end
        
        function binaryMatTargets = getTargetsAsBinaryMatrix(obj,indices1,indices2)
            %binaryMatTargets = getTargetsAsBinaryMatrix(obj)
            binaryMatTargets = zeros(obj.nObservations,obj.nClasses);
            for i = 1:obj.nClasses
                binaryMatTargets(:,i) = obj.getTargets == obj.uniqueClasses(i);
            end
            
            if nargin == 1
                return
            end
            
            % Else select only some of the matrix
            
            if nargin < 2 || isempty(indices1) || strcmpi(indices1,':')
                indices1 = 1:obj.nObservations;
            end
            if nargin < 3 || isempty(indices2) || strcmpi(indices2,':')
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
        
        function explore(obj)
            prtDataSetBase.makeExploreGui(obj,obj.getFeatureNames);
        end
        
        function varargout = plotAsTimeSeries(obj,featureIndices)
            
            if ~obj.isLabeled
                obj = obj.setTargets(0);
                obj = obj.setClassNames({'Unlabeled'});
            end
            
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
            
            if ~obj.isLabeled
                obj = obj.setTargets(0);
                obj = obj.setClassNames({'Unlabeled'});
            end
            
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
            
            if ~obj.isLabeled
                obj = obj.setTargets(0);
                obj = obj.setClassNames({'Unlabeled'});
            end
            
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
        %PLOTBW:
        function varargout = plotbw(obj, featureIndices)
            
            if ~obj.isLabeled
                obj = obj.setTargets(0);
                obj = obj.setClassNames({'Unlabeled'});
            end
            
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
            classColors = prtPlotUtilClassColorsBW(nClasses);
            classSymbols = prtPlotUtilClassSymbolsBW(nClasses);
            handleArray = zeros(nClasses,1);
            
            holdState = get(gca,'nextPlot');
            % Loop through classes and plot
            for i = 1:nClasses
                %Use "i" here because it's by uniquetargetIND
                cX = obj.getObservationsByClassInd(i, featureIndices);
                %classEdgeColor = prtDataSetBase.edgeColorMod(classColors(i,:));
                
                linewidth = 1;
                %handleArray(i) = prtDataSetBase.plotPoints(cX,obj.getFeatureNames(featureIndices),classSymbols(i),classColors(i,:),classEdgeColor,linewidth);
                switch size(cX,2)
                    case 1
                        handleArray(i) = plot(cX, ones(cX,1), classSymbols(i),'color',[0 0 0],'linewidth',linewidth,'markerfaceColor',classColors(i,:));
                    case 2
                        handleArray(i) = plot(cX(:,1), cX(:,2), classSymbols(i),'color',[0 0 0],'linewidth',linewidth,'markerfaceColor',classColors(i,:));
                    case 3
                        handleArray(i) = plot3(cX(:,1), cX(:,2), cX(:,3), classSymbols(i),'color',[0 0 0],'linewidth',linewidth,'markerfaceColor',classColors(i,:));
                end
                
                if i == 1
                    hold on;
                end
            end
            set(gca,'nextPlot',holdState);
            % Set title
            title(obj.name);
            grid on
            
            % Create legend
            legendStrings = getClassNames(obj);
            legend(handleArray,legendStrings,'Location','SouthEast');
            
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {handleArray,legendStrings};
            end
        end
        
        function Summary = summarize(Obj)
            Summary.upperBounds = max(Obj.getObservations());
            Summary.lowerBounds = min(Obj.getObservations());
            Summary.nFeatures = Obj.nFeatures;
            Summary.nTargetDimensions = Obj.nTargetDimensions;
            Summary.nObservations = Obj.nObservations;
            
            Summary.nClasses = Obj.nClasses;
            Summary.isMary = Obj.isMary;
        end
        
    end
end