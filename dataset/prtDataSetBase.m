classdef prtDataSetBase
    % prtDataSetBase
    %   Base class for all prt DataSets.  
    %
    % prtDataSetBase Properties: 
    %   name - Data set descriptive name
    %   description - Description of the data set
    %   UserData - Structure for holding additional data
    %   ActionData - Structure for prtActions to place additional data
    %   ObservationDependentUserData - Structure array of size nObservations x 1
    %          to hold data-specific user data.  This array is split along
    %          with the data in cross-validation
    %
    % prtDataSetBase Properties (Dependent, Abstract)
    %   nObservations - Number of observations in the data set
    %   nFeatures - Dimensionality of the feature vectors
    %   nTargetDimensions - Dimensionality of the target vectors
    %
    % prtDataSetBase Properties (Dependent)
    %   isLabeled - returns isempty(obj.getY);
    %
    % prtDataSetBase Methods:
    %   getObservationNames - get the observation names
    %   setObservationNames - set the observation names
    %   getFeatureNames - get the feature names
    %   setFeatureNames - set the feature names
    %   
    %   getX - Wrapper for getObservations
    %   setX - Wrapper for setObservations
    %   getY - Wrapper for getTargets
    %   setY - Wrapper for setTargets
    %
    %  prtDataSetBase Methods: (Abstract)
    %   getObservations - Return an array of observations
    %   setObservations - Set the array of observations
    %
    %   getTargets - Return an array of targets (empty if unlabeled)
    %   setTargets - Set the array of targets
    %
    %   joinFeatures - Combine the features from two or more data sets
    %   joinObservations - Combine the observations from two or more data sets
    %
    %   catFeatures - Combine the features from a data set with additional data
    %   catObservations - Combine the Observations from a data set with additional data
    %
    %   removeObservations - Remove observations from a data set
    %   retainObservations - Retain observatons (remove all others) from a data set
    %   replaceObservations - Replace observatons in a data set
    %
    %   removeFeatures - Remove features from a data set
    %   retainFeatures - Remove features (remove all others) from a data set
    %   replaceFeatures - Replace features in a data set
    %
    %   export - 
    %   plot - 
    %   summarize - 
    
    properties (Abstract, Dependent)
        nObservations         % Abstract, implement as size(data,1)
        nFeatures             % Abstract, implement as size(data,2)
        nTargetDimensions     % Abstract, implement as size(targets,2)
    end
    properties (Dependent)
        isLabeled
    end
    
    properties  %public, for now
        name = ''             % char
        description = ''      % char
        UserData = struct;         % Additional data
        ActionData = struct;
    end
    
    properties (Dependent, Hidden)
        % Additional properties for plotting
        plottingColors
        plottingSymbols
    end
    
    % Only prtDataSetBase knows about these, use getObs... and getFeat.. to
    % get and set these, they handle the dirty stuff
    properties (GetAccess = 'protected',SetAccess = 'private')
        observationNames = java.util.Hashtable;
        featureNames = java.util.Hashtable;
        targetNames = java.util.Hashtable;
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
        function observations = getX(obj,varargin)
            observations = obj.getObservations(varargin{:});
        end
        function targets = getY(obj,varargin)
            targets = obj.getTargets(varargin{:});
        end
        function obj = setX(obj,varargin)
            obj = obj.setObservations(varargin{:});
        end
        function obj = setY(obj,varargin)
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
        function obsNames = getObservationNames(obj,indices1)
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
            
            if nargin == 1
                indices1 = (1:obj.nObservations)';
            end
            
            obsNames = cell(length(indices1),1);
            for i = 1:length(indices1)
                obsNames{indices1(i)} = obj.observationNames.get(indices1(i));
                if isempty(obsNames{indices1(i)})
                    obsNames{indices1(i)} = prtDataSetBase.generateDefaultObservationNames(indices1(i));
                end
            end
        end
        
        function obj = setObservationNames(obj,obsNames,indices1)
            % setObservationNames - Set DataSet's Observation Names
            %
            %  obj = setObservationNames(obj,obsNames) Set an object's 
            %   observation names.
            %   
            %  obj = setObservationNames(obj,obsNames,indices1) Return the observation
            %   names for only the specified indices.
            
            if ~isvector(obsNames)
                error('setObservationNames requires vector obsNames');
            end
            if ~iscell(obsNames)
                obsNames = {obsNames};
            end
            if nargin == 2
                if length(obsNames) ~= obj.nObservations
                    error('setObservationNames with one input requires length(obsNames) == obj.nObservations');
                end
                indices1 = (1:obj.nObservations)';
            end
            
            %Put the default string names in there; otherwise we might end
            %up with empty elements in the cell array 
            for i = 1:length(indices1)
                obj.observationNames.put(indices1(i),obsNames{i});
            end
        end
        
        function featNames = getFeatureNames(obj,indices2)
            % getFeatureNames - Return DataSet's Feature Names
            %
            %   featNames = getFeatureNames(obj) Return a cell array of 
            %   an object's feature names; if setFeatureNames has not been 
            %   called or the 'featureNames' field was not set at construction,
            %   default behavior is to return sprintf('Feature %d',i) for all
            %   features.
            %
            %   featNames = getFeatureNames(obj,indices) Return the feature
            %   names for only the specified indices.
            
            if nargin == 1
                indices2 = (1:obj.nFeatures)';
            end
            featNames = cell(length(indices2),1);
            for i = 1:length(indices2)
                featNames{indices2(i)} = obj.featureNames.get(indices2(i));
                if isempty(featNames{indices2(i)})
                    featNames(indices2(i)) = prtDataSetBase.generateDefaultFeatureNames(indices2(i));
                end
            end
        end
        
        function obj = setFeatureNames(obj,featNames,indices2)
            % setFeatureNames - Set DataSet's Feature Names
            %
            if ~isvector(featNames)
                error('setFeatureNames requires vector featNames');
            end
            if nargin == 2
                if length(featNames) ~= obj.nFeatures
                    error('setFeatureNames with one input requires length(featNames) == obj.nFeatures');
                end
                indices2 = (1:obj.nFeatures)';
            end
            
            %Put the default string names in there; otherwise we might end
            %up with empty elements in the cell array 
            for i = 1:length(indices2)
                obj.featureNames.put(indices2(i),featNames{i});
            end
        end
    end
    
    %isEmpty and size
    methods
        function bool = isempty(obj)
            bool = obj.nObservations == 0 || obj.nFeatures == 0;
        end
        
        function s = size(obj)
            s = [obj.nObservations,obj.nFeatures];
        end
        
    end

    %Private static functions for generating feature and observation names
    methods (Access = 'private', Static = true)
        function featNames = generateDefaultFeatureNames(indices2)
            featNames = prtUtilCellPrintf('Feature %d',num2cell(indices2));
            featNames = featNames(:);
        end
        function obsNames = generateDefaultObservationNames(indices2)
            obsNames = prtUtilCellPrintf('Observation %d',num2cell(indices2));
            obsNames = obsNames(:);
        end
    end
    
    %Protected static functions for modifying edge colors from face colors
    %should be elsewhere
    methods (Access = 'protected', Static = true)
        function color = edgeColorMod(classColors)
            color = min(classColors + 0.2,[0.8 0.8 0.8]);
        end
    end
    
    %I don't think we need these anymore - addFeatureNames and
    %addObservationNames...  we may need "remove feature names" and "remove
    %Observation Names"
    methods (Access = 'protected')
        %         function obj = addFeatureNames(obj,newFeatureNames,prevDim)
        %             if isempty(obj.featureNames) && isempty(newFeatureNames)
        %                 %don't worry about it
        %                 return;
        %             elseif ~isempty(obj.featureNames) && isempty(newFeatureNames)
        %                 obj.featureNames = cat(1,obj.featureNames,prtDataSetBase.generateDefaultFeatureNames((length(obj.featureNames)+1:obj.nFeatures)'));
        %             elseif isempty(obj.featureNames) && ~isempty(newFeatureNames)
        %                 obj.featureNames = cat(1,prtDataSetBase.generateDefaultFeatureNames(1:prevDim),newFeatureNames(:));
        %             else
        %                 obj.featureNames = cat(1,obj.featureNames,newFeatureNames);
        %             end
        %         end
        %
        %         function obj = addObservationNames(obj,newObservationNames,prevDim)
        %             if isempty(obj.observationNames) && isempty(newObservationNames)
        %                 %don't worry about it
        %                 return;
        %             elseif ~isempty(obj.observationNames) && isempty(newObservationNames)
        %                 obj.observationNames = cat(1,obj.observationNames,prtDataSetBase.generateDefaultObservationNames((length(obj.observationNames)+1:obj.nObservations)'));
        %             elseif isempty(obj.observationNames) && ~isempty(newObservationNames)
        %                 obj.observationNames = cat(1,prtDataSetBase.generateDefaultObservationNames(1:prevDim),newObservationNames(:));
        %             else
        %                 obj.observationNames = cat(1,obj.observationNames,newObservationNames);
        %             end
        %         end
    end
    
    %Static plotting aid functions - plotPoints, plotLines, makeExploreGui
    methods (Access = 'protected',Static = true)
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
        
        function makeExploreGui(theObject,theFeatures)
            % Get the window position and pick/set a figure size.
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
        %Set the observations to a new set
        obj = setObservations(obj,data,indices1,indices2)
        
        targets = getTargets(obj,indices1,indices2)
        obj = setTargets(obj,targets,indices)
        
        obj = joinFeatures(obj1,obj2)
        obj = joinObservations(obj1,obj2)
        
        obj = catFeatures(obj1,newFeatures)
        obj = catObservations(obj1,newObservations)
        
        handles = plot(obj)
        
        obj = removeObservations(obj,indices)
        obj = retainObservations(obj,indices)
        obj = replaceObservations(obj,data,indices)
        
        export(obj,prtExportObject)
        
        Summary = summarize(obj)
        
        %Note: for BIG data sets, these have to be implemented "trickily" -
        %I have an idea
        obj = removeFeatures(obj,indices)
        obj = retainFeatures(obj,indices)
        obj = replaceFeatures(obj,data,indices)

    end
end
