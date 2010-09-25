function prtPlotUtilAlgorithmGui(connectivityMatrix, actionCell)

algoStr = cellfun(@(c)c.nameAbbreviation,actionCell,'uniformoutput',false);
algoStr = cat(1,{'Input'}, algoStr(:), {'Output'});
actionCell = cat(1,{[]},actionCell(:),{[]});

GraphLayoutInfo = prtPlotUtilGraphVizRun(connectivityMatrix');

nodePosMat = cat(1,GraphLayoutInfo.Nodes.pos);
nodePosMat = bsxfun(@minus,nodePosMat,min(nodePosMat));
nodePosMat = bsxfun(@rdivide,nodePosMat,max(nodePosMat));

nodePosMat(isnan(nodePosMat))=0;

minDistBetweenBlocks = min(min(prtDistanceLNorm(nodePosMat,nodePosMat,2) + realmax*eye(size(connectivityMatrix))));

blockSize = minDistBetweenBlocks*1/2;

nodePosMat = bsxfun(@rdivide,nodePosMat,max(nodePosMat)+[blockSize blockSize]);

Options = localGetOptions();

Handles = localMakeFigure();

% Ready the outputs
BlankBlock = struct('handle',[],'textHandle',[], 'Object',[]);

Layout.nBlocks = size(connectivityMatrix,1);
Layout.Blocks = BlankBlock;
Layout.connectivity = connectivityMatrix;
Layout.edges = zeros(sum(connectivityMatrix(:)),1);

Gui.status = '';
Gui.previous_point = [];

for iBlockOuter = 1:Layout.nBlocks
    placeBlockFunction([], [], actionCell{iBlockOuter}, nodePosMat(iBlockOuter,:), iBlockOuter, algoStr{iBlockOuter});
end

for iEdge = 1:length(GraphLayoutInfo.Edges)
    startLoc = cat(2,nodePosMat(GraphLayoutInfo.Edges(iEdge).startIndex,1)+blockSize,nodePosMat(GraphLayoutInfo.Edges(iEdge).startIndex,2)+blockSize/2);
    stopLoc = cat(2,nodePosMat(GraphLayoutInfo.Edges(iEdge).stopIndex,1),nodePosMat(GraphLayoutInfo.Edges(iEdge).stopIndex,2)+blockSize/2);
    
    Layout.edges(iEdge) = prtPlotUtilPlotArrow(cat(1,startLoc(1),stopLoc(1)),cat(1,startLoc(2),stopLoc(2)),[15 2]);
    set(Layout.edges(iEdge),'facecolor',[0 0 0],'edgecolor',[0 0 0])
    
end

[xlims, ylims] = centerBlocks();

axis(cat(2,xlims, ylims));

%% Begin Functions

    function patchWindowButtonMotion(hObject, eventData, blockIndex) %#ok
        cp = get(Handles.AxesPanel.mainAxes,'currentPoint');
        
        newX = Options.blockSize(1)/2*[-1 -1 1 1 -1] + cp(1,1);
        newY = Options.blockSize(2)/2*[-1 1 1 -1 -1] + cp(1,2);
        Layout.Blocks(blockIndex).polygonNodes = cat(2,newX(:), newY(:));
        
        set(Layout.Blocks(blockIndex).handle,'XData',newX, 'YData', newY);
        set(Layout.Blocks(blockIndex).textHandle,'Position',[cp(1,1) cp(1,2)+Options.blockSize(2)/2 0]);
        
        %Move Edges
        for jEdge = 1:length(GraphLayoutInfo.Edges)
            if blockIndex == GraphLayoutInfo.Edges(jEdge).startIndex || blockIndex == GraphLayoutInfo.Edges(jEdge).stopIndex
                
                
                startInd = GraphLayoutInfo.Edges(jEdge).startIndex;
                stopInd = GraphLayoutInfo.Edges(jEdge).stopIndex;
                
                cStartX = get(Layout.Blocks(startInd).handle,'XData');
                cStartY = get(Layout.Blocks(startInd).handle,'YData');
                
                cStopX = get(Layout.Blocks(stopInd).handle,'XData');
                cStopY = get(Layout.Blocks(stopInd).handle,'YData');
                
                startLoc = cat(2,max(cStartX), mean(unique(cStartY)));
                stopLoc = cat(2,min(cStopX), mean(unique(cStopY)));
    
                try
                    delete(Layout.edges(jEdge));
                end
                Layout.edges(jEdge) = prtPlotUtilPlotArrow(cat(1,startLoc(1),stopLoc(1)),cat(1,startLoc(2),stopLoc(2)),[15 2]);
                set(Layout.edges(jEdge),'facecolor',[0 0 0],'edgecolor',[0 0 0])
            end
        end
                
    end

    function patchButtonDownFunction(hObject, eventData, blockIndex) %#ok<INUSL>
        
        set(Handles.handle,'WindowButtonMotionFcn',@(h,E)patchWindowButtonMotion(h,E, blockIndex));
        set(Handles.handle,'WindowButtonUpFcn',@(h,E)patchButtonUpFunction(h,E, blockIndex));
    end

    function patchButtonUpFunction(hObject, eventData, blockIndex)   %#ok<INUSL>
        
        set(Handles.handle,'WindowButtonMotionFcn',@pan_motion,...
                           'WindowButtonDownFcn'  , @pan_click,...
                           'WindowButtonUpFcn'    , @pan_release);
        Gui.status = '';
        
        set(Layout.Blocks(blockIndex).handle,'Selected','off')
    end

    function placeBlockFunction(hObject, eventData, BlockObject, position, iBlock, blockStr)  %#ok<INUSL>
        
        % Extract stuff from the options so that the GUI can use it
        if isempty(BlockObject)
            blockColor = Options.BlockColors.dataSet;
        elseif isa(BlockObject,'prtPreProc')
            blockColor = Options.BlockColors.preProcessor;
        elseif isa(BlockObject,'prtFeatSel')
            blockColor = Options.BlockColors.featureSelector;
        elseif isa(BlockObject,'prtClass')
            blockColor = Options.BlockColors.classifier;
        elseif isa(BlockObject,'prtDecision')
            blockColor = Options.BlockColors.decision;
        else
            error('Unsupported Block Type');
        end
        
        newPolygonNodes = [position(1) position(2);
                           position(1)+blockSize position(2);
                           position(1)+blockSize position(2)+blockSize;
                           position(1) position(2)+blockSize;
                           position(1) position(2)];
        
        Layout.Blocks(iBlock).polygonNodes = newPolygonNodes;
        Layout.Blocks(iBlock).handle = patch(newPolygonNodes(:,1), newPolygonNodes(:,2), blockColor);
        Layout.Blocks(iBlock).textHandle = text(mean(newPolygonNodes(1:2,1)),max(newPolygonNodes(:,2)),blockStr,'VerticalAlignment','Top','HorizontalAlignment','Center','Color',[0 0 0],'FontUnits','Normalized','FontSize',Options.blockFontSizeNormalized);
        
        set(Layout.Blocks(iBlock).handle,'ButtonDownFcn',@(h,E)patchButtonDownFunction(h,E,iBlock));
        set(Layout.Blocks(iBlock).textHandle,'ButtonDownFcn',@(h,E)patchButtonDownFunction(h,E,iBlock));
        
        %set(Handles.AxesPanel.mainAxes,'XLim',Options.initialCanvasLimits(1:2),'YLim',Options.initialCanvasLimits(3:4));
        Layout.Blocks(iBlock).Object = BlockObject;
        
        % Turn off / cancel the button placement
%         set(Handles.handle,'WindowScrollWheelFcn' , @scroll_zoom,...
%             'WindowButtonDownFcn'  , @pan_click,...
%             'WindowButtonUpFcn'    , @pan_release,...
%             'WindowButtonMotionFcn', @pan_motion);
%         set(Handles.Hover.plotHandle,'ButtonDownFcn',[]);
%         set(Handles.Hover.plotHandle,'XData',nan(4,1),'YData',nan(4,1));
%         set(Handles.Hover.textHandle,'color',[1 1 1]);
%         
%         set(Layout.Blocks(Layout.nBlocks).handle,'DeleteFcn',@(h,o)blockDeleteFcn(h,o),'HitTest','on');
        %set(Layout.Blocks(Layout.nBlocks).textHandle,'DeleteFcn',@(h,o)blockTextDeleteFcn(h,o,Layout.nBlocks),'HitTest','on');
    end

% zoom in to the current point with the mouse wheel
% Stolen from mouse_figure  - Rody P.S. Oldenhuis
    function scroll_zoom(varargin)
        if ~ishandle(Handles.handle)
            return
        end
        % double check if these axes are indeed the current axes
        if get(Handles.handle, 'currentaxes') ~= Handles.AxesPanel.mainAxes, return, end
        % get the amount of scolls
        scrolls = varargin{2}.VerticalScrollCount;
        % get the axes' x- and y-limits
        xlim = get(Handles.AxesPanel.mainAxes, 'xlim');  ylim = get(Handles.AxesPanel.mainAxes, 'ylim');
        % get the current camera position, and save the [z]-value
        cam_pos_Z = get(Handles.AxesPanel.mainAxes, 'cameraposition');  cam_pos_Z = cam_pos_Z(3);
        % get the current point
        old_position = get(Handles.AxesPanel.mainAxes, 'CurrentPoint'); old_position(1,3) = cam_pos_Z;
        % calculate zoom factor
        zoomfactor = 1 - scrolls/50;
        % adjust camera position
        set(Handles.AxesPanel.mainAxes, 'cameratarget', [old_position(1, 1:2), 0],...
            'cameraposition', old_position(1, 1:3));
        % adjust the camera view angle (equal to zooming in)
        camzoom(zoomfactor);
        % zooming with the camera has the side-effect of
        % NOT adjusting the axes limits. We have to correct for this:
        x_lim1 = (old_position(1,1) - min(xlim))/zoomfactor;
        x_lim2 = (max(xlim) - old_position(1,1))/zoomfactor;
        xlim   = [old_position(1,1) - x_lim1, old_position(1,1) + x_lim2];
        y_lim1 = (old_position(1,2) - min(ylim))/zoomfactor;
        y_lim2 = (max(ylim) - old_position(1,2))/zoomfactor;
        ylim   = [old_position(1,2) - y_lim1, old_position(1,2) + y_lim2];
        set(Handles.AxesPanel.mainAxes, 'xlim', xlim), set(Handles.AxesPanel.mainAxes, 'ylim', ylim)
        % set new camera position
        new_position = get(Handles.AxesPanel.mainAxes, 'CurrentPoint');
        old_camera_target =  get(Handles.AxesPanel.mainAxes, 'CameraTarget');
        old_camera_target(3) = cam_pos_Z;
        new_camera_position = old_camera_target - ...
            (new_position(1,1:3) - old_camera_target(1,1:3));
        % adjust camera target and position
        set(Handles.AxesPanel.mainAxes, 'cameraposition', new_camera_position(1, 1:3),...
            'cameratarget', [new_camera_position(1, 1:2), 0]);
        % we also have to re-set the axes to stretch-to-fill mode
        set(Handles.AxesPanel.mainAxes, 'cameraviewanglemode', 'auto',...
            'camerapositionmode', 'auto',...
            'cameratargetmode', 'auto');
        
        Options.blockFontSizeNormalized = Options.blockFontSizeNormalized .* zoomfactor;
        % New Part by Kenny
        resizeText();
        
    end % scroll_zoom

% pan upon mouse click
% Stolen from mouse_figure  - Rody P.S. Oldenhuis
    function pan_click(varargin)
        if ~ishandle(Handles.handle)
            return
        end
        % double check if these axes are indeed the current axes
        if get(Handles.handle, 'currentaxes') ~= Handles.AxesPanel.mainAxes, return, end
        % perform appropriate action
        switch lower(get(Handles.handle, 'selectiontype'))
            % start panning on left click
            case 'normal'
                %                 Gui.status = 'down';
                %                 Gui.previous_point = get(Handles.AxesPanel.mainAxes, 'CurrentPoint');
                cp = get(Handles.AxesPanel.mainAxes, 'CurrentPoint');
                %% New Part from Kenny
                
                % From the current point we check and see if we are
                % clicking on a block.
                blockInd = findBlockClick(cp);
                if ~isempty(blockInd)
                    deselectEverything();
                    set(Layout.Blocks(blockInd).handle,'Selected','on');
                    Gui.status = 'block';
                    Gui.blockInd = blockInd;
                    Gui.previous_point = cp;
                else
                    deselectEverything();
                    % Clicking on back canvas Allow dragging around
                    Gui.status = 'down';
                    Gui.previous_point = cp;
                end
                
                
            case 'open' % double click (left or right)
                cp = get(Handles.AxesPanel.mainAxes, 'CurrentPoint');
                blockInd = findBlockClick(cp);
                if ~isempty(blockInd)
                    set(Handles.handle,'WindowButtonMotionFcn',@pan_motion,...
                        'WindowButtonDownFcn'  , @pan_click,...
                        'WindowButtonUpFcn'    , @pan_release);
                    
                    Gui.status = '';
                    
                    % Double clicking on a block
                    %msgbox(sprintf('This would be a %s options editing GUI.',get(Layout.Blocks(blockInd).textHandle,'string')),'Options Edtior Placeholder','Modal');
                    
                    if ~isempty(actionCell{blockInd}) && ismethod(actionCell{blockInd},'plot') && actionCell{blockInd}.isTrained
                        if actionCell{blockInd}.DataSetSummary.nFeatures > 1 && actionCell{blockInd}.DataSetSummary.nFeatures < 4
                            figure
                            plot(actionCell{blockInd})
                        else
                            %msgbox('This node has too many dimensions for plotting','Modal');
                        end
                    else
                        % Do something else?
                        
                    end
                        
                else
                    % Double clicking on back canvas.
                    % center view
                    [xlim, ylim] = centerBlocks;
                    set(Handles.AxesPanel.mainAxes, 'Xlim', xlim, 'Ylim', ylim);
                end
                % right click - set new reset state
            case 'alt'
                % We probably want to disable this for context menu
                %                 Gui.original_xlim = get(Handles.AxesPanel.mainAxes, 'xlim');
                %                 Gui.original_ylim = get(Handles.AxesPanel.mainAxes, 'ylim');
        end
    end

% release mouse button
% Stolen from mouse_figure  - Rody P.S. Oldenhuis
    function pan_release(varargin)
        % double check if these axes are indeed the current axes
        if get(Handles.handle, 'currentaxes') ~= Handles.AxesPanel.mainAxes, return, end
        
        switch lower(Gui.status)
            case 'down'
            case 'block'
        end
        
        %deselectEverything();
        % reset Gui.status
        Gui.status = '';
    end

% move the mouse (with button clicked)
% Stolen from mouse_figure  - Rody P.S. Oldenhuis
    function pan_motion(varargin)
        if ~ishandle(Handles.handle)
            return
        end
        % double check if these axes are indeed the current axes
        if get(Handles.handle, 'currentaxes') ~= Handles.AxesPanel.mainAxes, return, end
        % return if there isn't a previous point
        if isempty(Gui.previous_point), return, end
        % return if mouse hasn't been clicked
        if isempty(Gui.status), return, end
        % get current location (in pixels)
        current_point = get(Handles.AxesPanel.mainAxes, 'CurrentPoint');
        
        switch lower(Gui.status)
            case 'down'
                % get current XY-limits
                xlim = get(Handles.AxesPanel.mainAxes, 'xlim');  ylim = get(Handles.AxesPanel.mainAxes, 'ylim');
                % find change in position
                delta_points = current_point - Gui.previous_point;
                % adjust limits
                new_xlim = xlim - delta_points(1);
                new_ylim = ylim - delta_points(3);
                % set new limits
                set(Handles.AxesPanel.mainAxes, 'Xlim', new_xlim); set(Handles.AxesPanel.mainAxes, 'Ylim', new_ylim);
                % save new position
                Gui.previous_point = get(Handles.AxesPanel.mainAxes, 'CurrentPoint');
%             case 'block'
%                 cX = Options.blockSize(1)/2*[-1 -1 1 1 -1] + current_point(1,1);
%                 cY = Options.blockSize(2)/2*[-1 1 1 -1 -1] + current_point(1,2);
%                 set(Layout.Blocks(Gui.blockInd).handle,'XData',cX, 'YData',cY);
%                 set(Layout.Blocks(Gui.blockInd).textHandle,'Position',[current_point(1,1) current_point(1,2)+Options.blockSize(2)/2 0]);
%                 Layout.Blocks(Gui.blockInd).polygonNodes = [cX(:) cY(:)];
                
        end
    end

    function deselectEverything
        % Blocks
        for iBlock = 1:Layout.nBlocks
            set(Layout.Blocks(iBlock).handle,'Selected','off');
        end
    end

    function [xLims, yLims] = centerBlocks
        if Layout.nBlocks == 0
            xLims = Options.initialCanvasLimits(1:2);
            yLims = Options.initialCanvasLimits(3:4);
            Options.blockFontSizeNormalized = Options.initialBlockFontSizeNormalized;
            return
        end
        
        xLims = [inf -inf];
        yLims = [inf -inf];
        for iBlock = 1:Layout.nBlocks
            maxPos = max(Layout.Blocks(iBlock).polygonNodes);
            minPos = min(Layout.Blocks(iBlock).polygonNodes);
            xLims(1) = min(xLims(1),minPos(1));
            xLims(2) = max(xLims(2),maxPos(1));
            yLims(1) = min(yLims(1),minPos(2));
            yLims(2) = max(yLims(2),maxPos(2));
        end
        % Add some percentage to the edges
        edgePadPercent = 0.05;
        xLimsPadded = [-(xLims(2)-xLims(1)) (xLims(2)-xLims(1))]*edgePadPercent + xLims;
        yLimsPadded = [-(yLims(2)-yLims(1)) (yLims(2)-yLims(1))]*edgePadPercent + yLims;
        
        xRange = xLimsPadded(2)-xLimsPadded(1);
        yRange = yLimsPadded(2)-yLimsPadded(1);
        
        if xRange > yRange
            % We need to add some to the yRange to make equal aspect ratio
            xLims = xLimsPadded;
            yLims = yLimsPadded + (xRange-yRange)/2*[-1 1];
            yRange = xRange;
        else
            xLims = xLimsPadded + (yRange-xRange)/2*[-1 1];
            yLims = yLimsPadded;
            xRange = yRange;
        end
        
        % Dont zoom in more than the original
%         initRange = Options.initialCanvasLimits(2)-Options.initialCanvasLimits(1);
%         if xRange < initRange
%             xLims = (initRange-xRange)/2*[-1 1] + xLims;
%             yLims = (initRange-xRange)/2*[-1 1] + yLims;
%             xRange = initRange;
%             yRange = initRange;
%         end
        
        zoomFactorFromOriginal = max(xRange,yRange) ./ (Options.initialCanvasLimits(2)-Options.initialCanvasLimits(1));
        Options.blockFontSizeNormalized = 1./zoomFactorFromOriginal.*Options.initialBlockFontSizeNormalized;
        resizeText();
    end
    function resizeText
        for iBlock = 1:Layout.nBlocks
            set(Layout.Blocks(iBlock).textHandle,'FontSize',Options.blockFontSizeNormalized);
        end
        set(Handles.Hover.textHandle,'FontSize',Options.blockFontSizeNormalized);
    end
    function blockInd = findBlockClick(cp)
        blockInd = [];
        for iBlock = 1:Layout.nBlocks
            isInThisBlock = all(cp(1,1:2) < max(Layout.Blocks(iBlock).polygonNodes) & cp(1,1:2) > min(Layout.Blocks(iBlock).polygonNodes));
            if isInThisBlock
                blockInd = iBlock;
                
                return
            end
        end
    end


    function Options = localGetOptions()
        
        Options.initialCanvasLimits = [-0.1 1.1 -0.1 1.1];
        Options.blockSize = blockSize*[1 1];
        Options.initialBlockFontSizeNormalized = 0.03; %This is the default relative to the initialCanvas limits
        Options.blockFontSizeNormalized = Options.initialBlockFontSizeNormalized; %It can change as a function of the zoom level.
        Options.blockHoverEdgeColor = [0.8 0.8 0.8];
        Options.blockHoverTextColor = [0.8 0.8 0.8];
        Options.BlockColors.dataSet = [1 1 1];
        Options.BlockColors.preProcessor = [1 0.8 0.6];
        Options.BlockColors.featureSelector = [0.6 1 0.8];
        Options.BlockColors.classifier = [0.7 0.7 1];
        Options.BlockColors.decision = [0.3 0.3 0.3];
    end


    function Handles = localMakeFigure()
        
        ss = get(0,'screensize');
        
        windowSize = [754 600];
        
        % Center the window
        sizePads = round((ss(3:4)-windowSize));
        sizePads(1) = sizePads(1)/2; % We should use 2 right?
        sizePads(2) = sizePads(2)/2;
        pos = cat(2,sizePads,windowSize);
        
        % Create the figure an UIControls
        MainFigure.style = 'figure';
        MainFigure.units = 'pixels';
        MainFigure.position = pos;
        MainFigure.name = 'PRT Algorithm';
        MainFigure.Number = 'Off';
        MainFigure.Menu = 'none';
        MainFigure.toolbar = 'figure';
        MainFigure.DockControls = 'off';
        
        MainFigure.Children.AxesPanel.style = 'panel';
        MainFigure.Children.AxesPanel.units = 'normalized';
        MainFigure.Children.AxesPanel.position = [0 0 1 1];
        MainFigure.Children.AxesPanel.Children.mainAxes.style = 'axes';
        MainFigure.Children.AxesPanel.Children.mainAxes.units = 'Normalized';
        MainFigure.Children.AxesPanel.Children.mainAxes.position = [0 0 1 1];
        MainFigure.Children.AxesPanel.Children.mainAxes.xtick = [];
        MainFigure.Children.AxesPanel.Children.mainAxes.ytick = [];
        MainFigure.Children.AxesPanel.Children.mainAxes.xlim = [0 1];
        MainFigure.Children.AxesPanel.Children.mainAxes.ylim = [0 1];
        MainFigure.Children.AxesPanel.Children.mainAxes.nextPlot = 'add';
        
        Handles = prtUtilSuicontrol(MainFigure);
        
        Handles.Hover.plotHandle = patch(nan(4,1),nan(4,1),[0.95 0.95 0.95],'EdgeColor',Options.blockHoverEdgeColor);
        Handles.Hover.textHandle = text(0,0,'NAME','color',Options.blockHoverTextColor,'VerticalAlignment','Top','HorizontalAlignment','Center','FontUnits','Normalized','FontSize',Options.blockFontSizeNormalized,'HitTest','off');
        set(Handles.Hover.plotHandle,'visible','off');
        set(Handles.Hover.textHandle,'visible','off');
        
        
        % Trim the toolbar down to just the zooming controls
        Handles.Toolbar.handle = findall(Handles.handle,'Type','uitoolbar');
        Handles.Toolbar.Children = findall(Handles.handle,'Parent',Handles.Toolbar.handle,'HandleVisibility','off');
        
        % Delete a bunch of things we dont need
        delete(findobj(Handles.Toolbar.Children,'TooltipString','New Figure',...
            '-or','TooltipString','Open File','-or','TooltipString','Save Figure',...
            '-or','TooltipString','Print Figure','-or','TooltipString','Edit Plot',...
            '-or','TooltipString','Data Cursor','-or','TooltipString','Brush/Select Data',...
            '-or','TooltipString','Link Plot','-or','TooltipString','Insert Colorbar',...
            '-or','TooltipString','Insert Legend','-or','TooltipString','Show Plot Tools and Dock Figure',...
            '-or','TooltipString','Hide Plot Tools'))
        
        
        % define zooming with scrollwheel, and panning with mouseclicks
        set(Handles.handle, 'WindowScrollWheelFcn' , @scroll_zoom,...
            'WindowButtonDownFcn'  , @pan_click,...
            'WindowButtonUpFcn'    , @pan_release,...
            'WindowButtonMotionFcn', @pan_motion);
        
    end
end