classdef prtUiDataSetClassExploreWidgetTabClickDisplay < prtUiDataSetClassExploreWidgetTab

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
    properties

        titleStr = 'Clicked';
        
        handles
    end
    
    methods
        function self = prtUiDataSetClassExploreWidgetTabClickDisplay(varargin)
            
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            
            if nargin~=0 && ~self.hgIsValid
               self.create()
            end
            
            init(self);
        end
        
        function init(self)
            
            self.handles.text = uicontrol('style','text',...
                               'parent',self.managedHandle,...
                               'units','normalized',...
                               'position',[0.025 0.125 0.95 0.85],...
                               'FontSize',10,...
                               'FontName',get(0,'FixedWidthFontName'),...
                               'HorizontalAlignment','Left',...
                               'string','Click in the axes to inspect observations.');
            
            self.handles.listener = addlistener(self.widget.plotManager, 'clickedIndex', 'PostSet', @self.displayClick);
            
            self.handles.infoToWorkspaceButton = uicontrol('parent',self.managedHandle,...
                                 'string','View Obs. Info',...
                                 'units','normalized',...
                                 'position',[0.2 0.025 0.6 0.095],...
                                 'callback',@self.sendObservationInfoToWorkspaceCallback,...
                                 'enable','off');
            
        end
        function displayClick(self,varargin)
            
            
            clickedInd = self.widget.plotManager.clickedIndex;
            ds = self.widget.plotManager.dataSet;
            
            obsName = ds.getObservationNames(clickedInd);
            
            if ds.isLabeled
                className = ds.classNames(ds.getTargetsClassInd(clickedInd));
                cString = sprintf('Closest Observation:\n\tName: %s\n\tClass: %s',obsName{1},className{1});
            else
                cString = sprintf('Closest Observation:\n\t Name: %s',obsName{1});
            end
            
            if length(ds.observationInfo) >= clickedInd
                % observationInfo is present
                set(self.handles.infoToWorkspaceButton,'enable','on');
                
                s = ds.observationInfo(clickedInd);
                infoStr = evalc('display(s)');
                infoStr = infoStr(6:end); % 6 here is for the 's =   '
                
                cString = cat(2, cString, sprintf('\n\nObservation Info:\n'),infoStr);
                
            end
            
            set(self.handles.text,'string',cString);
            
        end
        
        function sendObservationInfoToWorkspaceCallback(self,myHandle,eventData)  %#ok<INUSD>
            
            clickedInd = self.widget.plotManager.clickedIndex;
            ds = self.widget.plotManager.dataSet;
            
            if length(ds.observationInfo) > clickedInd
                c = ds.observationInfo(clickedInd);
            else
                c =  struct([]);
            end
            
            assignin('base','prtPlotUtilDataSetExploreGuiWithNavigationTempVar',c);
            openvar('prtPlotUtilDataSetExploreGuiWithNavigationTempVar');
        end
    end
end


