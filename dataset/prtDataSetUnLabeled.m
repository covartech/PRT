classdef prtDataSetUnLabeled < prtDataSetBase
    
    properties (Dependent = true)
        %required by prtDataSet:
        nDimensions
        nObservations
    end
    
    properties %(Access = 'private') %Needed externally in classifier\plot
        colorsFunction = @(n)dprtClassColors(n,[0 0 0]);
        symbolsFunction = @dprtClassSymbols;
    end
    
    properties (SetAccess = 'private')
        %required by prtDataSet:
        dataSetName = ''      % char
        featureNames  = {}    % strcell, 1 x nDimensions
        observationNames = {} % strcell, nObservations x 1
        data = []             % matrix, doubles, features
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function prtDataSet = prtDataSetUnLabeled(varargin)
            % prtDataSet = prtDataSetUnLabeled
            % prtDataSet = prtDataSetUnLabeled(data)
            % prtDataSet = prtDataSetUnLabeled(data, paramName1, paramVal1, ...)
            
            if nargin == 0 % Empty constructor
                % Nothing to do
                return
            end
            
            % Check if we are supplying a set of data sets to join
            if all(cellfun(@(c)isa(c,'prtDataSetUnLabeled'),varargin)) || all(cellfun(@(c)isa(c,'prtDataSetLabeled'),varargin))
                prtDataSet = varargin{1};
                if isa(varargin{1},'prtDataSetLabeled')
                    prtDataSet = prtDataSetUnLabeled(prtDataSet.data);
                end
                for i = 2:length(varargin)
                    prtDataSet = prtDataSetUnLabeled(prtDataSet,'data',cat(2,prtDataSet.data,varargin{i}.data));
                end
                return
            end
            
            if isa(varargin{1},'prtDataSetUnLabeled')
                prtDataSet = varargin{1};
                varargin = varargin(2:end);
            else
                prtDataSet.data = varargin{1};
                varargin = varargin(2:end);
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
                error('prt:prtDataSetUnLabeled:invalidInputs','additional input arguments must be specified as parameter string, value pairs.')
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
                error('prt:prtDataSetUnLabeled:invalidData','data must be a 2-Dimensional double array');
            end
            obj.data = data;
        end
        function obj = set.featureNames(obj, featureNames)
            if size(featureNames(:),1) ~= obj.nDimensions
                error('prt:prtDataSetUnLabeled:dataFeaturesMismatch','obj.nDimensions (%d) must match size(featureNames(:),1) (%d)',obj.nDimensions,size(featureNames,2));
            end
            obj.featureNames = featureNames(:);
        end
        function obj = set.dataSetName(obj, dataSetName)
            if ~isa(dataSetName,'char');
                error('prt:prtDataSetUnLabeled:dataSetNameNonString','dataSetName is a (%s), but dataSetName must be a character array',class(dataSetName));
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Other Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = addObservations(obj, newData, newObsNames)
            if nargin < 3
                newObsNames = {};
            else
                if ~iscellstr(newObsNames)
                    error('prt:prtDataSetUnLabeled:incorrectInput','newObsNames, must be a cellstr.');
                end
                if size(newObsNames,1) ~= size(newData,1)
                    error('prt:prtDataSetUnLabeled:incorrectInput','The number of observations in the new data and the new observation names do not match.');
                end
            end
            
            if size(newData,2) ~= obj.nDimensions
                error('prt:prtDataSetUnLabeled:incorrectDimensionality','The dimensionality of the specified data (%d) does not match the dimensionality of this dataset (%d).', size(newData,2), obj.nDimensions);
            end
            
            oldNObs = obj.nObservations;
            
            % Cat the data and labels
            obj.data = cat(1,obj.data, newData);
            
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
        
        function varargout = plot(obj, featureIndices)
            
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
            
            % Preserve the hold state of the figure
            holdState = ishold;
            
            handleArray = 0;
            
            legendStrings = {'unlabeled'};

            % Un-labeled data set
            classColors = obj.colorsFunction(1);
            classSymbols = obj.symbolsFunction(1);
            cEdgeColor = min(classColors + 0.2,[0.8 0.8 0.8]);
            cX = obj.data;
            
            switch obj.nDimensions
                case 0
                    %empty;
                    varargout = {};
                    if nargout > 0
                        varargout = {[],{}};
                    end
                    return;
                case 1
                    handleArray = plot(cX,ones(size(cX)),classSymbols,'MarkerFaceColor',classColors,'MarkerEdgeColor',cEdgeColor,'linewidth',0.1);
                    xlabel(getFeatureNames(obj,featureIndicies(1)));
                case 2
                    handleArray = plot(cX(:,1),cX(:,2),classSymbols,'MarkerFaceColor',classColors,'MarkerEdgeColor',cEdgeColor,'linewidth',0.1);
                    xlabel(getFeatureNames(obj,featureIndicies(1)));
                    ylabel(getFeatureNames(obj,featureIndicies(2)));
                case 3
                    handleArray = plot3(cX(:,1),cX(:,2),cX(:,3),classSymbols,'MarkerFaceColor',classColors,'MarkerEdgeColor',cEdgeColor,'linewidth',0.1);
                    xlabel(getFeatureNames(obj,featureIndicies(1)));
                    ylabel(getFeatureNames(obj,featureIndicies(2)));
                    zlabel(getFeatureNames(obj,featureIndicies(3)));
                    grid on;
                otherwise
                    error('NDIMS (%d) > 3',size(cX,2));
            end
            
            title(obj.dataSetName);
            if holdState
                hold on;
            else
                hold off;
            end
            legend(handleArray,legendStrings,4);
            
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