function prtPlotUtilDataSetExploreGuiWithNavigation(ds,plotInds)
% Internal function,
% xxx Need Help xxx - see prtDataSetClass.explore

if strcmpi(get(gcf,'tag'),'prtDataSetExplorerControl')
    % Current figure is nav controls
    % so make a new one
    figure
end

% Current figure is new (made by gcf or figure calls above) or existed
plotAxes = gca; % Will make an axes if one isn't already there.
if strcmpi(get(plotAxes,'tag'),'prtDataSetExploreAxes')
    % We are calling explore into an existing explore axes
    % This is bad. We need to destroy the existing nav control for this
    % explorer window (if it still exists).
    oldNavHandle = get(plotAxes,'UserData');
    if ishandle(oldNavHandle)
        close(oldNavHandle)
    end
end
    

if ds.nFeatures > 1
    plotInds = [1 2 0];
elseif ds.nFeatures > 0
    plotInds = [1 0 0];
else
    error('prt:prtDataSetClassExplore','Dataset has zero features and cannot be explored');
end

% Make control panel figure
% Make axes current
plotAxesFig = gcf;
set(plotAxesFig,'visible','off');


navFigSize = [300 250];
navFigPad = [18 59];

plotAxesFigPos = get(plotAxesFig,'position');
% navFigPosTop = plotAxesFigPos(2)+plotAxesFigPos(4);
% navFigPosLeft = plotAxesFigPos(1)+plotAxesFigPos(3);

oldUnits = get(plotAxes,'units');
set(plotAxes,'Units','pixels');
plotAxesOuterPos = get(plotAxes,'outerposition');
set(plotAxes,'units',oldUnits);

navFigPosTop = plotAxesFigPos(2)+plotAxesOuterPos(2)-1+plotAxesOuterPos(4);
navFigPosLeft = plotAxesFigPos(1)+plotAxesOuterPos(1)-1+plotAxesOuterPos(3);

navFigPos = cat(2,navFigPosLeft+navFigPad(1), navFigPosTop-navFigSize(2)+navFigPad(2), navFigSize(1), navFigSize(2));

navFigH = figure('Number','Off',...
    'Name','PRT Dataset Explorer Controls',...
    'Menu','none',...
    'Toolbar','none',...
    'Units','pixels',...
    'Position',navFigPos,...
    'NextPlot','new',...
    'tag','prtDataSetExplorerControl',...
    'DockControls','off',...
    'visible','off');

% Just in case anyone tries to plot in this window we will plot that inside
% an invisible axes
invisibleAxes = axes('parent',navFigH,...
    'units','pixels',...
    'position',[1 1 1 1],...
    'visible','off',...
    'handlevisibility','off'); %#ok<NASGU>

tabGroupH = createTabGroup(ds);


PlotHandles = []; % Add to all workspaces
remakePlot();

% We don't display the plots until now because it is kind of slow to make
% all of the gui elements and MATLAB will sometimes try to draw the half
% completed windows
set(plotAxesFig,'visible','on');
set(navFigH,'visible','on');
    
    function plotAxesDeleteFunction(myHandle, evenData) %#ok<INUSD>
        try %#ok<TRYNC>
            close(navFigH)
        end
    end
    function uitableEditFun(source, eventData) %#ok<INUSD>
        updateVisibleClasses();
    end

    function featureSelectPopupCallback(myHandle, eventData, varargin)  %#ok<INUSL>
        cVal = get(myHandle,'value');
        axisInd = varargin{1};
        
        if axisInd > 1
            cVal = cVal - 1;
        end
        plotInds(axisInd) = cVal;
        
        remakePlot();
    end

    function updateVisibleClasses()
        cData = get(tabGroupH.uitable,'data');
        displayLogical = cat(1,cData{:,2});
        
        if isempty(displayLogical)
            displayLogical = true;
            % Unlabeled dataset
        end
        
        for iClass = 1:length(PlotHandles)
            if displayLogical(iClass)
                set(PlotHandles(iClass),'visible','on');
            else
                set(PlotHandles(iClass),'visible','off');
            end
        end
        drawnow;
    end

    function remakePlot()
        
        actualPlotDims = plotInds(plotInds>=1);
        axes(plotAxes); %#ok<MAXES>
        PlotHandles = plot(ds,actualPlotDims);
        % Set the plotAxes delete function so that we delete the controls
        % when necessary.
        % We have to reset this each time
        setAxesProperties();
        
        updateVisibleClasses();
    end
    function setAxesProperties()
        set(plotAxes,'deleteFcn',@plotAxesDeleteFunction)
        set(plotAxes,'tag','prtDataSetExploreAxes')
        set(plotAxes,'UserData',navFigH);
        set(plotAxes,'ButtonDownFcn',@plotAxesOnClick);
        set(PlotHandles,'HitTest','off');
    end

    function plotAxesOnClick(myHandle,eventData)  %#ok<INUSD>
        actualPlotDims = plotInds(plotInds>=1);
        
        cData = get(tabGroupH.uitable,'data');
        displayLogical = cat(1,cData{:,2});
        
        if all(displayLogical)
            data = ds.getFeatures(actualPlotDims);
        else
            actualInds = ismember(ds.getTargetsClassInd, find(displayLogical));
            data = ds.getObservations(actualInds,actualPlotDims);
        end

        [rP,rD] = rotateDataAndClick(data);

        dist = prtDistanceEuclidean(rP,rD);
        [minDist,clickedObsInd] = min(dist);  %#ok<ASGLU>
        
        if ~all(displayLogical)
            actualInds = find(actualInds);
            clickedObsInd = actualInds(clickedObsInd);
        end
        
        displayInfo(clickedObsInd);
    end
    function displayInfo(clickedObsInd)
        obsName = ds.getObservationNames(clickedObsInd);
        
        cClassInd = ds.getTargetsClassInd(clickedObsInd);
        
        if isempty(cClassInd)
            cString = sprintf('Closest Observation:\n\t Name: %s',obsName{1});
        else
            className = ds.getClassNamesByClassInd(cClassInd);
            cString = sprintf('Closest Observation:\n\t Name: %s\t\nClass: %s',obsName{1},className{1});
        end
        
        
        set(tabGroupH.infoText,'string',cString);
        if length(ds.ObservationInfo) > clickedObsInd
            uicontrol('parent',tabGroupH.navPanel(3),'string','View ObsInfo','callback',@(a,b)testAb(a,b,ds.ObservationInfo(clickedObsInd)));
        else
            uicontrol('parent',tabGroupH.navPanel(3),'string','View Observation Info','enable','off');
        end
        
    end
    function testAb(a,b,c)
        assignin('base','prtPlotUtilDataSetExploreGuiWithNavigationTempVar',c);
        openvar('prtPlotUtilDataSetExploreGuiWithNavigationTempVar');
    end
    function [rotatedData,rotatedClick] = rotateDataAndClick(data)
        % Used internally; from Click3dPoint from matlab central;
        % See prtExternal.ClickA3DPoint.()
        %
        % The copyright info from that file is below.
        %
        % Copyright (c) 2009, Babak Taati All rights reserved.
        %
        % Redistribution and use in source and binary forms, with or
        % without modification, are permitted provided that the following
        % conditions are met:
        %
        %     * Redistributions of source code must retain the above
        %     copyright
        %       notice, this list of conditions and the following
        %       disclaimer.
        %     * Redistributions in binary form must reproduce the above
        %     copyright
        %       notice, this list of conditions and the following
        %       disclaimer in the documentation and/or other materials
        %       provided with the distribution
        %
        % THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
        % CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
        % INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
        % MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        % DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
        % BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
        % EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
        % TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
        % DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
        % ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
        % OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
        % OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
        % POSSIBILITY OF SUCH DAMAGE.

        point = get(plotAxes, 'CurrentPoint'); % mouse click position
        camPos = get(plotAxes, 'CameraPosition'); % camera position
        camTgt = get(plotAxes, 'CameraTarget'); % where the camera is pointing to

        camDir = camPos - camTgt; % camera direction
        camUpVect = get(plotAxes, 'CameraUpVector'); % camera 'up' vector

        % build an orthonormal frame based on the viewing direction and the
        % up vector (the "view frame")
        zAxis = camDir/norm(camDir);
        upAxis = camUpVect/norm(camUpVect);
        xAxis = cross(upAxis, zAxis);
        yAxis = cross(zAxis, xAxis);

        rot = [xAxis; yAxis; zAxis]; % view rotation

        % the clicked point represented in the view frame
        rotatedClick = rot * point' ;
        rotatedClick = rotatedClick(1:2,1)';        
        
        if size(data,2) < 3
            if size(data,2) < 2
                rot = rot(1);
            else
                rot = rot(1:2,1:2);
            end
        end
        
        % the point cloud represented in the view frame
        rotatedData = (rot * data')';
        
        if size(rotatedData,2) > 2
            rotatedData = rotatedData(:,1:2);
        end
        
        if size(data,2) < 2
            rotatedClick = rotatedClick(1);
        end
    end

    
    function H = createTabGroup(ds)
        % Make control panel uitabs and uipanels
        H.navTabGroup = prtUtilUitabgroup('parent',navFigH);
        H.navTab(1) = prtUtilUitab(H.navTabGroup, 'title', 'Features');
        H.navTab(2) = prtUtilUitab(H.navTabGroup, 'title', 'Classes');
        H.navTab(3) = prtUtilUitab(H.navTabGroup, 'title', 'Info');
        
        H.navPanel(1) = uipanel(H.navTab(1));
        H.navPanel(2) = uipanel(H.navTab(2));
        H.navPanel(3) = uipanel(H.navTab(3));
        
        % Make Feature Selection panel
        featureNames = ds.getFeatureNames;
        H.xAxesLabel = uicontrol(H.navTab(1),'style','text',...
            'units','normalized',...
            'position',[0.025 0.875 0.95 0.1],...
            'string','X Axis',...
            'FontWeight','bold',...
            'horizontalAlignment','left',...
            'FontUnits','normalized',...
            'FontSize',0.75);
        
        H.xPopUp = uicontrol(H.navTab(1),'style','popup',...
            'units','normalized',...
            'position',[0.025 0.675 0.95 0.2],...
            'string',featureNames,...
            'FontUnits','normalized',...
            'FontSize',0.5,...
            'callback',{@featureSelectPopupCallback 1});
        
        H.yAxesLabel = uicontrol(H.navTab(1),'style','text',...
            'units','normalized',...
            'position',[0.025 0.55 0.95 0.1],...
            'string','Y Axis',...
            'FontWeight','bold',...
            'horizontalAlignment','left',...
            'FontUnits','normalized',...
            'FontSize',0.75);
        
        H.yPopUp = uicontrol(H.navTab(1),'style','popup',...
            'units','normalized',...
            'position',[0.025 0.35 0.95 0.2],...
            'string',cat(1,{'None'}, featureNames),...
            'FontUnits','normalized',...
            'FontSize',0.5,...
            'callback',{@featureSelectPopupCallback 2});
        
        
        H.zAxesLabel = uicontrol(H.navTab(1),'style','text',...
            'units','normalized',...
            'position',[0.025 0.225 0.95 0.1],...
            'string','Z Axis',...
            'FontWeight','bold',...
            'horizontalAlignment','left',...
            'FontUnits','normalized',...
            'FontSize',0.75);
        
        H.zPopUp = uicontrol(H.navTab(1),'style','popup',...
            'units','normalized',...
            'position',[0.025 0.025 0.95 0.2],...
            'string',cat(1,{'None'}, featureNames),...
            'FontUnits','normalized',...
            'FontSize',0.5,...
            'callback',{@featureSelectPopupCallback 3});
        
        
        set(H.xPopUp,'value',plotInds(1)) % Always have at least 1 features
        if plotInds(2) > 0
            set(H.yPopUp,'value',plotInds(2)+1)
        else
            set(H.yPopUp,'value',1) % None;
        end
        if plotInds(3) > 0
            set(H.zPopUp,'value',plotInds(3))
        else
            set(H.zPopUp,'value',1) % None;
        end
        
        % Make classes uitable with tick boxes
        H.uitable = uitable('parent',H.navPanel(2),...
            'units','Normalized',...
            'position',[0.025 0.025 0.95 0.95],...
            'columnFormat',{'char','logical'},...
            'ColumnEditable',[false true],...
            'RowName',[],...
            'ColumnName',{'Class' 'Plot'},...
            'FontUnits','normalized',...
            'FontSize',0.1,...
            'SelectionHighlight','off',...
            'CellEditCallback',@uitableEditFun,...
            'data',cat(2,ds.getClassNames,num2cell(true(ds.nClasses,1))));
        
        % Column widths must be specified in pixels
        set(H.uitable,'units','pixels')
        uitablePos = floor(get(H.uitable,'position'));
        leftColumnWidth = floor(uitablePos(3)*0.7);
        set(H.uitable,'ColumnWidth', {leftColumnWidth uitablePos(3)-leftColumnWidth-22});
        set(H.uitable,'units','normalized')
        
        
        H.infoText = uicontrol('style','text',...
                               'parent',H.navPanel(3),...
                               'units','normalized',...
                               'position',[0.025 0.025 0.95 0.95],...
                               'FontSize',10,...
                               'FontName',get(0,'FixedWidthFontName'),...
                               'HorizontalAlignment','Left',...
                               'string','Click in the axes to inspect observations.');
    end

end