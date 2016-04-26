classdef prtUiDataSetClassExploreWidgetTabClickDisplay < prtUiDataSetClassExploreWidgetTab





    properties

        titleStr = 'Clicked';
        
        handles
    end
    
    methods
        function self = prtUiDataSetClassExploreWidgetTabClickDisplay(varargin)
            self = self@prtUiDataSetClassExploreWidgetTab(varargin{:});
            
            init(self);
        end
        
        function init(self)
            

            self.handles.text = uicontrol('style','edit',... % Use an edit box instead of text so it is scrollable
                               'Max',100,...
                               'parent',self.managedHandle,...
                               'units','normalized',...
                               'position',[0.025 0.125 0.95 0.85],...
                               'FontSize',10,...
                               'FontName',get(0,'FixedWidthFontName'),...
                               'HorizontalAlignment','Left',...
                               'Enable','inactive',...
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


