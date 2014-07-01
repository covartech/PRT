function prtPlotUtilAlgorithmGui(connectivityMatrix, actionCell, algo)
% Internal function, for PRT use only, makes use of GraphViz
% xxx NEED HELP xxx

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


% Given the algorithms action cell extract the names of each of the blocks
% Also add in Input and Output blocks
algoStr = cellfun(@(c)c.nameAbbreviation,actionCell,'uniformoutput',false);
algoStr = cat(1,{'Input'}, algoStr(:), {'Output'});
actionCell = cat(1,{[]},actionCell(:),{[]});

% Call GraphViz to get a good initial layout
GraphLayoutInfo = prtPlotUtilGraphVizRun(connectivityMatrix');

% Scale the GraphViz layout to get something reasonable
nodePosMat = cat(1,GraphLayoutInfo.Nodes.pos);
nodePosMat = bsxfun(@minus,nodePosMat,min(nodePosMat));
nodePosMat = bsxfun(@rdivide,nodePosMat,max(nodePosMat));
nodePosMat(isnan(nodePosMat))=0;

% Decide how big the blocks can reasonably be given the number of blocks
% we have to put in the unit square
minDistBetweenBlocks = min(min(prtDistanceLNorm(nodePosMat,nodePosMat,2) + realmax*eye(size(connectivityMatrix))));
blockSize = minDistBetweenBlocks*2/3;

% Because nodePosMat gives us the left corner we have to modify the block
% size a little
nodePosMat = bsxfun(@rdivide,nodePosMat,max(nodePosMat)+[blockSize blockSize]);

strLengths = cellfun(@(s)length(s),algoStr);

textSizes = blockSize./(strLengths+1)/0.7;
textSizes = ones(size(textSizes))*min(textSizes);
originalTextSizes = textSizes;
% Add one character for the sides
% 0.8 is an approximate to the aspect ratio of fonts.

% Get the block drawing options
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
    placeBlockFunction([], [], actionCell{iBlockOuter}, nodePosMat(iBlockOuter,:), iBlockOuter, algoStr{iBlockOuter}, textSizes(iBlockOuter));
end

for iEdge = 1:length(GraphLayoutInfo.Edges)
    startLoc = cat(2,nodePosMat(GraphLayoutInfo.Edges(iEdge).startIndex,1)+blockSize,nodePosMat(GraphLayoutInfo.Edges(iEdge).startIndex,2)+blockSize/2);
    stopLoc = cat(2,nodePosMat(GraphLayoutInfo.Edges(iEdge).stopIndex,1),nodePosMat(GraphLayoutInfo.Edges(iEdge).stopIndex,2)+blockSize/2);
    
    %Layout.edges(iEdge) = prtPlotUtilPlotArrow(cat(1,startLoc(1),stopLoc(1)),cat(1,startLoc(2),stopLoc(2)),[20 4]);
    %set(Layout.edges(iEdge),'facecolor',[0 0 0],'edgecolor',[0 0 0])
    
    Layout.edges(iEdge) = prtPlotUtilPlotArrow(cat(1,startLoc(1),stopLoc(1)),cat(1,startLoc(2),stopLoc(2)),[],'headWidth',0.01,'realHeadLength',0.01);
    
    
end

centerBlocks();

set(gcf,'NextPlot','new')

%% Begin Functions

    function patchWindowButtonMotion(hObject, eventData, blockIndex, offSet) %#ok
        cp = get(Handles.AxesPanel.mainAxes,'currentPoint');
        
        oldBlockPosition = get(Layout.Blocks(blockIndex).handle,'position');
        
        cp = cp - blockSize/2 + repmat(cat(2, offSet, 0),2,1);
        
        Layout.Blocks(blockIndex).polygonPosition = cp(1,1:2);
        
        set(Layout.Blocks(blockIndex).handle,'position',cat(2,cp(1,1:2),oldBlockPosition(3:4)));
        set(Layout.Blocks(blockIndex).textHandle,'Position',[cp(1,1)+Options.blockSize(2)/2 cp(1,2)+Options.blockSize(2)/2 0]);
        
        %Move Edges
        for jEdge = 1:length(GraphLayoutInfo.Edges)
            if blockIndex == GraphLayoutInfo.Edges(jEdge).startIndex || blockIndex == GraphLayoutInfo.Edges(jEdge).stopIndex
                
                startInd = GraphLayoutInfo.Edges(jEdge).startIndex;
                stopInd = GraphLayoutInfo.Edges(jEdge).stopIndex;
                
                cStart = get(Layout.Blocks(startInd).handle,'position');
                cStop = get(Layout.Blocks(stopInd).handle,'position');
                
                startLoc = cStart(1:2) + [blockSize blockSize/2];
                stopLoc = cStop(1:2) + [0 blockSize/2];
    
%                 try  %#ok<TRYNC>
%                     delete(Layout.edges(jEdge));
%                 end
%                 Layout.edges(jEdge) = prtPlotUtilPlotArrow(cat(1,startLoc(1),stopLoc(1)),cat(1,startLoc(2),stopLoc(2)));
                
                %Layout.edges(jEdge) = prtPlotUtilPlotArrow(cat(1,startLoc(1),stopLoc(1)),cat(1,startLoc(2),stopLoc(2)),[20 4]);
                %set(Layout.edges(jEdge),'facecolor',[0 0 0],'edgecolor',[0 0 0])
                
                Layout.edges(jEdge) = prtPlotUtilPlotArrow(cat(1,startLoc(1),stopLoc(1)),cat(1,startLoc(2),stopLoc(2)),Layout.edges(jEdge));
            end
        end
    end

    function patchButtonDownFunction(hObject, eventData, blockIndex) %#ok<INUSL>
        
        switch lower(get(Handles.handle, 'selectiontype'))
            case 'open'
                % Nothing for now
                BlockObject = Layout.Blocks(blockIndex).Object;
                if ~isempty(BlockObject) && BlockObject.isTrained && prtUtilIsMethodIncludeHidden(BlockObject,'plot') && BlockObject.dataSetSummary.nFeatures < 4
                    plot(BlockObject);
                elseif (blockIndex == length(Layout.Blocks)) && algo.isPlottableAsClassifier
                    plotAsClassifier(algo);
                end
                
            otherwise % case 'normal'
                
                % Get block clock offset
                cp = get(Handles.AxesPanel.mainAxes,'currentPoint');
                
                cPolyCorner = Layout.Blocks(blockIndex).polygonPosition;
                
                offSet = cPolyCorner + blockSize/2 - cp(1,1:2);
                
                set(Handles.handle,'WindowButtonMotionFcn',@(h,E)patchWindowButtonMotion(h,E, blockIndex, offSet));
                set(Handles.handle,'WindowButtonUpFcn',@(h,E)patchButtonUpFunction(h,E, blockIndex));
                set(Layout.Blocks(blockIndex).handle,'Selected','off')
        end
    end

    function patchButtonUpFunction(hObject, eventData, blockIndex)   %#ok<INUSL>
        set(Handles.handle,'WindowButtonMotionFcn',@mouseControlWindowButtonMotionFcn,...
                           'WindowButtonDownFcn'  , @mouseControlWindowButtonDownFcn,...
                           'WindowButtonUpFcn'    , @mouseControlWindowButtonUpFcn);
        Gui.status = '';
        
        set(Layout.Blocks(blockIndex).handle,'Selected','off')
    end

    function placeBlockFunction(hObject, eventData, BlockObject, position, iBlock, blockStr, textSize)  %#ok<INUSL>
        
        % Extract stuff from the options so that the GUI can use it
        if isempty(BlockObject)
            blockColor = Options.BlockColors.dataSet;
            textColor = Options.BlockTextColors.dataSet;
        elseif isa(BlockObject,'prtPreProc')
            blockColor = Options.BlockColors.preProcessor;
            textColor = Options.BlockTextColors.preProcessor;
        elseif isa(BlockObject,'prtFeatSel')
            blockColor = Options.BlockColors.featureSelector;
            textColor = Options.BlockTextColors.featureSelector;
        elseif isa(BlockObject,'prtClass')
            blockColor = Options.BlockColors.classifier;
            textColor = Options.BlockTextColors.classifier;
        elseif isa(BlockObject,'prtDecision')
            blockColor = Options.BlockColors.decision;
            textColor = Options.BlockTextColors.decision;
        elseif isa(BlockObject,'prtDecision')
            blockColor = Options.BlockColors.decision;
            textColor = Options.BlockTextColors.decision;
        elseif isa(BlockObject,'prtOutlierRemoval')
            blockColor = Options.BlockColors.outlierRemoval ;
            textColor = Options.BlockTextColors.outlierRemoval ;
        elseif isa(BlockObject,'prtCluster')
            blockColor = Options.BlockColors.cluster ;
            textColor = Options.BlockTextColors.cluster ;
        elseif isa(BlockObject,'prtRv')
            blockColor = Options.BlockColors.rv ;
            textColor = Options.BlockTextColors.rv ;
        else
            blockColor = [1 1 1];
            textColor = [0 0 0];
        end
        
        Layout.Blocks(iBlock).polygonPosition = position;
        Layout.Blocks(iBlock).handle = rectangle('Position',[position,blockSize,blockSize],'Curvature',[0.25, 0.25],'FaceColor',blockColor,'LineWidth',2);
        
        if (~isempty(BlockObject) && BlockObject.isTrained && prtUtilIsMethodIncludeHidden(BlockObject,'plot') && BlockObject.dataSetSummary.nFeatures < 4)
            %set(Layout.Blocks(iBlock).handle,'lineWidth',2,'EdgeColor',[1 1 0.1]);
            set(Layout.Blocks(iBlock).handle,'lineWidth',4);
        end
        
        if (iBlock == Layout.nBlocks) && algo.isPlottableAsClassifier
            set(Layout.Blocks(iBlock).handle,'lineWidth',4);
        end
        
        Layout.Blocks(iBlock).textHandle = text(position(1)+blockSize/2,position(2)+blockSize/2,blockStr,'VerticalAlignment','Middle','HorizontalAlignment','Center','Color',textColor,'FontUnits','Normalized','FontSize',textSize,'FontWeight','Bold');
        
        set(Layout.Blocks(iBlock).handle,'ButtonDownFcn',@(h,E)patchButtonDownFunction(h,E,iBlock));
        set(Layout.Blocks(iBlock).textHandle,'ButtonDownFcn',@(h,E)patchButtonDownFunction(h,E,iBlock));
        
        Layout.Blocks(iBlock).Object = BlockObject;
    end

    function mouseControlWindowScrollWheelZoomFcn(varargin)
        scrollAmountFactor = 50;
        
        if ~ishandle(Handles.handle)
            return
        end
        
        % current axes?
        if get(Handles.handle, 'currentaxes') ~= Handles.AxesPanel.mainAxes
            return
        end
        
        % get the amount of scolls
        scrolls = varargin{2}.VerticalScrollCount;
        
        % Get the axes' x- and y-limits
        xlim = get(Handles.AxesPanel.mainAxes, 'xlim'); 
        ylim = get(Handles.AxesPanel.mainAxes, 'ylim');
        
        % get the current camera position, and save the [z]-value
        cam_pos_Z = get(Handles.AxesPanel.mainAxes, 'cameraposition'); 
        cam_pos_Z = cam_pos_Z(3);
        
        % get the current point
        old_position = get(Handles.AxesPanel.mainAxes, 'CurrentPoint');
        old_position(1,3) = cam_pos_Z;
        
        % calculate zoom factor
        zoomfactor = 1 - scrolls/scrollAmountFactor; 
        
        % adjust camera position
        set(Handles.AxesPanel.mainAxes,...
            'cameratarget', [old_position(1, 1:2), 0],...
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
        set(Handles.AxesPanel.mainAxes, 'xlim', xlim)
        set(Handles.AxesPanel.mainAxes, 'ylim', ylim)
        
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
        
        % Resize the text since the block size has changed
        xRange = xlim(2)-xlim(1);
        yRange = ylim(2)-ylim(1);
        
        zoomFactorFromOriginal = max(xRange,yRange) ./ (Options.initialCanvasLimits(2)-Options.initialCanvasLimits(1));
        textSizes = 1./zoomFactorFromOriginal.*originalTextSizes;
        
        resizeText();
    end 


    function mouseControlWindowButtonDownFcn(varargin)
        % If we are not a handle get out of here
        if ~ishandle(Handles.handle)
            return
        end
        
        % current axes?
        if get(Handles.handle, 'currentaxes') ~= Handles.AxesPanel.mainAxes
            return
        end
        
        % perform appropriate action
        switch lower(get(Handles.handle, 'selectiontype'))
            % start panning on left click
            case 'normal'
                cp = get(Handles.AxesPanel.mainAxes, 'CurrentPoint');
                
                deselectEverything();
                % Clicking on back canvas Allow dragging around
                Gui.status = 'down';
                Gui.previous_point = cp;

            case 'open' % double click (left or right)
                centerBlocks();
                Gui.status = '';
        end
    end

    function mouseControlWindowButtonUpFcn(varargin)
        % double check if these axes are indeed the current axes
        if get(Handles.handle, 'currentaxes') ~= Handles.AxesPanel.mainAxes
            return
        end
        
        %deselectEverything();
        % reset Gui.status
        Gui.status = '';
    end

    % The primary mouse button controler
    function mouseControlWindowButtonMotionFcn(varargin)
        if ~ishandle(Handles.handle)
            return
        end
        
        % double check if these axes are indeed the current axes
        if get(Handles.handle, 'currentaxes') ~= Handles.AxesPanel.mainAxes
            return
        end
        % return if there isn't a previous point
        if isempty(Gui.previous_point)
            return
        end
        % return if mouse hasn't been clicked
        if isempty(Gui.status)
            return
        end
        % get current location (in pixels)
        current_point = get(Handles.AxesPanel.mainAxes, 'CurrentPoint');
        
        switch lower(Gui.status)
            case 'down'
                % get current XY-limits
                xlim = get(Handles.AxesPanel.mainAxes, 'xlim');
                ylim = get(Handles.AxesPanel.mainAxes, 'ylim');
                
                % find change in position
                delta_points = current_point - Gui.previous_point;
                % adjust limits
                new_xlim = xlim - delta_points(1);
                new_ylim = ylim - delta_points(3);
                % set new limits
                set(Handles.AxesPanel.mainAxes, 'Xlim', new_xlim); set(Handles.AxesPanel.mainAxes, 'Ylim', new_ylim);
                % save new position
                Gui.previous_point = get(Handles.AxesPanel.mainAxes, 'CurrentPoint');
            otherwise % Window motion without anything going on
        end
    end

    function deselectEverything()
        for iBlock = 1:Layout.nBlocks
            set(Layout.Blocks(iBlock).handle,'Selected','off');
        end
    end

    function centerBlocks()
        if Layout.nBlocks == 0
            xLims = Options.initialCanvasLimits(1:2);
            yLims = Options.initialCanvasLimits(3:4);
            Options.blockFontSizeNormalized = Options.initialBlockFontSizeNormalized;
            
            xlim(xLims)
            ylim(yLims);
            
            return
        end
        
        xLims = [inf -inf];
        yLims = [inf -inf];
        for iBlock = 1:Layout.nBlocks
            maxPos = Layout.Blocks(iBlock).polygonPosition + blockSize;
            minPos = Layout.Blocks(iBlock).polygonPosition;
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
        
        zoomFactorFromOriginal = max(xRange,yRange) ./ (Options.initialCanvasLimits(2)-Options.initialCanvasLimits(1));
        textSizes = 1./zoomFactorFromOriginal.*originalTextSizes;
        resizeText();
        
        xlim(xLims)
        ylim(yLims);
    end

    function resizeText
        for iBlock = 1:Layout.nBlocks
            set(Layout.Blocks(iBlock).textHandle,'FontSize',textSizes(iBlock));
        end
    end

%     function blockInd = findBlockClick(cp)
%         blockInd = [];
%         for iBlock = 1:Layout.nBlocks
%             isInThisBlock = all(cp(1,1:2) < max(Layout.Blocks(iBlock).polygonNodes) & cp(1,1:2) > min(Layout.Blocks(iBlock).polygonNodes));
%             if isInThisBlock
%                 blockInd = iBlock;
%                 
%                 return
%             end
%         end
%     end


    function Options = localGetOptions()
        
        colors = prtPlotUtilClassColors(7);
        
        Options.initialCanvasLimits = [-0.1 1.1 -0.1 1.1];
        Options.blockSize = blockSize*[1 1];
        Options.initialBlockFontSizeNormalized = 0.03; %This is the default relative to the initialCanvas limits
        Options.blockFontSizeNormalized = Options.initialBlockFontSizeNormalized; %It can change as a function of the zoom level.
        
        Options.BlockColors.dataSet = [0.8 0.8 0.8];
        Options.BlockColors.preProcessor = colors(1,:);
        Options.BlockColors.featureSelector = colors(2,:);
        Options.BlockColors.classifier = colors(3,:);
        Options.BlockColors.decision = colors(4,:);
        Options.BlockColors.outlierRemoval = colors(5,:);
        Options.BlockColors.cluster = colors(6,:);
        Options.BlockColors.rv = colors(7,:);
        
        Options.BlockTextColors.dataSet = [0 0 0];
        Options.BlockTextColors.preProcessor = [1 1 1];
        Options.BlockTextColors.featureSelector = [1 1 1];
        Options.BlockTextColors.classifier = [1 1 1];
        Options.BlockTextColors.decision = [0 0 0];
        Options.BlockTextColors.rv = [0 0 0];
        Options.BlockTextColors.outlierRemoval = [1 1 1];
        Options.BlockTextColors.cluster = [1 1 1];
        
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
        MainFigure.NumberTitle = 'Off';
        MainFigure.Menu = 'none';
        MainFigure.toolbar = 'none';
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
        
        % define zooming with scrollwheel, and panning with mouseclicks
        set(Handles.handle, 'WindowScrollWheelFcn' , @mouseControlWindowScrollWheelZoomFcn,...
            'WindowButtonDownFcn'  , @mouseControlWindowButtonDownFcn,...
            'WindowButtonUpFcn'    , @mouseControlWindowButtonUpFcn,...
            'WindowButtonMotionFcn', @mouseControlWindowButtonMotionFcn);
        
    end
end
