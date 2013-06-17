% clear classes
% WaitObj = prtUtilProgressBar(0,'Wait some seconds ...','reset',true,'allowStop',true);
% for p=0:0.01:1
%     pause(0.01);
%     WaitObj.update(p);
%     if WaitObj.isCanceled
%         WaitObj.close();
%         break
%     end
% end
% 
% %%
% clear classes
% WaitObj = prtUtilProgressBar(0,'Wait some seconds ...','autoClose',false,'reset',true);
% WaitObj2 = prtUtilProgressBar(0,'Wait some more seconds ...','autoClose',false);
% for p=0:0.1:1
%     WaitObj.update(p);
%     for q=0:0.05:1
%         WaitObj2.update(q);
%         pause(0.001);
%     end
% end
% WaitObj.closeAll();
% 
% %%
% 
% clear classes
% WaitObj = prtUtilProgressBar(0,'Wait some seconds ...','autoClose',false,'reset',true,'allowStop',true);
% WaitObj2 = prtUtilProgressBar(0,'Wait some more seconds ...','autoClose',false);
% for p=0:0.1:1
%     WaitObj.update(p);
%     for q=0:0.051:1
%         WaitObj2.update(q);
%         pause(0.001);
%     end
%     if WaitObj.isCanceled
%         WaitObj.closeAll();
%         break
%     end
% end
% WaitObj.closeAll();
% 

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




classdef prtUtilProgressBar
    properties
        titleStr = 'Progress...';
        autoClose = true;
        reset = false;
    end
    
    properties (SetAccess = protected)
        figureHandle = [];
    end
    
    properties (Dependent = true)
        isCanceled
    end
    
    properties (SetAccess = private, GetAccess = private, Hidden = true)
        isCanceledLocal = false;
    end
    
    properties (Hidden = true)
        allowStop = false;
        isDead = false;
        globalTitleStr = '-auto';
        
        barIndex  % Used internally
        
        % Restricted update parameters
        minTimeBetweenUpdates = 0.2; % in seconds
        minPercentBetweenUpdates = 0; % in percent [0 100] (0 ignores this)
    end
    
    properties (Constant = true, GetAccess = protected);
        % Graphics parameters
        windowWidth = 512;
        windowHorzMargin = 16; % On both sides
        windowTopMargin = 24;  % Distance between top of window and top of top bar;
        windowBottomMargin = 16; % Distance between bottom of window and bottom cancel button
        
        barBackgroundColor = [1 1 1];
        barForegroundColor = [0.2157    0.4941    0.7216];
        
        barWidthMin = 0.1;
        barHeight = 22;
        barVertMargin = 24;
        titleTextMargin = 8;
        
        cancelButtonHeight = 36;
        cancelButtonVertMargin = 16; % Distance between top of cancel button and bottom of first bar
        cancelButtonWidth = 176;
        
        textHorzMargin = 4;
        
        % Time Estimate Smoothing
        nSamplesForTimeEstSmoothing = 25;
    end
    
    methods
        function Obj = set.isCanceled(Obj,val)
            Obj.isCanceledLocal = val;
        end
        function val = get.isCanceled(Obj)
            
            
            if ishandle(Obj.figureHandle)
                myFig = Obj.figureHandle;
                ud = get(myFig,'userdata');
                
                if ~isempty(ud) && isfield(ud,'prtUtilProgressBarIsCanceled')
                    val = (Obj.allowStop && ud.prtUtilProgressBarIsCanceled) || Obj.isCanceledLocal;
                else
                    val = false;
                end
                
                prtUtilProgressBarData = guidata(Obj.figureHandle);
                if ~isempty(prtUtilProgressBarData)
                    
                else
                    val = false;
                end
            else
                val = false;
            end
            
%             if ishandle(Obj.figureHandle)
%                 prtUtilProgressBarData = guidata(Obj.figureHandle);
%                 if ~isempty(prtUtilProgressBarData)
%                     val = (Obj.allowStop && prtUtilProgressBarData.isCanceled) || Obj.isCanceledLocal;
%                 else
%                     val = false;
%                 end
%             else
%                 val = false;
%             end
        end
        
        function Obj = prtUtilProgressBar(percentage,titleStr,varargin)
            %Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            if nargin < 1
                percentage = 0;
            end
            if nargin > 1
                Obj.titleStr = titleStr;
            end
            
            Obj = prtUtilAssignStringValuePairs(Obj, varargin{:});
            
            % Attempt to locate parent
            oldHandleVisilibity = get(0,'ShowHiddenHandles');
            set(0,'ShowHiddenHandles','on');
            oldFigureHandle = findobj('tag','PrtProgressBar','HandleVisibility','off');
            set(0,'ShowHiddenHandles',oldHandleVisilibity);
            
            if Obj.reset && ~isempty(oldFigureHandle)
                close(oldFigureHandle)
                oldFigureHandle = [];
            end
            
            if isempty(oldFigureHandle)
                % No existing prtUtilProgressBar windows open
                Obj.barIndex = 1;
            
                Obj = Obj.createWindow();
                Obj = Obj.addBar();
            
            else
                % There is a prtUtilProgressBar window open
                % We want to tack into that
                
                Obj.figureHandle = oldFigureHandle;
                
                prtProgressBarData = guidata(Obj.figureHandle);
                Obj.barIndex = prtProgressBarData.nBars + 1;
                
                Obj = Obj.addBar();
            end
            
            Obj.update(percentage); % Actually update the bars so that we can initialize partially done
        end
        function Obj = update(Obj, percentage)
            assert(numel(percentage)==1 &&  ~(percentage > 1+eps || percentage < -eps),'prt:prtUtilProgressBar','progress must be a scalar percentage in the range [0 1]');
            
            if  Obj.isCanceled || Obj.isDead || ~ishandle(Obj.figureHandle) || strcmpi(get(Obj.figureHandle,'BeingDeleted'),'on')
                Obj.isCanceled = true;
                Obj.isDead = false;
                return
            end
            
            % Must get bar structure from figure's guidata
            prtUtilProgressBarData = guidata(Obj.figureHandle);

            if Obj.barIndex > prtUtilProgressBarData.nBars
                % We deleted at least one bar (possibly through auto close 
                % We gotta create a new bar(s)
                
                nBarsNeeded = Obj.barIndex-prtUtilProgressBarData.nBars;
                for iNewBar = 1:nBarsNeeded
                    Obj = addBar(Obj);
                end
                Obj.update(percentage);
                return;
            end
                
            bar = prtUtilProgressBarData.bars(Obj.barIndex);
            
            % Get Current time with seconds = 1 instead of days = 1 like
            % now() provides
            currentTime = 86400*now();
            
            bar.percentage = percentage;
            
            % We only want to store times and percentages if the
            % percentages are different than the last time we saved.
            % Store iteration times and percentages
            if bar.lastIterationsPercentages(end) ~= percentage
                % An actual change occured for this bar
                if bar.percentage == 0
                    % Much like Donnie we have no frame of reference
                    bar.lastIterationsTimes(:) = nan;
                    bar.lastIterationsPercentages(:) = 0;
                    bar.startTime = currentTime;
                    bar.estimatedRemainingTime = Inf;
                else
                    bar.lastIterationsTimes = circshift(bar.lastIterationsTimes,[0 -1]);
                    bar.lastIterationsTimes(end) = currentTime;
                    
                    bar.lastIterationsPercentages = circshift(bar.lastIterationsPercentages,[0 -1]);
                    bar.lastIterationsPercentages(end) = percentage;
                end
            end
            
            % Update Patch position
            cPatchPosition = get(bar.foregroundPatchHandle,'Position');
            totalPatchArea = Obj.windowWidth-cPatchPosition(1)*2; % assumes equal x margin on both sides, which is currently true
                
            % Update Bar
            set(bar.foregroundPatchHandle,'Position',[cPatchPosition(1:2), min(max(0.1,totalPatchArea*percentage),totalPatchArea), cPatchPosition(4)]);
            
            % Update title string (sub title)
            set(bar.topTextHandle,'string',Obj.titleStr);
            
            % Update texts
            if sum(isfinite(bar.lastIterationsTimes)) == 1
                % First update with percetage > 0
                % Must reference start time instead of previously saved
                % iteration times
                timeChanges = currentTime - bar.startTime;
                percentChanges = percentage;
            else
                timeChanges = diff(bar.lastIterationsTimes);
                percentChanges = diff(bar.lastIterationsPercentages);
            end
            
            % Remove negative steps...
            percentChanges = percentChanges(percentChanges>=0);
            timeChanges = timeChanges(percentChanges>=0);
            
            % Based on the current percentages and the back log of
            % percentages estime the time remaining
                 
            estimatedTimesPerPercent = timeChanges./percentChanges;
            estimatedSecondsPerPercent = prtUtilNanMean(estimatedTimesPerPercent(~isnan(estimatedTimesPerPercent)));
            
            if isempty(estimatedSecondsPerPercent)
                estimatedRemainingTimeInSeconds = inf;
            else
                estimatedRemainingTimeInSeconds = round(estimatedSecondsPerPercent*(1-percentage));
            end
            
            if abs(estimatedRemainingTimeInSeconds-bar.estimatedRemainingTime) > 0.75 % Only update if we differ significantly. This eliminates jitter.
                bar.estimatedRemainingTime = estimatedRemainingTimeInSeconds;
                
                timeDifferentials = currentTime - cat(1,prtUtilProgressBarData.bars.timeLastGraphicsUpdate);
                remainingTimes = cat(1,prtUtilProgressBarData.bars.estimatedRemainingTime) - timeDifferentials;
                remainingTimes(remainingTimes<0) = 0;
                elapsedTimes = currentTime - cat(1,prtUtilProgressBarData.bars.startTime);
                
                for iBar = 1:prtUtilProgressBarData.nBars
                    
                    if isfinite(remainingTimes(iBar))
                        estimatedRemainingTimeInSeconds = fix(remainingTimes(iBar));
                        estimatedRemainingTimeInMinutes = estimatedRemainingTimeInSeconds/60;
                        estimatedRemainingHours = floor(estimatedRemainingTimeInMinutes/60);
                        estimatedRemainingMinutes = floor(mod(estimatedRemainingTimeInMinutes,60));
                        estimatedRemainingSeconds = mod(estimatedRemainingTimeInSeconds,60);
                    
                        timeRemainingStr = sprintf('%u:%02u:%02u',estimatedRemainingHours,estimatedRemainingMinutes,estimatedRemainingSeconds);
                        
                        set(prtUtilProgressBarData.bars(iBar).rightTextHandle,'string',timeRemainingStr);
                    end
                    
                    
                    if isfinite(elapsedTimes(iBar))
                        elapsedRemainingTimeInSeconds = fix(elapsedTimes(iBar));
                        elapsedRemainingTimeInMinutes = elapsedRemainingTimeInSeconds/60;
                        elapsedRemainingHours = floor(elapsedRemainingTimeInMinutes/60);
                        elapsedRemainingMinutes = floor(mod(elapsedRemainingTimeInMinutes,60));
                        elapsedRemainingSeconds = mod(elapsedRemainingTimeInSeconds,60);
                        
                        timeElapsedStr = sprintf('%u:%02u:%02u',elapsedRemainingHours,elapsedRemainingMinutes,elapsedRemainingSeconds);
                        
                        set(prtUtilProgressBarData.bars(iBar).leftTextHandle,'string',timeElapsedStr);
                    end
                end
            end
            
            % Always update the center 
            set(bar.centerTextHandle,'string', sprintf('%d%%',round(percentage*100)));
            
            if ((currentTime-bar.timeLastGraphicsUpdate) > Obj.minTimeBetweenUpdates) || ((percentage-bar.percentLastGraphicsUpdate) > Obj.minPercentBetweenUpdates)
                bar.timeLastGraphicsUpdate = currentTime;
                bar.percentLastGraphicsUpdate = percentage;
                
                Obj.updateFigureName(prtUtilProgressBarData);
                
                drawnow;
            end
             
            % Save bar data in figure
            prtUtilProgressBarData.bars(Obj.barIndex) = bar;
			if ishandle(Obj.figureHandle)
				guidata(Obj.figureHandle,prtUtilProgressBarData);
			end
            
            if all(abs(percentage-1)<1e-9)
                
                if Obj.autoClose
                    % close the object
                    Obj.close();
                end
            end
            
            
        end
        
        function Obj = set.globalTitleStr(Obj,str)
            assert(ischar(str),'globalTitleStr must be a character array');
            
            oldGlobalTitleStr = Obj.globalTitleStr;
            Obj.globalTitleStr = str;
            
            if ishandle(Obj.figureHandle) %#ok<MCSUP>
                prtUtilProgressBarData = guidata(Obj.figureHandle); %#ok<MCSUP>
                isAuto = strcmpi(str,'-auto');
                if (isAuto && strcmpi(oldGlobalTitleStr,prtUtilProgressBarData.globalTitleStr)) || ~isAuto
                    prtUtilProgressBarData.globalTitleStr = Obj.globalTitleStr;
                    guidata(Obj.figureHandle, prtUtilProgressBarData); %#ok<MCSUP>
                end
            end
        end
        
        function updateFigureName(Obj,gData)
            
            if ~ishandle(Obj.figureHandle)
                return
            end
            
            if nargin < 2 || isempty(gData)
                gData = guidata(Obj.figureHandle);
            end
            
            if ~isfield(gData,'globalTitleStr')
                guidata(Obj.figureHandle,gData);
                Obj.globalTitleStr = Obj.globalTitleStr;
                gData = guidata(Obj.figureHandle);                
            end
            
            if strcmpi(gData.globalTitleStr,'-auto')
                % Automatically set to the active sub-titles title
                set(Obj.figureHandle,'Name',Obj.titleStr);
            else
                % Set to the global one.
                set(Obj.figureHandle,'Name',gData.globalTitleStr);
            end
        end
        
        function Obj = close(Obj)
            
            Obj = removeBar(Obj);
            
            prtUtilProgressBarData = guidata(Obj.figureHandle);
            
            if prtUtilProgressBarData.nBars == 0 && ishandle(Obj.figureHandle) && strcmpi(get(Obj.figureHandle,'BeingDeleted'),'off')
                delete(Obj.figureHandle);
            end    
        end
        
        function Obj = closeAll(Obj)
            if ishandle(Obj.figureHandle) && strcmpi(get(Obj.figureHandle,'BeingDeleted'),'off')
                delete(Obj.figureHandle);
            end    
        end
        
        function Obj = set.titleStr(Obj,titleStr)
            assert(ischar(titleStr),'titleStr must be a character array');
            Obj.titleStr = titleStr;
            if ishandle(Obj.figureHandle) %#ok<MCSUP>
                set(Obj.figureHandle,'Name',titleStr); %#ok<MCSUP>
                prtUtilProgressBarData = guidata(Obj.figureHandle); %#ok<MCSUP>
                set(prtUtilProgressBarData.bars(Obj.barIndex).topTextHandle,'string',Obj.titleStr); %#ok<MCSUP>
            end
            
        end
    end
    
    methods (Access = private)
        function Obj = createWindow(Obj)
            
            nBars = 1;
            if Obj.allowStop
                windowHeight = Obj.windowBottomMargin + Obj.windowTopMargin + Obj.cancelButtonHeight + Obj.cancelButtonVertMargin + (nBars-1)*Obj.barVertMargin + nBars*Obj.barHeight;
            else
                windowHeight = Obj.windowBottomMargin + Obj.windowTopMargin + Obj.cancelButtonVertMargin + (nBars-1)*Obj.barVertMargin + nBars*Obj.barHeight;
            end
            
            windowSize = [Obj.windowWidth windowHeight];
            
            cancelButtonXStart = floor((Obj.windowWidth - Obj.cancelButtonWidth)/2);
            cancelButtonYStart = Obj.windowBottomMargin;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Create Figure
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            screenSize = get(0,'ScreenSize');
            Obj.figureHandle = figure('DoubleBuffer','on',...
                                      'HandleVisibility','off',...
                                      'MenuBar','none',...
                                      'NumberTitle','off',...
                                      'Resize','off',...
                                      'Tag','PrtProgressBar',...
                                      'ToolBar','none',...
                                      'DockControls','Off',...%'WindowStyle','modal',...
                                      'Name',Obj.titleStr,...
                                      'Position',[floor((screenSize(3:4)-windowSize)/2) windowSize]);...% Center window
                                      % 'CloseRequestFcn','');
                                      
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Create Axes
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            axesHandle = axes('Parent',Obj.figureHandle,...
                                  'Position',[0 0 1 1],...
                                  'Visible','off',...
                                  'XLim',[0 windowSize(1)],...
                                  'YLim',[0 windowSize(2)]);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Cancel Button                  
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if Obj.allowStop
                cancelButtonHandle = uicontrol('Parent',Obj.figureHandle,...
                                                   'Units','pixels',...
                                                   'position',[cancelButtonXStart cancelButtonYStart Obj.cancelButtonWidth Obj.cancelButtonHeight],...
                                                   'style','pushbutton',...
                                                   'callback',@(myHandle,evenData)prtUtilProgressBar.cancelCallBack(myHandle,evenData),...
                                                   'String','Stop','BusyAction','Queue');
            else
                cancelButtonHandle = [];
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            
            prtUtilProgressBarData.nBars = 0;
            prtUtilProgressBarData.axesHandle = axesHandle;
            prtUtilProgressBarData.cancelButtonHandle = cancelButtonHandle;
            prtUtilProgressBarData.bars = struct([]);
            prtUtilProgressBarData.isCanceled = false;
            prtUtilProgressBarData.nBarsSpace = 0;
            prtUtilProgressBarData.globalTitleStr = Obj.globalTitleStr;
            
            guidata(Obj.figureHandle,prtUtilProgressBarData);
            
        end
        
        function Obj = removeBar(Obj)
            
            % Get Figure user data
            prtUtilProgressBarData = guidata(Obj.figureHandle);
            prtUtilProgressBar.deleteBarHandles(prtUtilProgressBarData.bars(Obj.barIndex));
            prtUtilProgressBarData.bars(Obj.barIndex) = [];
            
            prtUtilProgressBarData.nBars = prtUtilProgressBarData.nBars - 1;
            nBars = prtUtilProgressBarData.nBars; % Shorthand
            nBarsSpace = prtUtilProgressBarData.nBarsSpace;
            % Derived Graphics parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            hasStop = ~isempty(prtUtilProgressBarData.cancelButtonHandle);
            
            if hasStop
                barYStarts = Obj.windowBottomMargin + Obj.cancelButtonHeight + Obj.cancelButtonVertMargin + ((1:nBarsSpace)-1)*(Obj.barHeight + Obj.barVertMargin);
            else
                barYStarts = Obj.windowBottomMargin + ((1:nBarsSpace)-1)*(Obj.barHeight + Obj.barVertMargin);
            end
            
            barYStarts = flipud(barYStarts(:));
            barYStarts = barYStarts(1:nBars);
            
            
            
            for iBar = 1:nBars
                cBarYStart = barYStarts(iBar);
                
                % An old bar, need to move the y positions up
                BarStruct = prtUtilProgressBarData.bars(iBar);
                
                handleFieldNamesToChange = {'backgroundPatchHandle';
                    'foregroundPatchHandle';};
                
                for iField = 1:length(handleFieldNamesToChange)
                    cHandle = BarStruct.(handleFieldNamesToChange{iField});
                    cPos = get(cHandle,'position');
                    cPos(2) = cBarYStart;
                    set(cHandle,'position', cPos);
                end
                
                handleFieldNamesToChange = {'leftTextHandle';
                    'rightTextHandle';
                    'centerTextHandle';};
                
                for iField = 1:length(handleFieldNamesToChange)
                    cHandle = BarStruct.(handleFieldNamesToChange{iField});
                    cPos = get(cHandle,'position');
                    cPos(2) = cBarYStart + Obj.barHeight/2;
                    set(cHandle,'position', cPos);
                end
                
                cHandle = BarStruct.topTextHandle;
                cPos = get(cHandle,'position');
                cPos(2) = cBarYStart + Obj.barHeight + Obj.titleTextMargin;
                set(cHandle,'position', cPos);
            end
            
            
            guidata(Obj.figureHandle,prtUtilProgressBarData);
            
            Obj.isDead = true;
            
        end
        
        function Obj = addBar(Obj)
            
            % Get Figure user data
            prtUtilProgressBarData = guidata(Obj.figureHandle);
            
            prtUtilProgressBarData.nBars = prtUtilProgressBarData.nBars + 1;
            nBars = prtUtilProgressBarData.nBars; % Shorthand
            nBarsSpace = prtUtilProgressBarData.nBarsSpace; % Shorthand
            cBar = nBars;
            
            % Derived Graphics parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            xStart = Obj.windowHorzMargin;
            xStop = Obj.windowWidth - Obj.windowHorzMargin;
            
            barWidth = xStop - xStart;
            
            textLeftX = xStart + Obj.textHorzMargin;
            textCenterX = mean([xStop xStart]);
            textRightX = xStop - Obj.textHorzMargin;
            
            hasStop = ~isempty(prtUtilProgressBarData.cancelButtonHandle);
            
            if nBars > nBarsSpace
                
                % Expand window
                if hasStop
                    windowHeight = Obj.windowBottomMargin + Obj.windowTopMargin + Obj.cancelButtonHeight + Obj.cancelButtonVertMargin + (nBars-1)*Obj.barVertMargin + nBars*Obj.barHeight;
                else
                    windowHeight = Obj.windowBottomMargin + Obj.windowTopMargin + Obj.cancelButtonVertMargin + (nBars-1)*Obj.barVertMargin + nBars*Obj.barHeight;
                end
                windowSize = [Obj.windowWidth windowHeight];
            
                screenSize = get(0,'ScreenSize');
                set(Obj.figureHandle,'Position',[floor((screenSize(3:4)-windowSize)/2) windowSize]);% Center window
            
                set(prtUtilProgressBarData.axesHandle,'Position',[0 0 1 1],...
                                                   'XLim',[0 windowSize(1)],...
                                                   'YLim',[0 windowSize(2)]);
                
                prtUtilProgressBarData.nBarsSpace = nBars;
                nBarsSpace = nBars;
            end
            
            % Force Set function call; Be sure to juggle guidata properly
            guidata(Obj.figureHandle,prtUtilProgressBarData);
            Obj.globalTitleStr = Obj.globalTitleStr; 
            prtUtilProgressBarData = guidata(Obj.figureHandle);
            
            if hasStop
                %barYStarts = cancelButtonYStart + Obj.cancelButtonHeight + Obj.cancelButtonVertMargin + ((1:nBars)-1)*(Obj.barHeight + Obj.barVertMargin);
                barYStarts = Obj.windowBottomMargin + Obj.cancelButtonHeight + Obj.cancelButtonVertMargin + ((1:nBarsSpace)-1)*(Obj.barHeight + Obj.barVertMargin);
            else
                %barYStarts = cancelButtonYStart + ((1:nBars)-1)*(Obj.barHeight + Obj.barVertMargin);
                barYStarts = Obj.windowBottomMargin + ((1:nBarsSpace)-1)*(Obj.barHeight + Obj.barVertMargin);
            end
            barYStarts = flipud(barYStarts(:));
            barYStarts = barYStarts(1:nBars);
            
            for iBar = 1:nBars
                cBarYStart = barYStarts(iBar);
                
                if iBar == cBar
                    % The new bar
                    
                    % Create Bars
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BarStruct.backgroundPatchHandle = rectangle('Position',[xStart cBarYStart barWidth Obj.barHeight],...
                        'EdgeColor','none',...
                        'FaceColor',Obj.barBackgroundColor,...
                        'parent',prtUtilProgressBarData.axesHandle);
                    BarStruct.foregroundPatchHandle = rectangle('Position',[xStart cBarYStart Obj.barWidthMin Obj.barHeight],...
                        'EdgeColor','none',...
                        'FaceColor',Obj.barForegroundColor,...
                        'parent',prtUtilProgressBarData.axesHandle);
                    
                    % Create Texts
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BarStruct.leftTextHandle = text(textLeftX,cBarYStart + Obj.barHeight/2,'','HorizontalAlignment','Left','VerticalAlignment','middle','parent',prtUtilProgressBarData.axesHandle);
                    BarStruct.rightTextHandle = text(textRightX,cBarYStart + Obj.barHeight/2,'','HorizontalAlignment','Right','VerticalAlignment','middle','parent',prtUtilProgressBarData.axesHandle);
                    BarStruct.centerTextHandle = text(textCenterX,cBarYStart + Obj.barHeight/2,'','HorizontalAlignment','Center','VerticalAlignment','middle','parent',prtUtilProgressBarData.axesHandle);
                    BarStruct.topTextHandle = text(xStart, cBarYStart + Obj.barHeight + Obj.titleTextMargin, Obj.titleStr,'HorizontalAlignment','Left','VerticalAlignment','middle','parent',prtUtilProgressBarData.axesHandle);
                    
                    % Initialize other variables
                    BarStruct.lastIterationsTimes = nan(1,Obj.nSamplesForTimeEstSmoothing);
                    BarStruct.lastIterationsPercentages = nan(1,Obj.nSamplesForTimeEstSmoothing);
                    BarStruct.startTime = 86400*now;
                    BarStruct.estimatedRemainingTime = inf;
                    BarStruct.percentage = 0;
                    
                    
                    BarStruct.timeLastGraphicsUpdate = -Inf;
                    BarStruct.percentLastGraphicsUpdate = -Inf;
                
                    if isempty(prtUtilProgressBarData.bars)
                        prtUtilProgressBarData.bars = BarStruct;
                    else
                        prtUtilProgressBarData.bars = cat(1,prtUtilProgressBarData.bars,BarStruct);
                    end
                else
                    % An old bar, need to move the y positions up
                    BarStruct = prtUtilProgressBarData.bars(iBar);
                    
                    handleFieldNamesToChange = {'backgroundPatchHandle';
                                                'foregroundPatchHandle';};
                    
                    for iField = 1:length(handleFieldNamesToChange)
                        cHandle = BarStruct.(handleFieldNamesToChange{iField});
                        cPos = get(cHandle,'position');
                        cPos(2) = cBarYStart;
                        set(cHandle,'position', cPos);
                    end
                    
                    handleFieldNamesToChange = {'leftTextHandle';
                                                'rightTextHandle';
                                                'centerTextHandle';};
                     
                    for iField = 1:length(handleFieldNamesToChange)
                        cHandle = BarStruct.(handleFieldNamesToChange{iField});
                        cPos = get(cHandle,'position');
                        cPos(2) = cBarYStart + Obj.barHeight/2;
                        set(cHandle,'position', cPos);
                    end
                    
                    cHandle = BarStruct.topTextHandle;
                    cPos = get(cHandle,'position');
                    cPos(2) = cBarYStart + Obj.barHeight + Obj.titleTextMargin;
                    set(cHandle,'position', cPos);
                    
                end
            end
            
            guidata(Obj.figureHandle,prtUtilProgressBarData);
            
            
        end
    end
    
    methods (Static)
        function cancelCallBack(myHandle,evenData) %#ok<INUSD>
            set(myHandle,'String','Stopping...');
            %prtUtilProgressBarData = guidata(get(myHandle,'parent'));
            
            myFig = get(myHandle,'parent');
            ud = get(myFig,'userdata');
            ud.prtUtilProgressBarIsCanceled = true;
            set(myFig,'userData',ud);
            %prtUtilProgressBarData.isCanceled = true;
            %guidata(get(myHandle,'parent'), prtUtilProgressBarData);
            drawnow;
        end
        function deleteBarHandles(barStruct)
            delete(barStruct.leftTextHandle);
            delete(barStruct.rightTextHandle);
            delete(barStruct.centerTextHandle);
            delete(barStruct.backgroundPatchHandle);
            delete(barStruct.foregroundPatchHandle);
            delete(barStruct.topTextHandle);
        end
        
        function forceClose()
            
            oldHandleVisilibity = get(0,'ShowHiddenHandles');
            set(0,'ShowHiddenHandles','on');
            figHandle = findobj('tag','PrtProgressBar','HandleVisibility','off');
            set(0,'ShowHiddenHandles',oldHandleVisilibity);
            
            if ~isempty(figHandle)
                close(figHandle)
            end
        end       
    end
end
