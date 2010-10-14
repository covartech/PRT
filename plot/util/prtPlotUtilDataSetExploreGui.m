function prtPlotUtilDataSetExploreGui(theObject)

ss = prtPlotUtilCurrentCursorScreenSize;

windowSize = [754 600];

% Center the window
sizePads = round((ss(3:4)-ss(1:2)+1-windowSize));
sizePads(1) = sizePads(1)/2; % We should use 2 right?
sizePads(2) = sizePads(2)/2;
pos = cat(2,sizePads+ss(1:2)-1,windowSize);

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

popUpStrs = theObject.getFeatureNames;

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
        h = plot(theObject,actualPlotDims);
        set(h,'HitTest','off');
        set(axisH,'ButtonDownFcn',@axisOnClick);
    end
    function explorerPopOut(myHandle,eventData) %#ok
        figure;
        actualPlotDims = plotDims(plotDims>=1);
        plot(theObject,actualPlotDims);
    end
    function axisOnClick(myHandle,eventData)
        actualPlotDims = plotDims(plotDims>=1);
        data = theObject.getFeatures(actualPlotDims);
        
        [rP,rD] = rotateDataAndClick(data);
        
        dist = prtDistanceEuclidean(rP,rD);
        [~,i] = min(dist);
        title(sprintf('Observation Closest To Last Click: %d',i));
        
        debug = false;
        if debug
            hold on;
            d = theObject.getObservations(i);
            switch length(actualPlotDims)
                case 2
                    plot(d(1),d(2),'kx');
                case 3
                    plot3(d(1),d(2),d(3),'kx');
            end
            hold off;
        end
    end
    
    function [rotatedData,rotatedClick] = rotateDataAndClick(data)
        %[rotatedData,rotatedClick] = rotateDataAndClick(data)
        % Used internally; from Click3dPoint from matlab central; need
        % copyright here.
        
        point = get(gca, 'CurrentPoint'); % mouse click position
        camPos = get(gca, 'CameraPosition'); % camera position
        camTgt = get(gca, 'CameraTarget'); % where the camera is pointing to
        
        camDir = camPos - camTgt; % camera direction
        camUpVect = get(gca, 'CameraUpVector'); % camera 'up' vector
        
        % build an orthonormal frame based on the viewing direction and the
        % up vector (the "view frame")
        zAxis = camDir/norm(camDir);
        upAxis = camUpVect/norm(camUpVect);
        xAxis = cross(upAxis, zAxis);
        yAxis = cross(zAxis, xAxis);
        
        rot = [xAxis; yAxis; zAxis]; % view rotation
        
        if size(data,2) < 3
            data = cat(2,data,zeros(size(data,1),1));
        end
        
        % the point cloud represented in the view frame
        rotatedData = (rot * data')';
        rotatedData = rotatedData(:,1:2);
        % the clicked point represented in the view frame
        rotatedClick = rot * point' ;
        rotatedClick = rotatedClick(1:2,1)';
    end
end