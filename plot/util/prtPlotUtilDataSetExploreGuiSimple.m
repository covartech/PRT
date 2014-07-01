function prtPlotUtilDataSetExploreGuiSimple(theObject,parent)
% Internal function, 
% xxx Need Help xxx - see prtDataSetClass.explore

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

if nargin == 1
    windowSize = [754 600];
    pos = prtPlotUtilCenterFigure(windowSize);
    
    % Create the figure an UIControls
    figH = figure('Name','PRT Data Set Explorer','Menu','none','toolbar','figure','units','pixels','position',pos,'DockControls','off');
    try
        set(figH,'Number','Off');
    catch
        try
            set(figH,'NumberTitle','off');
        end
    end
    
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
    bgc = get(figH,'Color');
else
    bgc = get(gcf,'Color');
    figH = parent;
end

popUpStrs = theObject.getFeatureNames;
popUpStrs = popUpStrs(:);

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
        obsName = theObject.getObservationNames(i);
        title(sprintf('Observation Closest To Last Click: %s',obsName{1}));
        
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
        % Used internally; from Click3dPoint from matlab central; Copyright
        % follows
        
        %         Copyright (c) 2009, Babak Taati
        % All rights reserved.
        %
        % Redistribution and use in source and binary forms, with or without
        % modification, are permitted provided that the following conditions are
        % met:
        %
        %     * Redistributions of source code must retain the above copyright
        %       notice, this list of conditions and the following disclaimer.
        %     * Redistributions in binary form must reproduce the above copyright
        %       notice, this list of conditions and the following disclaimer in
        %       the documentation and/or other materials provided with the distribution
        %
        % THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
        % AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
        % IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
        % ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
        % LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
        % CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
        % SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
        % INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
        % CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
        % ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
        % POSSIBILITY OF SUCH DAMAGE.
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
