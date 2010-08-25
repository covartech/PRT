classdef prtDataSetBase
    % prtDataSetBase    Base class for all prt data sets.
    %
    % This is an abstract class from which all prt data sets inherit from.
    % It can not be instantiated. It contains the following properties:
    %
    %   name           - Data set descriptive name
    %   description    - Description of the data set
    %   UserData       - Structure for holding additional related to the
    %                    data set
    %   ActionData     - Structure for prtActions to place additional data
    %
    %   ObservationDependentUserData - Structure array holding additional
    %                                  data per related to each observation
    %
    %   nObservations     - Number of observations in the data set
    %   nTargetDimensions - Number of target dimensions
    %   isLabeled         - Whether or not the data set is labeled
    %
    % The prtDataSetBase class has the following methods
    %
    %   getObservationNames - get the observation names
    %   setObservationNames - set the observation names
    %
    %   getTargetNames      - get the target names
    %   setTargetNames      - set the target names
    %
    %   getX - Shortcut for getObservations
    %   setX - Shortcut for setObservations
    %   getY - Shortcut for getTargets
    %   setY - Shortcut for setTargets
    %
    %   setXY - Shortcut for setObservationsAndTargets
    %
    % The prtDataSetBase class also specifies the following abstract
    % functions, which are implemented by all derived classes:
    %
    %   getObservations - Return an array of observations
    %   setObservations - Set the array of observations
    %
    %   getTargets - Return an array of targets (empty if unlabeled)
    %   setTargets - Set the array of targets
    %
    %   setObservationsAndTargets - Set the array of observations and
    %                               targets
    %   catFeatures               - Combine the features from a data set
    %                               with another data set
    %   catObservations           - Combine the Observations from a data
    %                               set with another data set
    %   catTargets                - Combine the targets from a data set
    %                               with another data set
    %   removeObservations        - Remove observations from a data set
    %   retainObservations        - Retain observatons (remove all others)
    %                               from a data set
    %
    %   removeTargets - Remove columns of targets from a data set
    %   retainTargets - Retain columns of targets from a data set
    %
    %   export -
    %   plot -
    %   summarize -
    
    properties (Abstract, Dependent)
        nObservations         % The number of observations
        nTargetDimensions     % The number of target dimensions
    end
    properties (Dependent)
        isLabeled           % Whether or not the data has target labels
    end
    
    properties  %public, for now
        name = ''             % A string naming the data set
        description = ''      % A string with a verbose description of the data set
        UserData = struct;         % Additional data per data set
        ActionData = struct;      %Will someone please explain to me ActionData XXXX
    end
    
    properties (Dependent, Hidden)
        % Additional properties for plotting
        plottingColors
        plottingSymbols
    end
    
    % Only prtDataSetBase knows about these, use getObs... and getFeat.. to
    % get and set these, they handle the dirty stuff
    properties (GetAccess = 'protected',SetAccess = 'protected')
        observationNames    % The observations names
        targetNames         % The target names.
    end
    
    methods
        function isLabeled = get.isLabeled(obj)
            isLabeled = ~isempty(obj.getY);
        end
    end
    
    %Replace this with an object! prtDataPlottingOptions object?
    methods
        function colors = get.plottingColors(obj)
            colors = prtPlotUtilClassColors(obj.nClasses);
        end
        function symbols = get.plottingSymbols(obj)
            symbols = prtPlotUtilClassSymbols(obj.nClasses);
        end
    end
    
    %Wrappers - getX, setX, getY, setY
    methods
        function [observations,targets] = getXY(obj,varargin)
            % getXY  Shortcut for getObservationsAndTargets
            observations = obj.getObservations(varargin{:});
            targets = obj.getTargets(varargin{:});
        end
        function observations = getX(obj,varargin)
            % getX Shortcut for GetObservations
            observations = obj.getObservations(varargin{:});
        end
        function targets = getY(obj,varargin)
            % getY Shortcut for getTargets
            targets = obj.getTargets(varargin{:});
        end
        function obj = setXY(obj,varargin)
            % setXY Shortcut for setObservationsAndTargets
            obj = obj.setObservationsAndTargets(varargin{:});
        end
        function obj = setX(obj,varargin)
            % setX Shortcut for setObservations
            obj = obj.setObservations(varargin{:});
        end
        function obj = setY(obj,varargin)
            % setY Shortcut for setTargets
            obj = obj.setTargets(varargin{:});
        end
    end
    
    %Methods for setting name, description
    methods
        function obj = set.name(obj, newName)
            if ~isa(newName,'char');
                error('prt:prtDataSetBase:dataSetNameNonString','name must but name must be a character array');
            end
            obj.name = newName;
        end
        function obj = set.description(obj, newDescr)
            if ~isa(newDescr,'char');
                error('prt:prtDataSetBase:dataSetNameNonString','description must be a character array');
            end
            obj.description = newDescr;
        end
    end
    
    %Methods for get, set, ObservationNames and FeatureNames
    methods
        function obj = prtDataSetBase
            obj.observationNames = java.util.Hashtable;
            obj.targetNames = java.util.Hashtable;
        end
        
        function obsNames = getObservationNames(obj,varargin)
            % getObservationNames - Return DataSet's Observation Names
            %
            %   featNames = getObservationNames(obj) Return a cell array of
            %   an object's observation names; if setObservationNames has not been
            %   called or the 'observationNames' field was not set at construction,
            %   default behavior is to return sprintf('Observation %d',i) for all
            %   observations.
            %
            %   featNames = getObservationNames(obj,indices) Return the observation
            %   names for only the specified indices.
            
            indices1 = prtDataSetBase.parseIndices(obj.nObservations,varargin{:});
            %parse returns logicals
            if islogical(indices1)
                indices1 = find(indices1);
            end
            
            obsNames = cell(length(indices1),1);
            
            for i = 1:length(indices1)
                obsNames{i} = obj.observationNames.get(indices1(i));
                if isempty(obsNames{i})
                    obsNames(i) = prtDataSetBase.generateDefaultObservationNames(indices1(i));
                end
            end
        end
        
        function targetNames = getTargetNames(obj,varargin)
            % getTargetNames  Return the target names of a dataset
            %
            
            indices2 = prtDataSetBase.parseIndices(obj.nTargetDimensions,varargin{:});
            %parse returns logicals
            if islogical(indices2)
                indices2 = find(indices2);
            end
            
            targetNames = cell(length(indices2),1);
            
            for i = 1:length(indices2)
                targetNames{i} = obj.targetNames.get(indices2(i));
                if isempty(targetNames{i})
                    targetNames(i) = prtDataSetBase.generateDefaultTargetNames(indices2(i));
                end
            end
        end
        
        function obj = setObservationNames(obj,obsNames,varargin)
            % setObservationNames  Set the observation names of a data set
            %
            %  dataSet = dataSet.setObservationNames(NAMES) Set an object's
            %  observation names to NAMES.
            %
            %  dataSet = dataSet.setObservationNames(NAMES, INDICES) Set the observation
            %  names for only the specified INDICES.
            
            if ~isvector(obsNames)
                error('setObservationNames requires vector NAMES');
            end
            if ~iscell(obsNames)
                obsNames = {obsNames};
            end
            
            indices1 = prtDataSetBase.parseIndices(obj.nObservations,varargin{:});
            %parse returns logicals; find the indices
            if islogical(indices1)
                indices1 = find(indices1);
            end
            
            for i = 1:length(indices1)
                obj.observationNames.put(indices1(i),obsNames{i});
            end
        end
        
        function obj = setTargetNames(obj,targetNames,varargin)
            % setTargetNames  Set the data set target names
            %
            %  dataSet = dataSet.setTargetNames(NAMES) Set an object's
            %  target names to NAMES.
            %
            %  dataSet = dataSet.setTargetNames(NAMES, INDICES) Set the
            %  target names for only the specified INDICES.
                        
            indices2 = prtDataSetBase.parseIndices(obj.nTargetDimensions,varargin{:});
            %parse returns logicals
            if islogical(indices2)
                indices2 = find(indices2);
            end
            if length(targetNames) ~= length(indices2)
                if nargin == 2
                    error('prt:prtDataSetStandard','Attempt to set target names for different number of targets (%d) than data set has (%d)',length(targetNames),length(max(indices2)));
                else
                    error('prt:prtDataSetStandard','Too many indices (%d) provided for number of target names provited (%d)',length(indices2),length(targetNames));
                end
            end
            %Put the default string names in there; otherwise we might end
            %up with empty elements in the cell array
            for i = 1:length(indices2)
                obj.targetNames.put(indices2(i),targetNames{i});
            end
        end
    end
    
    %isEmpty and size
    %     methods
    %         function bool = isempty(obj)
    %             bool = obj.nObservations == 0 || obj.nFeatures == 0;
    %         end
    %
    %         function s = size(obj)
    %             s = [obj.nObservations,obj.nFeatures];
    %         end
    %
    %     end
    
    
    %Private static functions for generating feature and observation names
    methods (Access = 'protected', Static = true, Hidden = true)
        function featNames = generateDefaultFeatureNames(indices2)
            featNames = prtUtilCellPrintf('Feature %d',num2cell(indices2));
            featNames = featNames(:);
        end
        function obsNames = generateDefaultObservationNames(indices2)
            obsNames = prtUtilCellPrintf('Observation %d',num2cell(indices2));
            obsNames = obsNames(:);
        end
        function targNames = generateDefaultTargetNames(indices2)
            targNames = prtUtilCellPrintf('Target %d',num2cell(indices2));
            targNames = targNames(:);
        end
    end
    
    %Protected static functions for modifying edge colors from face colors
    %should be elsewhere
    methods (Access = 'protected', Static = true, Hidden = true)
        function color = edgeColorMod(classColors)
            color = min(classColors + 0.2,[0.8 0.8 0.8]);
        end
        
        function checkIndices(sz,varargin)
            
            nDims = numel(sz);
            if nDims ~= length(varargin)
                error('prt:prtDataSetStandard:invalidIndices','Specified indicies do not match te referenced dimensionality');
            end
            
            
            for iDim = 1:nDims
                cIndices = varargin{iDim};
                
                % No matter how you slize it the indices must be a vector
                if ~isvector(cIndices)
                    error('prt:prtDataSetStandard:invalidIndices','Indices must be a vector');
                end
                
                if islogical(cIndices)
                    if numel(cIndices) ~= sz(iDim)
                        error('prt:prtDataSetStandard:indexOutOfRange','Index size (%d) does not match the size of the reference (%d).',numel(cIndices),sz(iDim));
                    end
                else
                    % Numeric (ie integer) referencing
                    if any(cIndices < 1)
                        error('prt:prtDataSetStandard:indexOutOfRange','Some index elements (%d) are less than 1',min(cIndices));
                    end
                    
                    if any(cIndices > sz(iDim))
                        error('prt:prtDataSetStandard:indexOutOfRange','Some index elements out of range (%d > %d)',max(cIndices),sz(iDim));
                    end
                end
            end
            
        end
        
        function varargout = parseIndices(sz, varargin)
            
            nDims = numel(sz);
            indicesCell = cell(nDims,1);
            for iDim = 1:nDims
                if iDim > length(varargin)
                    indicesCell{iDim} = true(sz(iDim),1);
                else
                    indicesCell{iDim} = varargin{iDim};
                end
                
                if strcmpi(indicesCell{iDim},':')
                    indicesCell{iDim} = true(sz(iDim),1);
                end
            end
            
            prtDataSetBase.checkIndices(sz,indicesCell{:});
            
            varargout = indicesCell;
        end
        
    end
    
    %I don't think we need these anymore - addFeatureNames and
    %addObservationNames...  we may need "remove feature names" and "remove
    %Observation Names"
    methods (Access = 'protected', Hidden = true)
        function obj = catObservationNames(obj,newDataSet)
            
            for i = 1:newDataSet.nObservations;
                currObsName = newDataSet.observationNames.get(i);
                if ~isempty(currObsName)
                    obj.observationNames.put(i + obj.nObservations,currObsName);
                end
            end
        end
        
        %   Note: only call this from within retainObservations
        function obj = retainObservationNames(obj,varargin)
            
            
            retainIndices = prtDataSetBase.parseIndices(obj.nObservations,varargin{:});
            %parse returns logicals
            if islogical(retainIndices)
                retainIndices = find(retainIndices);
            end
            if isempty(obj.observationNames)
                return;
            else
                %copy the hash with new indices
                newHash = java.util.Hashtable;
                for retainInd = 1:length(retainIndices);
                    if obj.observationNames.containsKey(retainIndices(retainInd));
                        newHash.put(retainInd,obj.observationNames.get(retainIndices(retainInd)));
                    end
                end
                obj.observationNames = newHash;
            end
        end
        
        %obj = catTargetNames(obj,newDataSet)
        function obj = catTargetNames(obj,newDataSet)
            
            for i = 1:newDataSet.nTargetDimensions;
                currTargetName = newDataSet.targetNames.get(i);
                if ~isempty(currTargetName)
                    obj.targetNames.put(i + obj.nTargetDimensions,currTargetName);
                end
            end
        end
 
        % Only call from retain tartets
        function obj = retainTargetNames(obj,varargin)
            
            retainIndices = prtDataSetBase.parseIndices(obj.nTargetDimensions,varargin{:});
            %parse returns logicals
            if islogical(retainIndices)
                retainIndices = find(retainIndices);
            end
            if isempty(obj.targetNames)
                return;
            else
                %copy the hash with new indices
                newHash = java.util.Hashtable;
                for retainInd = 1:length(retainIndices);
                    if obj.targetNames.containsKey(retainIndices(retainInd));
                        newHash.put(retainInd,obj.targetNames.get(retainIndices(retainInd)));
                    end
                end
                obj.targetNames = newHash;
            end
        end
        
    end
    
    %Static plotting aid functions - plotPoints, plotLines, makeExploreGui
    methods (Access = 'protected',Static = true, Hidden  = true)
        function h = plotPoints(cX,featureNames,classSymbols,classColors,classEdgeColor,linewidth)
            nPlotDimensions = size(cX,2);
            if nPlotDimensions < 1
                warning('prt:plot:NoPlotDimensionality','No plot dimensions requested.');
                return
            end
            if nPlotDimensions > 3
                error('prt:plot:plotDimensionality','The number of requested plot dimensions (%d) is greater than 3. You may want to use explore() to selet and visualize a subset of the features.',nPlotDimensions);
            end
            
            switch nPlotDimensions
                case 1
                    h = plot(cX,ones(size(cX)),classSymbols,'MarkerFaceColor',classColors,'MarkerEdgeColor',classEdgeColor,'linewidth',linewidth);
                    xlabel(featureNames{1});
                    grid on
                case 2
                    h = plot(cX(:,1),cX(:,2),classSymbols,'MarkerFaceColor',classColors,'MarkerEdgeColor',classEdgeColor,'linewidth',linewidth);
                    xlabel(featureNames{1});
                    ylabel(featureNames{2});
                    grid on
                case 3
                    h = plot3(cX(:,1),cX(:,2),cX(:,3),classSymbols,'MarkerFaceColor',classColors,'MarkerEdgeColor',classEdgeColor,'linewidth',linewidth);
                    xlabel(featureNames{1});
                    ylabel(featureNames{2});
                    zlabel(featureNames{3});
                    grid on;
            end
        end
        
        function h = plotLines(xInd,cY,linecolor,linewidth)
            h = plot(xInd,cY,'color',linecolor,'linewidth',linewidth);
        end

       % Get the window position and pick/set a figure size.
        function makeExploreGui(theObject,theFeatures)
            ss = get(0,'screensize');
            
            windowSize = [754 600];
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
            
            popUpStrs = theFeatures;
            
            bgc = get(figH,'Color');
            popX = uicontrol(figH,'Style','popup','units','normalized','FontUnits','Normalized','FontSize',0.6,'position',[0.15 0.01 0.19 0.04],'string',popUpStrs,'callback',{@plotSelectPopupCallback 1});
            popXHead = uicontrol(figH,'Style','text','units','normalized','FontUnits','Normalized','FontSize',0.75,'position',[0.05 0.01 0.09 0.04],'string','X-Axis:','BackgroundColor',bgc,'HorizontalAlignment','Right'); %#ok
            
            popY = uicontrol(figH,'Style','popup','units','normalized','FontUnits','Normalized','FontSize',0.6,'position',[0.45 0.01 0.19 0.04],'string',popUpStrs,'callback',{@plotSelectPopupCallback 2});
            popYHead = uicontrol(figH,'Style','text','units','normalized','FontUnits','Normalized','FontSize',0.75,'position',[0.35 0.01 0.09 0.04],'string','Y-Axis:','BackgroundColor',bgc,'HorizontalAlignment','Right'); %#ok
            
            popZ = uicontrol(figH,'Style','popup','units','normalized','FontUnits','Normalized','FontSize',0.6,'position',[0.75 0.01 0.19 0.04],'string',[{'None'}; popUpStrs],'callback',{@plotSelectPopupCallback 3});
            popZHead = uicontrol(figH,'Style','text','units','normalized','FontUnits','Normalized','FontSize',0.75,'position',[0.65 0.01 0.09 0.04],'string','Z-Axis:','BackgroundColor',bgc,'HorizontalAlignment','Right'); %#ok
            
            axisH = axes('Units','Normalized','outerPosition',[0.05 0.07 0.9 0.9]);
            
            % Setup the PopOut Option
            hcmenu = uicontextmenu;
            hcmenuPopoutItem = uimenu(hcmenu, 'Label', 'Popout', 'Callback', @explorerPopOut); %#ok
            set(axisH,'UIContextMenu',hcmenu);
            
            if theObject.nFeatures > 1
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
                plot(theObject,actualPlotDims)
            end
            function explorerPopOut(myHandle,eventData) %#ok
                figure;
                actualPlotDims = plotDims(plotDims>=1);
                plot(theObject,actualPlotDims);
            end
        end
    end
    
    methods (Abstract)
        %all sub-classes must define these behaviors, this is the contract
        %that all "data sets" must follow
        
        %Return the data by indices
        data = getObservations(obj,indices1,indices2)
        targets = getTargets(obj,indices1,indices2)
        [data,targets] = getObservationsAndTargets(obj,indices1,indices2)
        
        
        obj = setObservations(obj,data,indices1,indices2)
        obj = setTargets(obj,targets,indices)
        obj = setObservationsAndTargets(obj,data,targets)
        
        obj = removeObservations(obj,indices)
        obj = removeTargets(obj,indices)
        
        obj = retainObservations(obj,indices)
        obj = retainTargets(obj,indices)
        
        obj = catObservations(obj,dataSet)
        obj = catTargets(obj,dataSet)
        
        handles = plot(obj)
        export(obj,prtExportObject)
        Summary = summarize(obj)
        
    end
end
