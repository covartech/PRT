classdef prtDataSetLabeled < prtDataSetBase
    % prtDataSetLabeled < prtDataSetBase
    %   Standard prtDataSet for labeled training data.  prtDataSetLabeled
    %   allows access to generic feature data using methods
    %   getObservations, getLabels, getObservationNames, getFeatureNames,
    %   etc. and access to dependent properties like nDimensions,
    %   nObservations, nClasses, uniqueClasses, isBinary, etc.
    
    properties (Dependent = true)
        % Dependent properties for datasets
        nDimensions   % scalar, number of dimensions (columns) of the data
        nObservations % scalar, number of observations (rows) of the data
        
        % Dependent properties for labeled data only:
        nClasses      % scalar, number of unique class labels
        uniqueClasses % vector, unique class names in the dataSet
        isBinary      % logical, true if nClasses == 2
        isMary        % logical, true if nClasses > 2
        isUnary       % logical, true if nClasses == 1
        isZeroOne     % true if isequal(uniqueClasses,[0 1])
    end
    
    properties % Additional properties
        colorsFunction = @prtPlotUtilClassColors;   % For plotting
        symbolsFunction = @prtPlotUtilClassSymbols; % For plotting
    end
    
    properties (SetAccess = 'private')
        dataSetName = ''      % char
        featureNames  = {}    % strcell, 1 x nDimensions
        observationNames = {} % strcell, nObservations x 1
        data = []             % matrix, doubles, features
        dataLabels = []       % matrix, doubles, probably integers
        classNames = {}       % strcell, 1 x nClasses
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function prtDataSet = prtDataSetLabeled(varargin)
            % prtDataSet = prtDataSetLabeled
            % prtDataSet = prtDataSetLabeled(data, labels)
            % prtDataSet = prtDataSetLabeled(data, labels, paramName1, paramVal1, ...)
            
            if nargin == 0 % Empty constructor
                % Nothing to do
                return
            end
            
            % Check if we are supplying a set of data sets to join
            if all(cellfun(@(c)isa(c,'prtDataSetLabeled'),varargin))
                prtDataSet = varargin{1};
                for i = 2:length(varargin)
                    prtDataSet = prtDataSetLabeled(prtDataSet,'data',cat(2,prtDataSet.data,varargin{i}.data));
                end
                return
            end
            
            
            if isa(varargin{1},'prtDataSetLabeled')
                prtDataSet = varargin{1};
                varargin = varargin(2:end);
            else
                if nargin < 2
                    error('prt:prtDataSetLabeled:invalidInputs','both data and labels must be specified.');
                end
                if size(varargin{1},1) ~= size(varargin{2},1)
                    error('prt:prtDataSetLabeled:dataLabelsMismatch','size(data,1) (%d) must match size(labels,1) (%d)',size(varargin{1},1), size(varargin{2},1));
                end
                prtDataSet.data = varargin{1};
                prtDataSet.dataLabels = varargin{2};
                varargin = varargin(3:end);
            end
            
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
                error('prt:prtDataSetLabeled:invalidInputs','additional input arguments must be specified as parameter string, value pairs.')
            end
            % Set Values
            for iPair = 1:length(paramNames)
                prtDataSet.(paramNames{iPair}) = paramValues{iPair};
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Set Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Sanity error checks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = set.data(obj, data)
            if ~isa(data,'double') || ndims(data) ~= 2
                error('prt:prtDataSetLabeled:invalidData','data must be a 2-Dimensional double array');
            end
            obj.data = data;
        end
        function obj = set.featureNames(obj, featureNames)
            if size(featureNames(:),1) ~= obj.nDimensions
                error('prt:prtDataSetLabeled:dataFeaturesMismatch','obj.nDimensions (%d) must match size(featureNames(:),1) (%d)',obj.nDimensions,size(featureNames,2));
            end
            obj.featureNames = featureNames(:);
        end
        function obj = set.classNames(obj, classNames)
            if  size(classNames(:),1) ~= obj.nClasses
                error('prt:prtDataSetLabeled:labelsClassNamesMismatch','obj.nClasses (%d) must match size(classNames(:),1) (%d)',obj.nClasses,size(classNames,2));
            end
            obj.classNames = classNames;
        end
        function obj = set.dataSetName(obj, dataSetName)
            if ~isa(dataSetName,'char');
                error('prt:prtDataSetLabeled:dataSetNameNonString','dataSetName is a (%s), but dataSetName must be a character array',class(dataSetName));
            end
            obj.dataSetName = dataSetName;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get Methods for Dependent properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function nD = get.nDimensions(obj)
            nD = size(obj.data,2);
        end
        function nObs = get.nObservations(obj)
            nObs = size(obj.data,1);
        end
        function featureNames = get.featureNames(obj)
            % We choose not to generate the default names here to save time
            % If there are a ton of features we dont want to make all the
            % names when we probably only need a few of the names.
            featureNames = obj.featureNames;
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
            isZO = isequal(obj.uniqueClasses,[0 1]);
        end
        function uC = get.uniqueClasses(obj)
            % This can be slow, but we can't make this persistent.
            % We don't know when if labels have changed
            uC = unique(obj.dataLabels);
        end
        function nC = get.nClasses(obj)
            nC = length(obj.uniqueClasses);
        end
        function cn = get.classNames(obj)
            % We generate defaults here because there shouldn't be too many
            % and there isn't an occmpanied virtual get. You always get all
            % the classNames
            if isempty(obj.classNames)
                % Generate default
                uY = obj.uniqueClasses;
                cn = cell(length(uY),1);
                if isa(uY,'cell')
                    cn = uY;
                elseif isa(uY,'double')
                    for i = 1:length(uY)
                        cn{i} = sprintf('H_{%d}',uY(i));
                    end
                end
            else
                cn = obj.classNames;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Virtual dependent methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % These allow use to fetch rows and colums of X etc. %%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function data = getObservations(obj,indices1,indices2)
            if nargin < 2
                indices1 = 1:obj.nObservations;
            end
            if nargin < 3
                indices2 = 1:obj.nDimensions;
            end
            data = obj.data(indices1,indices2);
        end
        function o = getObservationNames(obj,indices1)
            if nargin == 0
                indices1 = 1:obj.nObservations;
            end
            if isempty(obj.observationNames)
                % Generate default
                o = cell(length(indices),1);
                for i = 1:length(indices)
                    o{i,1} = sprintf('Observation %d',indices(i));
                end
            else
                % Fetch from object
                o = obj.observationNames(indices1);
            end
        end
        function featureNames = getFeatureNames(obj,indices)
            if nargin < 2 || isempty(indices)
                indices = 1:obj.nDimensions;
            end
            if isempty(obj.featureNames)
                % Generate default featureNames
                featureNames = cell(length(indices),1);
                for i = 1:length(indices)
                    featureNames{i,1} = sprintf('Feature %d',indices(i));
                end
            else
                % Fetch from object
                featureNames = obj.featureNames(indices);
            end
        end
        function labels = getLabels(obj,indices)
            if nargin == 1
                indices = 1:obj.nObservations;
            end
            labels = obj.dataLabels(indices,:);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Other Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = addObservations(obj, newData, newLabels, newObsNames)
            if nargin < 4
                newObsNames = {};
            else
                if ~iscellstr(newObsNames)
                    error('prt:prtDataSetLabeled:incorrectInput','newObsNames, must be a cellstr.');
                end
                if size(newObsNames,1) ~= size(newData,1)
                    error('prt:prtDataSetLabeled:incorrectInput','The number of observations in the new data and the new observation names do not match.');
                end
            end
            
            if size(newData,2) ~= obj.nDimensions
                error('prt:prtDataSetLabeled:incorrectDimensionality','The dimensionality of the specified data (%d) does not match the dimensionality of this dataset (%d).', size(newData,2), obj.nDimensions);
            end
            
            if size(newData,1) ~= size(newLabels,1)
                error('prt:prtDataSetLabeled:incorrectInput','The number of observations in the new data and new labels do not match.');
            end
            
            oldNObs = obj.nObservations;
            
            % Cat the data and labels
            obj.data = cat(1,obj.data, newData);
            obj.dataLabels = cat(1,obj.dataLabels, newLabels);
            
            if ~isempty(obj.observationNames)
                if isempty(newObsNames)
                    % Generate default
                    newObsNames = cell(size(newData,1),1);
                    for i = 1:length(indices)
                        newObsNames{i,1} = sprintf('Observation %d',i+oldNObs);
                    end
                else
                    obj.observationNames = cat(1,obj.getObservationNames, newObsNames(:));
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Plotting Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function varargout = plot(obj, featureIndicies)
            % [H,L] = plot(dataSet); Plots the data in the data set using
            %   class names, feature names, etc.
            %
            %   Output H is a handle to the points plotted, and L is a
            %   cell array of legend strings
            
            if nargin < 2 || isempty(featureIndicies)
                featureIndicies = 1:obj.nDimensions;
            end
            if islogical(featureIndicies)
                featureIndicies = find(featureIndicies);
            end
            
            nPlotDimensions = length(featureIndicies);
            if nPlotDimensions < 1
                warning('prt:plot:NoPlotDimensionality','No plot dimensions requested.');
                return
            end
            if nPlotDimensions > 3
                error('prt:plot:plotDimensionality','The number of requested plot dimensions (%d) is greater than 3. You may want to use explore() to selet and visualize a subset of the features.',nPlotDimensions);
            end
            if max(featureIndicies) > obj.nDimensions
                error('prt:plot:plotDimensionality','A requested plot dimensions (%d) exceeds the dimensionality of the data set (%d).',max(featureIndicies),obj.nDimensions);
            end
            
            % Get colors and symbols from the colors and symbols functions
            classColors = obj.colorsFunction(obj.nClasses);
            classSymbols = obj.symbolsFunction(obj.nClasses);
            
            % Preserve the hold state of the figure
            holdState = ishold;
            
            handleArray = zeros(obj.nClasses,1);
            % Loop through classes and plot
            for i = 1:obj.nClasses
                currIndices = getLabels(obj) == obj.uniqueClasses(i);
                cX = getObservations(obj, currIndices, featureIndicies);
                cEdgeColor = min(classColors(i,:) + 0.2,[0.8 0.8 0.8]);
                
                switch nPlotDimensions
                    case 1
                        handleArray(i) = plot(cX,ones(size(cX)),classSymbols(i),'MarkerFaceColor',classColors(i,:),'MarkerEdgeColor',cEdgeColor,'linewidth',0.1);
                        xlabel(getFeatureNames(obj,featureIndicies(1)));
                        grid on
                    case 2
                        handleArray(i) = plot(cX(:,1),cX(:,2),classSymbols(i),'MarkerFaceColor',classColors(i,:),'MarkerEdgeColor',cEdgeColor,'linewidth',0.1);
                        xlabel(getFeatureNames(obj,featureIndicies(1)));
                        ylabel(getFeatureNames(obj,featureIndicies(2)));
                        grid on
                    case 3
                        handleArray(i) = plot3(cX(:,1),cX(:,2),cX(:,3),classSymbols(i),'MarkerFaceColor',classColors(i,:),'MarkerEdgeColor',cEdgeColor,'linewidth',0.1);
                        xlabel(getFeatureNames(obj,featureIndicies(1)));
                        ylabel(getFeatureNames(obj,featureIndicies(2)));
                        zlabel(getFeatureNames(obj,featureIndicies(3)));
                        grid on;
                end
                if i == 1
                    hold on;
                end
            end
            
            % Set title
            title(obj.dataSetName);
            
            % Set hold state back to the way it was
            if holdState
                hold on;
            else
                hold off;
            end
            
            % Create legend
                legendStrings = obj.classNames;
            legend(handleArray,legendStrings,'Location','SouthEast');
            
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {handleArray,legendStrings};
            end
        end
        
        function explore(obj)
            
            % Get the window position and pick/set a figure size.
            ss = get(0,'screensize');
            
            windowSize = [800 600];
            % Center the window
            sizePads = round((ss(3:4)-windowSize));
            sizePads(1) = sizePads(1)/2; % We should use 2 right?
            sizePads(2) = sizePads(2)/2;
            pos = cat(2,sizePads,windowSize);
            
            % Create the figure an UIControls
            figH = figure('Number','Off','Name','PRT Data Set Explorer','Menu','none','toolbar','figure','units','pixels','position',pos,'DockControls','off');
            
            % Trim the toolbar down to just the zooming controls
            Toolbar.handle = findall(figH,'Type','uitoolbar');
            Toolbar.Children = findall(figH,'Parent',Toolbar.handle,'HandleVisibility','off');
            
            % Delete a bunch of things we dont need
            delete(findobj(Toolbar.Children,'TooltipString','New Figure',...
                '-or','TooltipString','Open File','-or','TooltipString','Save Figure',...
                '-or','TooltipString','Print Figure','-or','TooltipString','Edit Plot',...
                '-or','TooltipString','Data Cursor','-or','TooltipString','Brush/Select Data',...
                '-or','TooltipString','Link Plot','-or','TooltipString','Insert Colorbar',...
                '-or','TooltipString','Insert Legend','-or','TooltipString','Show Plot Tools and Dock Figure',...
                '-or','TooltipString','Hide Plot Tools'))
            
            popUpStrs = getFeatureNames(obj);
            
            bgc = get(figH,'Color');
            popX = uicontrol(figH,'Style','popup','units','normalized','FontUnits','Normalized','FontSize',0.5,'position',[0.81 0.8 .18 0.05],'string',popUpStrs,'callback',{@plotSelectPopupCallback 1});
            popXHead = uicontrol(figH,'Style','text','units','normalized','FontUnits','Normalized','FontSize',0.5,'position',[0.81 0.85 .18 0.05],'string','X-Axis','BackgroundColor',bgc); %#ok
            
            popY = uicontrol(figH,'Style','popup','units','normalized','FontUnits','Normalized','FontSize',0.5,'position',[0.81 0.65 .18 0.05],'string',popUpStrs,'callback',{@plotSelectPopupCallback 2});
            popYHead = uicontrol(figH,'Style','text','units','normalized','FontUnits','Normalized','FontSize',0.5,'position',[0.81 0.7 .18 0.05],'string','Y-Axis','BackgroundColor',bgc); %#ok
            
            popZ = uicontrol(figH,'Style','popup','units','normalized','FontUnits','Normalized','FontSize',0.5,'position',[0.81 0.5 .18 0.05],'string',[{'None'}; popUpStrs],'callback',{@plotSelectPopupCallback 3});
            popZHead = uicontrol(figH,'Style','text','units','normalized','FontUnits','Normalized','FontSize',0.5,'position',[0.81 0.55 .18 0.05],'string','Z-Axis','BackgroundColor',bgc); %#ok
            
            axisH = axes('Units','Normalized','outerPosition',[0.05 0.05 0.75 0.9]);
            
            % Setup the PopOut Option
            hcmenu = uicontextmenu;
            hcmenuPopoutItem = uimenu(hcmenu, 'Label', 'Popout', 'Callback', @explorerPopOut); %#ok
            set(axisH,'UIContextMenu',hcmenu);
            
            if obj.nDimensions > 1
                plotDims = [1 2 0];
                
                set(popX,'value',1); % Becase we have dont have a none;
                set(popY,'value',2); % Becase we have dont have a none;
                set(popZ,'value',1); % Becase we have a none;
            else
                plotDims = [1 1 0];
                
                set(popX,'value',1); % Becase we have dont hvae a none;
                set(popY,'value',1); % Becase we have a none;
                set(popZ,'value',1); % Becase we have a none;
            end
            updatePlot;
            
            function plotSelectPopupCallback(myHandle, eventData, varargin) %#ok
                cVal = get(myHandle,'value');
                axisInd = varargin{1};
                if axisInd == 3
                    % Z-axis we have a None option
                    cVal = cVal - 1;
                end
                plotDims(axisInd) = cVal;
                updatePlot;
            end
            
            function updatePlot
                actualPlotDims = plotDims(plotDims>=1);
                axes(axisH); %#ok
                plot(obj,actualPlotDims)
            end
            function explorerPopOut(myHandle,eventData) %#ok
                figure
                actualPlotDims = plotDims(plotDims>=1);
                plot(obj,actualPlotDims);
            end
        end
    end
end
