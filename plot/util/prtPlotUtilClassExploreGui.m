function prtPlotUtilClassExploreGui(class)
% PRTPLOTUTILCLASSEXPLOREGUI

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


assert(~isempty(class.isTrained),'prtPlotUtilClassExploreGui is only for trained classifiers.');
assert(~isempty(class.dataSet),'prtPlotUtilClassExploreGui requires that verboseStorage is true and therefore a prtDataSet is stored within the classifier.');
assert(~class.yieldsMaryOutput,'prtPlotUtilClassExploreGui is currently only for binary classifiers or classifiers that have an internal decider.');

if strcmpi(get(gcf,'tag'),'prtClassExploreControl')
    % Current figure is nav controls
    % so make a new one
    figure
end

% Current figure is new (made by gcf or figure calls above) or existed
plotAxes = gca; % Will make an axes if one isn't already there.
if strcmpi(get(plotAxes,'tag'),'prtClassExploreAxes')
    % We are calling explore into an existing explore axes
    % This is bad. We need to destroy the existing nav control for this
    % explorer window (if it still exists).
    oldNavHandle = get(plotAxes,'UserData');
    if ishandle(oldNavHandle)
        close(oldNavHandle)
    end
end
    

if class.dataSetSummary.nFeatures > 1
    plotInds = [1 2 0];
elseif class.dataSetSummary.nFeatures > 0
    plotInds = [1 0 0];
else
    error('prt:prtPlotUtilClassExploreGui','Dataset has zero features and cannot be explored');
end


featureNames = class.dataSet.getFeatureNames;
classNames = class.dataSet.getClassNames;

% Set Values
setValues = mean(cat(1,class.dataSetSummary.upperBounds,class.dataSetSummary.lowerBounds),1);

% Make control panel figure
% Make axes current
plotAxesFig = gcf;
set(plotAxesFig,'visible','off');

navFigSize = [300 400];
navFigPad = [18 55];

plotAxesFigPos = get(plotAxesFig,'position');
% navFigPosTop = plotAxesFigPos(2)+plotAxesFigPos(4);
% navFigPosLeft = plotAxesFigPos(1)+plotAxesFigPos(3);

oldUnits = get(plotAxes,'units');
set(plotAxes,'Units','pixels','tag','prtClassExploreAxes');
plotAxesOuterPos = get(plotAxes,'outerposition');
set(plotAxes,'units',oldUnits);

navFigPosTop = plotAxesFigPos(2)+plotAxesOuterPos(2)-1+plotAxesOuterPos(4);
navFigPosLeft = plotAxesFigPos(1)+plotAxesOuterPos(1)-1+plotAxesOuterPos(3);

navFigPos = cat(2,navFigPosLeft+navFigPad(1), navFigPosTop-navFigSize(2)+navFigPad(2), navFigSize(1), navFigSize(2));

navFigH = figure('Number','Off',...
    'Name','PRT Class Explorer Controls',...
    'Menu','none',...
    'Toolbar','none',...
    'Units','pixels',...
    'Position',navFigPos,...
    'NextPlot','new',...
    'tag','prtClassExploreControl',...
    'DockControls','off',...
    'visible','off');

% Just in case anyone tries to plot in this window we will plot that inside
% an invisible axes
invisibleAxes = axes('parent',navFigH,...
    'units','pixels',...
    'position',[1 1 1 1],...
    'visible','off',...
    'handlevisibility','off'); %#ok<NASGU>

tabGroupH = createTabGroup();

PlotHandles = []; % Add to all workspaces
clickedOnInd = [];
remakePlot();

% We don't display the plots until now because it is kind of slow to make
% all of the gui elements and MATLAB will sometimes try to draw the half
% completed windows
set(plotAxesFig,'visible','on');
set(navFigH,'visible','on');

yFeatureInds = setdiff(1:class.dataSetSummary.nFeatures,plotInds(1));
zFeatureInds = setdiff(1:class.dataSetSummary.nFeatures,plotInds(plotInds>0));

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
        
        switch axisInd
            case 1
                plotInds(axisInd) = cVal;
                setYString(tabGroupH);
                plotInds(2) = yFeatureInds(get(tabGroupH.yPopUp,'value'));
                setZString(tabGroupH);
                remakePlot();
                
            case 2
                plotInds(axisInd) = yFeatureInds(cVal);
                setZString(tabGroupH);
                remakePlot();
                
            case 3
                tabGroupH = setZAxes(tabGroupH);
                
                %Update value selector
                clickedOnInd = [];
        end
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
        
        imageHandle = class.plotBinaryConfidenceWithFixedFeatures(actualPlotDims,setValues);
        set(imageHandle.imageHandle,'HitTest','off');
        hold on
        subDataSet = class.dataSet.retainFeatures(actualPlotDims);
        subDataSet = subDataSet.setFeatureNames(featureNames(actualPlotDims));
        PlotHandles = plot(subDataSet);
        
        if ~isempty(clickedOnInd)
            symbols = class.dataSet.plotOptions.symbolsFunction(class.dataSetSummary.nClasses);
            plot(setValues(actualPlotDims(1)), setValues(actualPlotDims(2)), symbols(class.dataSet.getTargetsClassInd(clickedOnInd)),'MarkerSize',class.dataSet.plotOptions.symbolSize,'color',[0 0 0]);
        end
        
        hold off
        
        % Set the plotAxes delete function so that we delete the controls
        % when necessary.
        % We have to reset this each time
        setAxesProperties();
        
        updateVisibleClasses();
    end
    function setAxesProperties()
        set(plotAxes,'deleteFcn',@plotAxesDeleteFunction)
        set(plotAxes,'tag','prtClassExploreAxes')
        set(plotAxes,'UserData',navFigH);
        set(plotAxes,'ButtonDownFcn',@plotAxesOnClick);
        set(PlotHandles,'HitTest','off');
    end

    function plotAxesOnClick(myHandle,eventData)  %#ok<INUSD>
        actualPlotDims = plotInds(plotInds>=1);
        
        if ~ishandle(navFigH)
            return
        end
        
        cData = get(tabGroupH.uitable,'data');
        displayLogical = cat(1,cData{:,2});
        
        if all(displayLogical)
            data = class.dataSet.getFeatures(actualPlotDims);
        else
            actualInds = ismember(class.dataSet.getTargetsClassInd, find(displayLogical));
            data = class.dataSet.getObservations(actualInds,actualPlotDims);
        end

        [rP,rD] = rotateDataAndClick(data);

        dist = prtDistanceEuclidean(rP,rD);
        [minDist,clickedObsInd] = min(dist);  %#ok<ASGLU>
        
        if ~all(displayLogical)
            actualInds = find(actualInds);
            clickedObsInd = actualInds(clickedObsInd);
        end
        
        displayInfo(clickedObsInd);

        setValues = class.dataSet.getObservations(clickedObsInd);
        clickedOnInd = clickedObsInd;
        
        remakePlot();
        moveZAxesLine();
    end
    function displayInfo(clickedObsInd)
        obsName = class.dataSet.getObservationNames(clickedObsInd);
        
        cClassInd = class.dataSet.getTargetsClassInd(clickedObsInd);
        
        if isempty(cClassInd)
            cString = sprintf('Closest Observation:\n\t Name: %s',obsName{1});
        else
            className = class.dataSet.getClassNamesByClassInd(cClassInd);
            cString = sprintf('Closest Observation:\n\t Name: %s\t\nClass: %s',obsName{1},className{1});
        end
        
        set(tabGroupH.infoText,'string',cString);
        
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

    
    function H = createTabGroup()
        % Make control panel uitabs and uipanels
        H.navTabGroup = prtUtilUitabgroup('parent',navFigH);
        H.navTab(1) = prtUtilUitab(H.navTabGroup, 'title', 'Features');
        H.navTab(2) = prtUtilUitab(H.navTabGroup, 'title', 'Classes');
        H.navTab(3) = prtUtilUitab(H.navTabGroup, 'title', 'Info.');
        
        H.navPanel(1) = uipanel(H.navTab(1));
        H.navPanel(2) = uipanel(H.navTab(2));
        H.navPanel(3) = uipanel(H.navTab(3));
        
        % Make Feature Selection panel
        H.xAxesLabel = uicontrol(H.navTab(1),'style','text',...
            'units','normalized',...
            'position',[0.025 0.9124 0.95 0.0625],...
            'string','X Axis',...
            'FontWeight','bold',...
            'horizontalAlignment','left',...
            'FontUnits','normalized',...
            'FontSize',0.75);
        
        H.xPopUp = uicontrol(H.navTab(1),'style','popup',...
            'units','normalized',...
            'position',[0.025 0.7874 0.95 0.125],...
            'string',featureNames,...
            'FontUnits','normalized',...
            'FontSize',0.5,...
            'callback',{@featureSelectPopupCallback 1});
        
        H.yAxesLabel = uicontrol(H.navTab(1),'style','text',...
            'units','normalized',...
            'position',[0.025 0.6936 0.95 0.0625],...
            'string','Y Axis',...
            'FontWeight','bold',...
            'horizontalAlignment','left',...
            'FontUnits','normalized',...
            'FontSize',0.75);
        
        H.yPopUp = uicontrol(H.navTab(1),'style','popup',...
            'units','normalized',...
            'position',[0.025 0.5686 0.95 0.125],...
            'string',featureNames,...
            'FontUnits','normalized',...
            'FontSize',0.5,...
            'callback',{@featureSelectPopupCallback 2});
        
        
        H.zAxesLabel = uicontrol(H.navTab(1),'style','text',...
            'units','normalized',...
            'position',[0.025 0.4748 0.95 0.0625],...
            'string','Other Dimension Values:',...
            'FontWeight','bold',...
            'horizontalAlignment','left',...
            'FontUnits','normalized',...
            'FontSize',0.75);
        
        H.zPopUp = uicontrol(H.navTab(1),'style','popup',...
            'units','normalized',...
            'position',[0.025 0.3498 0.95 0.125],...
            'FontUnits','normalized',...
            'FontSize',0.5,...
            'string',{'temp'},... % Will be quickly changed.
            'callback',{@featureSelectPopupCallback 3});
        
        
        H.zAxes = axes('parent',H.navTab(1),...
                       'units','normalized',...
                       'position',[0.1 0.131 0.8 0.1875]);
        
        
        axes(H.zAxes) %#ok<MAXES>
        hold on
        H.zLinePlot = plot(H.zAxes,0,1,'k'); %Will be quickly changed. 
        H.zDensityLinePlot = plot(H.zAxes,zeros(2,1),ones(2,class.dataSetSummary.nClasses),'w'); %Will be quickly changed. 
        hold off
        
        set(H.xPopUp,'value',plotInds(1))
        set(H.yPopUp,'value',plotInds(2))
        set(H.zPopUp,'value',1)
        
        setZString(H);
        H = setZAxes(H);
        setYString(H);
        
        % Make classes uitable with tick boxes
        H.uitable = uitable('parent',H.navPanel(2),...
            'units','Normalized',...
            'position',[0.025 0.025 0.95 0.95],...
            'columnFormat',{'char','logical'},...
            'ColumnEditable',[false true],...
            'RowName',[],...
            'ColumnName',{'Class' 'Plot'},...
            'FontUnits','normalized',...
            'FontSize',0.05,...
            'SelectionHighlight','off',...
            'CellEditCallback',@uitableEditFun,...
            'data',cat(2,classNames,num2cell(true(length(classNames),1))));
        
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

    function setZString(H)
        if class.dataSetSummary.nFeatures < 3
            set(H.zPopUp,'value',1,'string',{'Not Available'},'Enable','off');
            return
        end
        oldVal = get(H.zPopUp,'value');
        oldString = get(H.zPopUp,'string');
        oldStringVal = oldString{oldVal};
        
        featureVec = 1:class.dataSetSummary.nFeatures;
        newFeatureVec = setdiff(featureVec,plotInds(plotInds>0));
        newString = featureNames(newFeatureVec);
        
        [consistentString, newVal] = ismember(oldStringVal,newString);
        
        if ~consistentString
            newVal = 1;
        end
        
        set(H.zPopUp,'value',newVal,'string',newString);
        zFeatureInds = newFeatureVec;
        
        %if ~isequal(preferedNewVal,
        
    end
    function setYString(H)
        if class.dataSetSummary.nFeatures < 2
            set(H.yPopUp,'value',1,'string',{'Not Available'},'Enable','off');
            return
        end
        
        oldVal = get(H.yPopUp,'value');
        oldString = get(H.yPopUp,'string');
        oldStringVal = oldString{oldVal};
        
        featureVec = 1:class.dataSetSummary.nFeatures;
        newFeatureVec = setdiff(featureVec,plotInds(1));
        newString = featureNames(newFeatureVec);
        
        [consistentString, newVal] = ismember(oldStringVal,newString);
        
        if ~consistentString
            newVal = 1;
        end
        
        set(H.yPopUp,'value',newVal,'string',newString);
        yFeatureInds = newFeatureVec;
    end

    function H = setZAxes(H)
        
        if class.dataSetSummary.nFeatures < 3
            set(H.zAxes,'visible','off');
            return
        end
        
        %set(navFigH,'NextPlot','replace');
        iFeature = zFeatureInds(get(H.zPopUp,'value'));
        
        nKSDsamples = 500;
        nClasses = class.dataSetSummary.nClasses;
        xLoc = linspace(class.dataSetSummary.lowerBounds(iFeature), class.dataSetSummary.upperBounds(iFeature), nKSDsamples);
                        
        F = zeros([nKSDsamples, nClasses]);
        for cY = 1:nClasses
            F(:,cY) = pdf(mle(prtRvKde,class.dataSet.getObservationsByClassInd(cY,iFeature)),xLoc(:));
        end
        colors = class.dataSet.plotOptions.colorsFunction(class.dataSetSummary.nClasses);
        
        if any(ishandle(H.zDensityLinePlot))
            delete(H.zDensityLinePlot(ishandle(H.zDensityLinePlot)));
        end
        
        hold on
        lineHandles = plot(H.zAxes,xLoc,F);
        for iLine = 1:length(lineHandles)
            set(lineHandles(iLine),'color',colors(iLine,:));
        end
        xlim([class.dataSetSummary.lowerBounds(iFeature), class.dataSetSummary.upperBounds(iFeature)]);
               
        H.zDensityLinePlot = lineHandles;
        
        ylim([0 max(F(:))]);
        
        v = axis;
        set(H.zLinePlot,'XData',setValues(iFeature)*ones(2,1),'YData',v(3:4));
        hold off
        
        set(H.zAxes,'XTick',setValues(iFeature),'YTick',[]);
        set(navFigH,'NextPlot','new');
    end

    function moveZAxesLine()
        if class.dataSetSummary.nFeatures < 3
            % Everything is disabled so we don't do anything.
            return
        end
        
        H = tabGroupH;
        iFeature = zFeatureInds(get(H.zPopUp,'value'));
        v = axis(H.zAxes);
        set(H.zLinePlot,'XData',setValues(iFeature)*ones(2,1),'YData',v(3:4));
        set(H.zAxes,'XTick',setValues(iFeature),'YTick',[]);
        
        axesChildren = get(H.zAxes,'children');
        
        lineHInd = find(axesChildren == H.zLinePlot);
        
        set(H.zAxes,'children',cat(1, H.zLinePlot ,axesChildren(setdiff(1:length(axesChildren),lineHInd))));
    end

end
