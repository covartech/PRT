classdef prtDataSetInMemoryTemp < prtDataSetBase
    
    properties %public... for now... this is controversial :)
        data = [];            % matrix, doubles, features
        targets = [];         % matrix, doubles, targets, for unlabeled data sets, just ignore(?)
    end
    
    methods
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = prtDataSetInMemoryTemp(varargin)
            % Nothing to do.
            % This should only be called when initializing a sub-class
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Set Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % These just provide sanity error checking
        function obj = set.data(obj, data)
            if ~isa(data,'double') || ndims(data) ~= 2
                error('prt:prtDataSetLabeled:invalidData','data must be a 2-Dimensional double array');
            end
            obj.data = data;
        end
        function data = get.data(obj)
            data = obj.data;
        end
        function obj = set.targets(obj, targets)
            if ~isa(targets,'double') || ndims(targets) ~= 2
                error('prt:prtDataSetLabeled:invalidData','targets must be a 2-Dimensional double array');
            end
            obj.targets = targets;
        end
        function targets = get.targets(obj)
            targets = obj.targets;
        end
    end
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %% Other Get Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         function featureNames = get.featureNames(obj)
%             % We choose not to generate the default names here to save
%             % time. Because the GetAccess is protected we generate these in
%             % getFeatureNames(). This means internally or in sub-classes
%             % you will sometimes get an {} if nothing has been set whereas 
%             % getFeatureNames() will generate the default feature names.
%             featureNames = obj.featureNames;
%         end
%         function obsNames = get.observationNames(obj)
%             % We choose not to generate the default names here to save
%             % time. Because the GetAccess is protected we generate these in
%             % getObservationsNames(). This means internally or in
%             % sub-classes you will sometimes get an {} if nothing has been
%             % set whereas getObservationNames() will generate the default
%             % observation names.
%             obsNames = obj.observationNames;
%         end
%         function name = get.name(obj)
%             if isempty(obj.name)
%                 name = 'Unnamed';
%             else
%                 name = obj.name;
%             end
%         end
%         
% %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %         %% Other Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %         function obj = catFeatures(obj, newData, newFeatureNames)
% %             if nargin < 2
% %                 newFeatureNames = {};
%             else
%                 if ~iscellstr(newFeatureNames)
%                     error('prt:prtDataSetInMemory:incorrectInput','newFeatureNames, must be a cellstr.');
%                 end
%                 if length(newFeatureNames) ~= size(newData,2)
%                     error('prt:prtDataSetInMemory:incorrectInput','The number of observations in the new data and the new observation names do not match.');
%                 end
%             end
%             
%             % We need this in the event that we need to develop
%             % featureNames
%             oldNDims = obj.nFeatures;
%             
%             % Cat the data and labels
%             obj.data = cat(2,obj.data, newData);
%             
%             if ~isempty(obj.featureNames)
%                 if isempty(newFeatureNames)
%                     % Generate default
%                     newFeatureNames = cell(1,size(newData,2));
%                     for i = 1:length(indices)
%                         newFeatureNames{i,1} = sprintf('Feature %d',i+oldNDims);
%                     end
%                 else
%                     obj.featureNames = cat(2,obj.getFeatureNames, newFeatureNames(:)');
%                 end
%             end
%         end
%         function obj = catObservations(obj, newData, newObsNames)
%             if nargin < 3
%                 newObsNames = {};
%             else
%                 if ~iscellstr(newObsNames)
%                     error('prt:prtDataSetInMemory:incorrectInput','newObsNames, must be a cellstr.');
%                 end
%                 if length(newObsNames) ~= size(newData,1)
%                     error('prt:prtDataSetInMemory:incorrectInput','The number of observations in the new data and the new observation names do not match.');
%                 end
%             end
%             
%             if size(newData,2) ~= obj.nFeatures
%                 error('prt:prtDataSetInMemory:incorrectDimensionality','The dimensionality of the specified data (%d) does not match the dimensionality of this dataset (%d).', size(newData,2), obj.nFeatures);
%             end
%             
%             % We need this in the event that we need to develop
%             % observations
%             oldNObs = obj.nObservations;
%             
%             % Cat the data and labels
%             obj.data = cat(1,obj.data, newData);
%             
%             if ~isempty(obj.observationNames)
%                 if isempty(newObsNames)
%                     % Generate default
%                     newObsNames = cell(size(newData,1),1);
%                     for i = 1:length(indices)
%                         newObsNames{i,1} = sprintf('Observation %d',i+oldNObs);
%                     end
%                 else
%                     obj.observationNames = cat(1,obj.getObservationNames, newObsNames(:));
%                 end
%             end
%         end
%         function obj = joinFeatures(obj, varargin)
%             for iCat = 1:length(varargin)
%                 obj = catFeatures(obj, varargin{iCat}.getObservations, varargin{iCat}.getFeatureNames);
%             end
%         end
%         function obj = joinObservations(obj, varargin)
%             for iCat = 1:length(varargin)
%                 obj = catObservations(obj, varargin{iCat}.getObservations, varargin{iCat}.getObservationNames);
%             end
%         end
%         function n = size(obj)
%             n = [obj.nObservations obj.nFeatures];
%         end
%         function b = isempty(obj)
%             b = isempty(obj.data);
%         end
%         function disp(obj)
%             display(obj)
%         end
%         function display(obj)
%             isCompact = strcmp(get(0,'FormatSpacing'),'compact');
%             
%             if ~isCompact
%                 fprintf('\n');
%             end
%             fprintf('%s =\n',inputname(1));
%             if ~isCompact
%                 fprintf('\n');
%             end
%             fprintf('\t%s\n',class(obj))
%             % Convert stuff we want to be displayed into a struct and use
%             % the struct display function
%             display(struct('name',obj.name,'description',obj.description,'nObservations',obj.nObservations,'nFeatures',obj.nFeatures,'UserData',obj.UserData))
%             
%             if ~isCompact
%                 fprintf('\n')
%             end
%         end
%         function export(obj,varargin)
%             error('Not Done Yet');
%         end
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %% Plotting Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         function varargout = plot(obj, featureIndices)
%             if nargin < 2 || isempty(featureIndices)
%                 featureIndices = 1:obj.nFeatures;
%             end
%             if islogical(featureIndices)
%                 featureIndices = find(featureIndices);
%             end
%             
%             nPlotDimensions = length(featureIndices);
%             if nPlotDimensions < 1
%                 warning('prt:plot:NoPlotDimensionality','No plot dimensions requested.');
%                 return
%             end
%             if nPlotDimensions > 3
%                 error('prt:plot:plotDimensionality','The number of requested plot dimensions (%d) is greater than 3. You may want to use explore() to selet and visualize a subset of the features.',nPlotDimensions);
%             end
%             if max(featureIndices) > obj.nFeatures
%                 error('prt:plot:plotDimensionality','A requested plot dimensions (%d) exceeds the dimensionality of the data set (%d).',max(featureIndices),obj.nFeatures);
%             end
%             
%             % Preserve the hold state of the figure
%             holdState = ishold;
%             
%             % This is a little weird. But it prevents us from duplicating
%             % this code so ...
%             % Get colors and symbols from the colors and symbols functions
%             isLabeled = ismethod(obj,'getTargets');
%             if isLabeled
%                 nClasses = obj.nUniqueTargets;
%                 classColors = obj.plottingColors;
%                 classSymbols = obj.plottingSymbols;
%             else
%                 nClasses = 1;
%                 classColors = prtPlotUtilClassColors(1);
%                 classSymbols = prtPlotUtilClassSymbols(1);
%             end
%             
%             
%             handleArray = zeros(nClasses,1);
%             % Loop through classes and plot
%             for i = 1:nClasses
%                 if isLabeled
%                     cX = obj.getObservationsByUniqueTargetInd(i, featureIndices);
%                 else
%                     cX = obj.getObservations([], featureIndices);
%                 end
%                 
%                 
%                 cEdgeColor = min(classColors(i,:) + 0.2,[0.8 0.8 0.8]);
%                 
%                 switch nPlotDimensions
%                     case 1
%                         handleArray(i) = plot(cX,ones(size(cX)),classSymbols(i),'MarkerFaceColor',classColors(i,:),'MarkerEdgeColor',cEdgeColor,'linewidth',0.1);
%                         xlabel(getFeatureNames(obj,featureIndices(1)));
%                         grid on
%                     case 2
%                         handleArray(i) = plot(cX(:,1),cX(:,2),classSymbols(i),'MarkerFaceColor',classColors(i,:),'MarkerEdgeColor',cEdgeColor,'linewidth',0.1);
%                         xlabel(getFeatureNames(obj,featureIndices(1)));
%                         ylabel(getFeatureNames(obj,featureIndices(2)));
%                         grid on
%                     case 3
%                         handleArray(i) = plot3(cX(:,1),cX(:,2),cX(:,3),classSymbols(i),'MarkerFaceColor',classColors(i,:),'MarkerEdgeColor',cEdgeColor,'linewidth',0.1);
%                         xlabel(getFeatureNames(obj,featureIndices(1)));
%                         ylabel(getFeatureNames(obj,featureIndices(2)));
%                         zlabel(getFeatureNames(obj,featureIndices(3)));
%                         grid on;
%                 end
%                 if i == 1
%                     hold on;
%                 end
%             end
%             
%             % Set title
%             title(obj.name);
%             
%             % Set hold state back to the way it was
%             if holdState
%                 hold on;
%             else
%                 hold off;
%             end
%             
%             % Create legend
%             if isLabeled
%                 legendStrings = getUniqueTargetNames(obj);
%                 legend(handleArray,legendStrings,'Location','SouthEast');
%             end
%             
%             % Handle Outputs
%             varargout = {};
%             if nargout > 0
%                 varargout = {handleArray,legendStrings};
%             end
%         end
%         function explore(obj)
%             % Get the window position and pick/set a figure size.
%             ss = get(0,'screensize');
%             
%             windowSize = [754 600];
%             % Center the window
%             sizePads = round((ss(3:4)-windowSize));
%             sizePads(1) = sizePads(1)/2; % We should use 2 right?
%             sizePads(2) = sizePads(2)/2;
%             pos = cat(2,sizePads,windowSize);
%             
%             % Create the figure an UIControls
%             figH = figure('Number','Off','Name','PRT Data Set Explorer','Menu','none','toolbar','figure','units','pixels','position',pos,'DockControls','off');
%             
%             % Trim the toolbar down to just the zooming controls
%             Toolbar.handle = findall(figH,'Type','uitoolbar');
%             Toolbar.Children = findall(figH,'Parent',Toolbar.handle,'HandleVisibility','off');
%             
%             % Delete a bunch of things we dont need
%             delete(findobj(Toolbar.Children,'TooltipString','New Figure',...
%                 '-or','TooltipString','Open File','-or','TooltipString','Save Figure',...
%                 '-or','TooltipString','Print Figure','-or','TooltipString','Edit Plot',...
%                 '-or','TooltipString','Data Cursor','-or','TooltipString','Brush/Select Data',...
%                 '-or','TooltipString','Link Plot','-or','TooltipString','Insert Colorbar',...
%                 '-or','TooltipString','Insert Legend','-or','TooltipString','Show Plot Tools and Dock Figure',...
%                 '-or','TooltipString','Hide Plot Tools'))
%             
%             popUpStrs = getFeatureNames(obj);
%             
%             bgc = get(figH,'Color');
%             popX = uicontrol(figH,'Style','popup','units','normalized','FontUnits','Normalized','FontSize',0.6,'position',[0.15 0.01 0.19 0.04],'string',popUpStrs,'callback',{@plotSelectPopupCallback 1});
%             popXHead = uicontrol(figH,'Style','text','units','normalized','FontUnits','Normalized','FontSize',0.75,'position',[0.05 0.01 0.09 0.04],'string','X-Axis:','BackgroundColor',bgc,'HorizontalAlignment','Right'); %#ok
%             
%             popY = uicontrol(figH,'Style','popup','units','normalized','FontUnits','Normalized','FontSize',0.6,'position',[0.45 0.01 0.19 0.04],'string',popUpStrs,'callback',{@plotSelectPopupCallback 2});
%             popYHead = uicontrol(figH,'Style','text','units','normalized','FontUnits','Normalized','FontSize',0.75,'position',[0.35 0.01 0.09 0.04],'string','Y-Axis:','BackgroundColor',bgc,'HorizontalAlignment','Right'); %#ok
%             
%             popZ = uicontrol(figH,'Style','popup','units','normalized','FontUnits','Normalized','FontSize',0.6,'position',[0.75 0.01 0.19 0.04],'string',[{'None'}; popUpStrs],'callback',{@plotSelectPopupCallback 3});
%             popZHead = uicontrol(figH,'Style','text','units','normalized','FontUnits','Normalized','FontSize',0.75,'position',[0.65 0.01 0.09 0.04],'string','Z-Axis:','BackgroundColor',bgc,'HorizontalAlignment','Right'); %#ok
%             
%             axisH = axes('Units','Normalized','outerPosition',[0.05 0.07 0.9 0.9]);
%             
%             % Setup the PopOut Option
%             hcmenu = uicontextmenu;
%             hcmenuPopoutItem = uimenu(hcmenu, 'Label', 'Popout', 'Callback', @explorerPopOut); %#ok
%             set(axisH,'UIContextMenu',hcmenu);
%             
%             if obj.nFeatures > 1
%                 plotDims = [1 2 0];
%                 
%                 set(popX,'value',1); % Becase we have dont have a none;
%                 set(popY,'value',2); % Becase we have dont have a none;
%                 set(popZ,'value',1); % Becase we have a none;
%             else
%                 plotDims = [1 1 0];
%                 
%                 set(popX,'value',1); % Becase we have dont hvae a none;
%                 set(popY,'value',1); % Becase we have a none;
%                 set(popZ,'value',1); % Becase we have a none;
%             end
%             updatePlot;
%             
%             function plotSelectPopupCallback(myHandle, eventData, varargin) %#ok
%                 cVal = get(myHandle,'value');
%                 axisInd = varargin{1};
%                 if axisInd == 3
%                     % Z-axis we have a None option
%                     cVal = cVal - 1;
%                 end
%                 plotDims(axisInd) = cVal;
%                 updatePlot;
%             end
%             
%             function updatePlot
%                 actualPlotDims = plotDims(plotDims>=1);
%                 axes(axisH); %#ok
%                 plot(obj,actualPlotDims)
%             end
%             function explorerPopOut(myHandle,eventData) %#ok
%                 figure
%                 actualPlotDims = plotDims(plotDims>=1);
%                 plot(obj,actualPlotDims);
%             end
%         end
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     end
end
