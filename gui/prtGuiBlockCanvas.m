function prtGuiBlockCanvas

Options.initialCanvasLimits = [0 1 0 1];
Options.blockSize = 0.25*[1 1]; 
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
Handles.ToolboxPanel.Tabs.PreProcessors.zmuv = uicontrol(Handles.ToolboxPanel.Tabs.PreProcessors.handle, 'Style', 'Toggle', 'callback', @(h,o)placeBlackCallback(h,o,prtPreProcOptZmuv), 'Units','Normalized', 'Position',[0.1 0.85 0.8 0.0975],'String','ZMUV');

% Feature Selectors
Handles.ToolboxPanel.Tabs.FeatureSelectors.sfs = uicontrol(Handles.ToolboxPanel.Tabs.FeatureSelectors.handle, 'Style', 'Toggle', 'callback', @(h,o)placeBlackCallback(h,o,prtFeatSelOptSfs), 'Units','Normalized', 'Position',[0.1 0.85 0.8 0.0975],'String','SFS');

% Classifiers
Handles.ToolboxPanel.Tabs.Classifiers.dlrt = uicontrol(Handles.ToolboxPanel.Tabs.Classifiers.handle, 'Style', 'Toggle', 'callback', @(h,o)placeBlackCallback(h,o,prtClassOptDlrt), 'Units','Normalized', 'Position',[0.1 0.85 0.8 0.0975],'String','DLRT');
Handles.ToolboxPanel.Tabs.Classifiers.fld = uicontrol(Handles.ToolboxPanel.Tabs.Classifiers.handle, 'Style', 'Toggle', 'callback', @(h,o)placeBlackCallback(h,o,prtClassOptFld), 'Units','Normalized', 'Position',[0.1 0.75 0.8 0.0975],'String','FLD');
Handles.ToolboxPanel.Tabs.Classifiers.knn = uicontrol(Handles.ToolboxPanel.Tabs.Classifiers.handle, 'Style', 'Toggle', 'callback', @(h,o)placeBlackCallback(h,o,prtClassOptKnn), 'Units','Normalized', 'Position',[0.1 0.65 0.8 0.0975],'String','KNN');
Handles.ToolboxPanel.Tabs.Classifiers.logDisc = uicontrol(Handles.ToolboxPanel.Tabs.Classifiers.handle, 'Style', 'Toggle', 'callback', @(h,o)placeBlackCallback(h,o,prtClassOptLogDisc), 'Units','Normalized', 'Position',[0.1 0.55 0.8 0.0975],'String','LogDisc');
Handles.ToolboxPanel.Tabs.Classifiers.rvm = uicontrol(Handles.ToolboxPanel.Tabs.Classifiers.handle, 'Style', 'Toggle', 'callback', @(h,o)placeBlackCallback(h,o,prtClassOptRvm), 'Units','Normalized', 'Position',[0.1 0.45 0.8 0.0975],'String','RVM');

% Make the axes
Handles.AxesPanel.handle = uipanel(Handles.handle,'Units','Normalized','Position',[0.25 0 0.75 1]);
Handles.AxesPanel.mainAxes = axes('parent',Handles.AxesPanel.handle,'Units','Normalized','Position',[0 0 1 1],'XTick',[],'YTick',[],'XLim',Options.initialCanvasLimits(1:2),'YLim',Options.initialCanvasLimits(3:4),'NextPlot','add');

Handles.Hover.plotHandle = patch(nan(4,1),nan(4,1),[0.95 0.95 0.95],'EdgeColor',[0.8 0.8 0.8]);
Handles.Hover.textHandle = text(0,0,'NAME','color',[1 1 1],'VerticalAlignment','Top','HorizontalAlignment','Center');

SelectedBlockInfo = [];

% Ready the outputs
BlankBlock = struct('handle',[],'textHandle',[], 'Options',[]);
Layout.nBlocks = 0;
Layout.Blocks = BlankBlock;
Layout.Connectivity = false(0);

    function placeBlackCallback(hObject, eventData, BlockOptions)
        
        % Extract stuff from the options so that the GUI can use it
        switch BlockOptions.Private.PrtObjectType
            case 'preProcessor'
                SelectedBlockInfo.blockColor = Options.BlockColors.preProcessor;
                SelectedBlockInfo.abbreviation = BlockOptions.Private.preProcessAbbreviation;
            case 'featureSelector'
                SelectedBlockInfo.blockColor = Options.BlockColors.featureSelector;
                SelectedBlockInfo.abbreviation = BlockOptions.Private.featureSelectionAbbreviation;
            case 'classifier' 
                SelectedBlockInfo.blockColor = Options.BlockColors.classifier;
                SelectedBlockInfo.abbreviation = BlockOptions.Private.classifierNameAbbreviation;
            otherwise
                error('Unsupported Block Type');
        end

        if get(hObject,'value') % Recently turned on
            % Turn on the button placement
            set(Handles.handle,'WindowButtonMotionFcn',@(h,o)figWindowButtonMotionFcnPlaceBlock(h,o,BlockOptions));
            set(Handles.Hover.plotHandle,'ButtonDownFcn',@(h,o)buttonDownFcnPlaceBlock(h,o,BlockOptions, hObject));
        else
            % Turn off / cancel the button placement
            set(Handles.handle,'WindowButtonMotionFcn',[]);
            set(Handles.Hover.plotHandle,'ButtonDownFcn',[]);
            set(Handles.Hover.plotHandle,'XData',nan(4,1),'YData',nan(4,1));
            set(Handles.Hover.textHandle,'color',[1 1 1]);
        end
        
    end

    function figWindowButtonMotionFcnPlaceBlock(hObject, eventData, BlockOptions)
        cp = get(Handles.AxesPanel.mainAxes,'currentPoint');
        cColor = min(SelectedBlockInfo.blockColor+0.2,0.95);
        
        set(Handles.Hover.plotHandle,'XData',Options.blockSize(1)/2*[-1 -1 1 1 -1] + cp(1,1), 'YData',Options.blockSize(2)/2*[-1 1 1 -1 -1] + cp(1,2),'EdgeColor',[0.8 0.8 0.8],'FaceColor',cColor );
        set(Handles.Hover.textHandle,'Position',[cp(1,1) cp(1,2)+Options.blockSize(2)/2 0],'String',SelectedBlockInfo.abbreviation,'color',[0.8 0.8 0.8]);
        set(Handles.AxesPanel.mainAxes,'XLim',Options.initialCanvasLimits(1:2),'YLim',Options.initialCanvasLimits(3:4));
        
    end

    function buttonDownFcnPlaceBlock(hObject, eventData, BlockOptions, buttonHandle)
        Layout.nBlocks = Layout.nBlocks + 1;
        cX = get(Handles.Hover.plotHandle,'XData');
        cY = get(Handles.Hover.plotHandle,'YData');
        
        Layout.Blocks(Layout.nBlocks).handle = patch(cX, cY, SelectedBlockInfo.blockColor);
        Layout.Blocks(Layout.nBlocks).textHandle = text(mean(cX(2:3)),max(cY),SelectedBlockInfo.abbreviation,'VerticalAlignment','Top','HorizontalAlignment','Center','Color',[0 0 0]);
        
        set(Handles.AxesPanel.mainAxes,'XLim',Options.initialCanvasLimits(1:2),'YLim',Options.initialCanvasLimits(3:4));
        Layout.Blocks(Layout.nBlocks).Options = BlockOptions;
        
        % Turn off / cancel the button placement
        set(buttonHandle,'value',0)
        set(Handles.handle,'WindowButtonMotionFcn',[]);
        set(Handles.Hover.plotHandle,'ButtonDownFcn',[]);
        set(Handles.Hover.plotHandle,'XData',nan(4,1),'YData',nan(4,1));
        set(Handles.Hover.textHandle,'color',[1 1 1]);
    end
end