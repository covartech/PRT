classdef prtDataSetClass  < prtDataSetStandard
    % prtDataSetClass  < prtDataSetStandard
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
        nObservationsByClass
        
        isUnary                % logical, true if nClasses == 1
        isBinary               % logical, true if nClasses == 2
        isMary                 % logical, true if nClasses > 2
        isZeroOne              % true if isequal(uniqueClasses,[0 1])
    end
    
    properties (Access = 'private')
        classNames
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
            
            obj.classNames = java.util.Hashtable;
            if nargin == 0
                return;
            end
            if isa(varargin{1},'prtDataSetClass')
                obj = varargin{1};
                varargin = varargin(2:end);
            end
            
            if length(varargin) >= 1 && isa(varargin{1},'double')
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
            
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Access methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function tn = getClassNamesByClassInd(obj,varargin)
            indices1 = prtDataSetBase.parseIndices(obj.nClasses, varargin{:});
            uniqueClasses = obj.uniqueClasses;
            
            tn = cell(length(indices1),1);
            for i = 1:length(indices1)
                if obj.classNames.containsKey(uniqueClasses(indices1(i)))
                    tn{i} = obj.classNames.get(uniqueClasses(indices1(i)));
                else
                    tn(i) = prtDataSetClass.generateDefaultClassNames(uniqueClasses(indices1(i)));
                end
            end
        end
        
        function obj = setClassNamesByClassInd(obj,names,varargin)
            indices1 = prtDataSetBase.parseIndices(obj.nClasses, varargin{:});
            uniqueClasses = obj.uniqueClasses;
            
            for i = 1:length(indices1)
                obj.classNames.put(uniqueClasses(indices1(i)),names{i});
            end
        end
        
        function tn = getClassNames(obj,classes)
            
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
            
            if nargin < 3
                classes = obj.uniqueClasses;
            end
            uniqueClasses = obj.uniqueClasses;
            
            if ~isempty(setdiff(classes,uniqueClasses))
                error('classes contains classes not in uniqueClasses');
            end
            [~,~,ib] = intersect(classes,uniqueClasses);
            obj = setClassNamesByClassInd(obj,names,ib);
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
        
        function obj = catObservations(obj,varargin)
            for i = 1:length(varargin)
                disp('catting');
                if isa(varargin{i},'prtDataSetClass')
                    obj = catClassNames(obj,varargin{i});
                end
            end
            obj = catObservations@prtDataSetStandard(obj,varargin{:});
        end
        
        function obj = catClassNames(obj,newDataSet)
            
            newUniqueClasses = newDataSet.uniqueClasses;
            for i = 1:length(newUniqueClasses);
                %if the current data set doesn't have this key, and the
                %other data set does, well, use the other data set's name
                %for this class
                if ~obj.classNames.containsKey(newUniqueClasses(i)) && newDataSet.classNames.containsKey(newUniqueClasses(i));
                    obj.classNames.put(newUniqueClasses(i),newDataSet.classNames.get(newUniqueClasses(i)));
                    %If both the data sets have the key, and the strings
                    %don't match...
                elseif (obj.classNames.containsKey(newUniqueClasses(i)) && newDataSet.classNames.containsKey(newUniqueClasses(i))) && ...
                        ~strcmpi(newDataSet.classNames.get(newUniqueClasses(i)),obj.classNames.get(newUniqueClasses(i)))
                    warning('prt:prtDataSetClass:IncompatibleClassNames','Incompatible class names encountered; retaining original data sets class names');
                end
            end
        end
        
        function d = getObservationsByClassInd(obj, classInd, featureIndices)
            if nargin < 3 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            
            d = obj.getObservations(obj.getTargets == obj.uniqueClasses(classInd),featureIndices);
        end
        
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
        
        function explore(obj)
            prtDataSetBase.makeExploreGui(obj,obj.getFeatureNames);
        end
        
        function varargout = plotAsTimeSeries(obj,featureIndices)
            
            if ~obj.isLabeled
                obj = obj.setTargets(zeros(obj.nObservations,1));
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
                obj = obj.setTargets(zeros(obj.nObservations,1));
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
        
        function Out = bootstrapByClass(Obj,N)
            %   BOOTSTRAPBYCLASS Generate "bootstrap" samples from dataset
            %       incorporating N samples from each class in
            %
            %   Out = bootstrapByClass(Obj,N) Bootstrap sample N data points
            %       from each of the unique class labels in Y.  If N is a scalar, N
            %       samples are drawn from each unique label in Y.  If N is a vector
            %       of length length(unique(Y)), N(i) samples are drawn from the class
            %       corresponding to the i'th unique element in Y (as determined by
            %       unique.m)
            %
            %   Out = bootstrapByClass(Obj) Bootstrap sample data from
            %       dataset extracting the same number of samples from each
            %       class as there are in the input. 
            %       If targets = [1 1 1 0 0 0 0 ]'; for example,
            %       dprtBootstrapByClass(X,Y) will return 3 samples from
            %       class 1 and 4 samples from class 0.
            %
            %     Inputs:
            %         Obj ~ PRT Data Set Class
            %         N ~ integer scalar or vector - number of bootstrap samples to
            %           draw; if integer, draw equally from all classes, if vector,
            %           draw N(i) from class corresponding to i'th element of unique(Y)

            if nargin < 2 || isempty(N)
                N = Obj.nObservationsByClass;
            end
            
            nClasses = Obj.nClasses;
            
            if isscalar(N);
                N = N*ones(nClasses,1);
            end
            
            if length(N) ~= nClasses
                error('Number of samples (N) must be either scalar or a vector of DS.nClasses (%d), N is %s',nClasses,mat2str(size(N)));
            end
            
            OutputsByClass = repmat(prtDataSetClass(),[nClasses,1]);
            for iClass = 1:nClasses
                OutputsByClass(iClass) = bootstrap(retainObservations(Obj,Obj.getTargets==Obj.uniqueClasses(iClass)), N(iClass));
            end
            
            Out = catObservations(OutputsByClass);
            
        end
        
        function classHist = get.nObservationsByClass(Obj)
            classHist = histc(Obj.getTargets, Obj.uniqueClasses);
        end
        
        function classInds = getTargetsClassInd(obj,varargin)
            %targets = getTargetsClassInd(obj)
            %targets = getTargetsClassInd(obj,indices1)
            %targets = getTargetsClassInd(obj,indices1,indices2)
            
            targets = getTargets(obj,varargin{:});
            
            [~, classInds] = ismember(targets,obj.uniqueClasses);
        end
        
    end
end