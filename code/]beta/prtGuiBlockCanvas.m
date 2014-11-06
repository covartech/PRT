function prtGuiBlockCanvas

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


Options.initialCanvasLimits = [0 1 0 1];
Options.blockSize = 0.1*[1 1]; 
Options.initialBlockFontSizeNormalized = 0.03; %This is the default relative to the initialCanvas limits
Options.blockFontSizeNormalized = Options.initialBlockFontSizeNormalized; %It can change as a function of the zoom level.
Options.blockHoverEdgeColor = [0.8 0.8 0.8];
Options.blockHoverTextColor = [0.8 0.8 0.8];
Options.BlockColors.preProcessor = [1 0.8 0.6];
Options.BlockColors.featureSelector = [0.6 1 0.8];
Options.BlockColors.classifier = [0.7 0.7 1];

Handles.handle = figure('Units','Pixels','position',[390 331 820 615],'MenuBar','figure','DockControls','off');

% Make the toolbox on the left side
Handles.ToolboxPanel.handle = uipanel(Handles.handle,'Units','Normalized','Position',[0 0 0.25 1]);
Handles.ToolboxPanel.Tabs.handle = uitabgroup('v0', 'parent', Handles.ToolboxPanel.handle);
Handles.ToolboxPanel.Tabs.PreProcessors.handle = uitab('v0', Handles.ToolboxPanel.Tabs.handle,'title','Pre-Proc');
Handles.ToolboxPanel.Tabs.FeatureSelectors.handle = uitab('v0', Handles.ToolboxPanel.Tabs.handle,'title','Feat. Sel.');
Handles.ToolboxPanel.Tabs.Classifiers.handle = uitab('v0', Handles.ToolboxPanel.Tabs.handle,'title','Class.');

% Pre-processors
Handles.ToolboxPanel.Tabs.PreProcessors.zmuv = uicontrol(Handles.ToolboxPanel.Tabs.PreProcessors.handle, 'Style', 'Toggle', 'callback', @(h,o)placeBlockCallback(h,o,prtPreProcZmuv), 'Units','Normalized', 'Position',[0.1 0.85 0.8 0.0975],'String','ZMUV');

% Feature Selectors
Handles.ToolboxPanel.Tabs.FeatureSelectors.sfs = uicontrol(Handles.ToolboxPanel.Tabs.FeatureSelectors.handle, 'Style', 'Toggle', 'callback', @(h,o)placeBlockCallback(h,o,prtFeatSelSfs), 'Units','Normalized', 'Position',[0.1 0.85 0.8 0.0975],'String','SFS');

% Classifiers
Handles.ToolboxPanel.Tabs.Classifiers.dlrt = uicontrol(Handles.ToolboxPanel.Tabs.Classifiers.handle, 'Style', 'Toggle', 'callback', @(h,o)placeBlockCallback(h,o,prtClassDlrt), 'Units','Normalized', 'Position',[0.1 0.85 0.8 0.0975],'String','DLRT');
Handles.ToolboxPanel.Tabs.Classifiers.fld = uicontrol(Handles.ToolboxPanel.Tabs.Classifiers.handle, 'Style', 'Toggle', 'callback', @(h,o)placeBlockCallback(h,o,prtClassFld), 'Units','Normalized', 'Position',[0.1 0.75 0.8 0.0975],'String','FLD');
Handles.ToolboxPanel.Tabs.Classifiers.knn = uicontrol(Handles.ToolboxPanel.Tabs.Classifiers.handle, 'Style', 'Toggle', 'callback', @(h,o)placeBlockCallback(h,o,prtClassKnn), 'Units','Normalized', 'Position',[0.1 0.65 0.8 0.0975],'String','KNN');
Handles.ToolboxPanel.Tabs.Classifiers.logDisc = uicontrol(Handles.ToolboxPanel.Tabs.Classifiers.handle, 'Style', 'Toggle', 'callback', @(h,o)placeBlockCallback(h,o,prtClassLogisticDiscriminant), 'Units','Normalized', 'Position',[0.1 0.55 0.8 0.0975],'String','LogDisc');
Handles.ToolboxPanel.Tabs.Classifiers.rvm = uicontrol(Handles.ToolboxPanel.Tabs.Classifiers.handle, 'Style', 'Toggle', 'callback', @(h,o)placeBlockCallback(h,o,prtClassRvm), 'Units','Normalized', 'Position',[0.1 0.45 0.8 0.0975],'String','RVM');

% Make the axes
Handles.AxesPanel.handle = uipanel(Handles.handle,'Units','Normalized','Position',[0.25 0 0.75 1]);
Handles.AxesPanel.mainAxes = axes('parent',Handles.AxesPanel.handle,'Units','Normalized','Position',[0 0 1 1],'XTick',[],'YTick',[],'XLim',Options.initialCanvasLimits(1:2),'YLim',Options.initialCanvasLimits(3:4),'NextPlot','add');

Handles.Hover.plotHandle = patch(nan(4,1),nan(4,1),[0.95 0.95 0.95],'EdgeColor',Options.blockHoverEdgeColor);
Handles.Hover.textHandle = text(0,0,'NAME','color',Options.blockHoverTextColor,'VerticalAlignment','Top','HorizontalAlignment','Center','FontUnits','Normalized','FontSize',Options.blockFontSizeNormalized,'HitTest','off');

SelectedBlockInfo = [];

% Ready the outputs
BlankBlock = struct('handle',[],'textHandle',[], 'Options',[]);
Layout.nBlocks = 0;
Layout.Blocks = BlankBlock;
Layout.Connectivity = false(0);


Gui.status = '';
Gui.previous_point = [];

Gui.original_xlim = get(Handles.AxesPanel.mainAxes, 'xlim');
Gui.original_ylim = get(Handles.AxesPanel.mainAxes, 'ylim');

% define zooming with scrollwheel, and panning with mouseclicks
set(Handles.handle, 'WindowScrollWheelFcn' , @scroll_zoom,...
                    'WindowButtonDownFcn'  , @pan_click,...
                    'WindowButtonUpFcn'    , @pan_release,...
                    'WindowButtonMotionFcn', @pan_motion,...
                    'KeyPressFcn',@windowKeyPressFun);
                
    function windowKeyPressFun(hObject, eventData)
        if strcmp(eventData.Key,'delete')
            % Delete Selected Blocks
            isSelected = false(Layout.nBlocks,1);
            for iBlock = 1:Layout.nBlocks
                isSelected(iBlock) = strcmp(get(Layout.Blocks(iBlock).handle,'selected'),'on');
            end
            isSelected = find(isSelected);
            for iSelected = 1:length(isSelected)
                delete(Layout.Blocks(isSelected(iSelected)).handle);
                isSelected = isSelected - 1;
            end
        end
    end
                    
    function placeBlockCallback(hObject, eventData, BlockObj) %#ok
        
        SelectedBlockInfo.abbreviation = BlockObj.nameAbbreviation;
        
        % Extract stuff from the options so that the GUI can use it
        if isa(BlockObj,'prtPreProc')
            SelectedBlockInfo.blockColor = Options.BlockColors.preProcessor;
        elseif isa(BlockObj,'prtFeatSel')
            SelectedBlockInfo.blockColor = Options.BlockColors.featureSelector;
        elseif isa(BlockObj,'prtClass')
            SelectedBlockInfo.blockColor = Options.BlockColors.classifier;
        else
                error('Unsupported Block Type');
        end                

        if get(hObject,'value') % Recently turned on
            % Turn on the button placement
            set(Handles.handle,'WindowButtonMotionFcn',@(h,o)figWindowButtonMotionFcnPlaceBlock(h,o,BlockObj));
            set(Handles.Hover.plotHandle,'ButtonDownFcn',@(h,o)buttonDownFcnPlaceBlock(h,o,BlockObj, hObject));
        else
            % Turn off / cancel the button placement
            set(Handles.handle,'WindowScrollWheelFcn' , @scroll_zoom,...
                'WindowButtonDownFcn'  , @pan_click,...
                'WindowButtonUpFcn'    , @pan_release,...
                'WindowButtonMotionFcn', @pan_motion);
            set(Handles.Hover.plotHandle,'ButtonDownFcn',[]);
            set(Handles.Hover.plotHandle,'XData',nan(4,1),'YData',nan(4,1));
            set(Handles.Hover.textHandle,'color',[1 1 1]);
        end
        
    end

    function figWindowButtonMotionFcnPlaceBlock(hObject, eventData, BlockObj) %#ok
        cp = get(Handles.AxesPanel.mainAxes,'currentPoint');
        cColor = min(SelectedBlockInfo.blockColor+0.2,0.95);
        
        set(Handles.Hover.plotHandle,'XData',Options.blockSize(1)/2*[-1 -1 1 1 -1] + cp(1,1), 'YData',Options.blockSize(2)/2*[-1 1 1 -1 -1] + cp(1,2),'EdgeColor',[0.8 0.8 0.8],'FaceColor',cColor );
        set(Handles.Hover.textHandle,'Position',[cp(1,1) cp(1,2)+Options.blockSize(2)/2 0],'String',SelectedBlockInfo.abbreviation,'color',[0.8 0.8 0.8]);
        %set(Handles.AxesPanel.mainAxes,'XLim',Options.initialCanvasLimits(1:2),'YLim',Options.initialCanvasLimits(3:4));
        
    end

    function buttonDownFcnPlaceBlock(hObject, eventData, BlockOptions, buttonHandle) %#ok
        Layout.nBlocks = Layout.nBlocks + 1;
        cX = get(Handles.Hover.plotHandle,'XData');
        cY = get(Handles.Hover.plotHandle,'YData');
        
        Layout.Blocks(Layout.nBlocks).polygonNodes = [cX, cY];
        Layout.Blocks(Layout.nBlocks).handle = patch(cX, cY, SelectedBlockInfo.blockColor);
        Layout.Blocks(Layout.nBlocks).textHandle = text(mean(cX(2:3)),max(cY),SelectedBlockInfo.abbreviation,'VerticalAlignment','Top','HorizontalAlignment','Center','Color',[0 0 0],'FontUnits','Normalized','FontSize',Options.blockFontSizeNormalized);
        
        %set(Handles.AxesPanel.mainAxes,'XLim',Options.initialCanvasLimits(1:2),'YLim',Options.initialCanvasLimits(3:4));
        Layout.Blocks(Layout.nBlocks).Options = BlockOptions;
        
        % Turn off / cancel the button placement
        set(buttonHandle,'value',0)
        set(Handles.handle,'WindowScrollWheelFcn' , @scroll_zoom,...
            'WindowButtonDownFcn'  , @pan_click,...
            'WindowButtonUpFcn'    , @pan_release,...
            'WindowButtonMotionFcn', @pan_motion);
        set(Handles.Hover.plotHandle,'ButtonDownFcn',[]);
        set(Handles.Hover.plotHandle,'XData',nan(4,1),'YData',nan(4,1));
        set(Handles.Hover.textHandle,'color',[1 1 1]);
        
        set(Layout.Blocks(Layout.nBlocks).handle,'DeleteFcn',@(h,o)blockDeleteFcn(h,o),'HitTest','on');
        %set(Layout.Blocks(Layout.nBlocks).textHandle,'DeleteFcn',@(h,o)blockTextDeleteFcn(h,o,Layout.nBlocks),'HitTest','on');
    end

    function blockDeleteFcn(hObject, eventData) %#ok
        if ~ishandle(Handles.handle)
            return
        end
        
        blockInd = find(arrayfun(@(h)isequal(hObject,h),cat(1,Layout.Blocks.handle)));
        
        if ishandle(Layout.Blocks(blockInd).textHandle)
            delete(Layout.Blocks(blockInd).textHandle)
        end
        Layout.Blocks(blockInd) = [];
        Layout.nBlocks = Layout.nBlocks - 1;
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
                    % Double clicking on a block
                    msgbox(sprintf('This would be a %s options editing GUI.',get(Layout.Blocks(blockInd).textHandle,'string')),'Options Edtior Placeholder','Modal');
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
            case 'block'
                cX = Options.blockSize(1)/2*[-1 -1 1 1 -1] + current_point(1,1);
                cY = Options.blockSize(2)/2*[-1 1 1 -1 -1] + current_point(1,2);
                set(Layout.Blocks(Gui.blockInd).handle,'XData',cX, 'YData',cY);
                set(Layout.Blocks(Gui.blockInd).textHandle,'Position',[current_point(1,1) current_point(1,2)+Options.blockSize(2)/2 0]);
                Layout.Blocks(Gui.blockInd).polygonNodes = [cX(:) cY(:)];
        
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
        edgePadPercent = 0.2;
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
        initRange = Options.initialCanvasLimits(2)-Options.initialCanvasLimits(1);
        if xRange < initRange 
            xLims = (initRange-xRange)/2*[-1 1] + xLims;
            yLims = (initRange-xRange)/2*[-1 1] + yLims;
            xRange = initRange;
            yRange = initRange;
        end
        
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
end
