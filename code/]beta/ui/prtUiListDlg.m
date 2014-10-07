classdef prtUiListDlg < prtUiManagerPanel

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


    % clear classes
    % close all
    % strs = {'asdf', 'qwer','poiu','lkhj'};
    % obj = prtUiListDlg(strs);
    %
    % if isempty(obj.enteredSelection)
    %     disp('Nothin');
    % else
    %     disp(strs{obj.enteredSelection});
    % end
    
    properties
        inputStruct
        tableFieldNames = {};
        dataCell = {};
        
        enteredSelection = [];
        
        windowSize = [500 300];
        textFontSize = 25;
        tableFontSize = 20;
        
        titleStr = '';
        messageStr = '<HTML><H1>Make A Choice</H1></HTML>';
        
        cancelStr = 'Cancel';
        okStr = 'OK';        
        
        enableMultiSelect = false;
        
        handleStruct
    end
    
    properties (SetAccess = 'protected')
        madeThisWindow = false;
    end
    
    methods
        function self = prtUiListDlg(varargin)
            
            if nargin == 1
                self.inputStruct = varargin{1};
            elseif ~mod(nargin,2)
                self = prtUtilAssignStringValuePairs(self,varargin{:});
            else
                self.inputStruct = varargin{1};
                self = prtUtilAssignStringValuePairs(self,varargin{2:end});
            end
            
            if nargin~=0 && ~self.hgIsValid
               self.create()
            end
            
            init(self);
            
            waitfor(self.handleStruct.table);
            
        end
        function create(self)
            ss = get(0,'ScreenSize');
            screenCenter = ss(3:4)/2;
            
            self.handleStruct.figureHandle = figure('units','pixels',...
                'position',[screenCenter(1)-self.windowSize(1)/2 screenCenter(2)-self.windowSize(2)/2 self.windowSize],...
                'menubar','none',...
                'toolbar','none',...
                'numberTitle','off',...
                'Name',self.titleStr,...
                'Interruptible','off',...
                'BusyAction','cancel',...
                'DockControls','off');
            
            self.managedHandle = uipanel(self.handleStruct.figureHandle, ...
                'units','normalized',...
                'BorderType','none',...
                'Position',[0 0 1 1]);
            
            self.madeThisWindow = true;
        
        end
        
        function init(self)
            
            self.handleStruct.table = uitable('parent',self.managedHandle,...
                'units','pixels','position',[1 1 50 50]); % Dummy position
            if ~isfield(self.handleStruct,'figureHandle') || ~ishandle(self.handleStruct.figureHandle)
                self.handleStruct.figureHandle = gcf; %Is this ok? It depens how we use this.
            end
            drawnow;
            
            self.handleStruct.jScrollPane = findjobj(self.handleStruct.table);
            self.handleStruct.jTable = self.handleStruct.jScrollPane.getViewport.getView;
            
            % Set the actual data in the cell
            structArrayToCell(self);
            set(self.handleStruct.table,'data',self.dataCell,...
                'columnName',self.tableFieldNames,...
                'RearrangeableColumns','on',...
                'RowName',{},...
                'TooltipString','Available Options',...
                'ColumnEditable',false(1,length(self.tableFieldNames)),...
                'KeyPressFcn',@self.tableKeyPressFcn,...
                'CellSelectionCallback',@self.cellCelectionFcn);
           
            % Force selection of full rows only
            self.handleStruct.jTable.setNonContiguousCellSelection(false)
            
            % Force selection of a single row only
            if ~self.enableMultiSelect
                self.handleStruct.jTable.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_SELECTION);
            end
            
            % Set the column widths to take up the whole area
            self.handleStruct.jTable.setAutoResizeMode(self.handleStruct.jTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
            
            [self.handleStruct.textHandle, self.handleStruct.textHandleContainer]  = javacomponent('javax.swing.JLabel',[1 1 1 1], self.managedHandle);
            backgroundColor = get(self.managedHandle,'BackgroundColor');
            set(self.handleStruct.textHandle,'Text',self.messageStr,'Background',java.awt.Color(backgroundColor(1),backgroundColor(2),backgroundColor(3)),...
                'Font',java.awt.Font('sansserif',java.awt.Font.PLAIN,self.textFontSize));
            self.handleStruct.textHandle.setVerticalAlignment(javax.swing.JLabel.TOP);
            
            self.handleStruct.cancelButton = uicontrol('style','pushbutton',...
                'parent',self.managedHandle,...
                'units','pixels',...
                'position',[1 1 10 10],...
                'callback',@self.cancelCallback,...
                'string',self.cancelStr);
            
            self.handleStruct.okButton = uicontrol('style','pushbutton',...
                'parent',self.managedHandle,...
                'units','pixels',...
                'position',[1 1 10 10],...
                'callback',@self.okCallback,...
                'string',self.okStr);
            
            % Set and call the resize function to set the element positions
            set(self.managedHandle,'ResizeFcn',@self.resizeFunction);
            resizeFunction(self);
            
            drawnow;
            set(self.handleStruct.jTable,'Font',java.awt.Font('sansserif',java.awt.Font.PLAIN,self.tableFontSize));
        end
        
        function close(self)
            if self.madeThisWindow
                try %#ok<TRYNC>
                    close(self.handleStruct.figureHandle);
                end
            else
                try
                    delete(self.handleStruct.table);
                end
            end
            
        end
        
        function okCallback(self, varargin)
            self.enteredSelection = getSelection(self); 
            close(self)
        end
        
        function cancelCallback(self, varargin)
            close(self);
        end
            
        function structArrayToCell(self)
            self.tableFieldNames = fieldnames(self.inputStruct)';
            self.dataCell = struct2cell(self.inputStruct)';
        end

        function resizeFunction(self, varargin)
            panelPosition = getpixelposition(self.managedHandle);
            
            border = 8;
            textHeight = 50;
            buttonHeight = 20;
            buttonWidth = 50;
            
            left = border+1;
            width = panelPosition(3);
            bottom = border+1;
            height= panelPosition(4);
            
            textBottom = max(height-textHeight-border,1);
            
            okButtonLeft = width/2-border/2-buttonWidth;
            cancelButtonLeft = width/2+border/2;
            
            tableBottom = bottom+border+buttonHeight;
            tableHeight = max(height-buttonHeight-border*4-textHeight,1);
            
            okButtonPos = [okButtonLeft bottom buttonWidth, buttonHeight];
            cancelButtonPos = [cancelButtonLeft bottom buttonWidth, buttonHeight];
            
            tablePos = [left tableBottom width-border*2-2 tableHeight];
            textPos = [left textBottom width-border*2-2 textHeight];
            
            set(self.handleStruct.okButton,'units','pixels');
            set(self.handleStruct.okButton,'position',okButtonPos);
            set(self.handleStruct.okButton,'units','normalized');
            
            set(self.handleStruct.cancelButton,'units','pixels');
            set(self.handleStruct.cancelButton,'position',cancelButtonPos);
            set(self.handleStruct.cancelButton,'units','normalized');
            
            set(self.handleStruct.table,'units','pixels');
            set(self.handleStruct.table,'position',tablePos);
            set(self.handleStruct.table,'units','normalized');
            
            set(self.handleStruct.textHandleContainer,'units','pixels')
            set(self.handleStruct.textHandleContainer,'position',textPos)
            set(self.handleStruct.textHandleContainer,'units','normalized')
        
            %drawnow;
        end
        
        function tableKeyPressFcn(self, varargin)
            event = varargin{2};
            
            if strcmpi(event.Key,'Return')
                
                % They hit return, so select this entry and exit
                % When you hit return MATLAB (I think), moves the selection
                % to the "next" cell. If you have the last one selected it
                % goes back around to zero. 
                reportedSelection = getSelection(self);
                reportedSelection = reportedSelection - 1; % undo the wrap arround
                if reportedSelection==0 % We actually selected the end and they wrapped us around to 1
                    reportedSelection = length(self.inputStruct);
                end
                
                self.enteredSelection = reportedSelection; 
                
                drawnow;
                self.handleStruct.jTable.setRowSelectionInterval(reportedSelection-1,reportedSelection-1);
                drawnow;
                
                close(self);
                
            elseif strcmpi(event.Key,'Escape')
                % Leave with an empty selection
                close(self)
            else
                % Nada, probably an arrow
            end
        end
        function reportedSelection = getSelection(self)
            if ~self.enableMultiSelect
                reportedSelection = self.handleStruct.jTable.getSelectedRow()+1;% Java is 0 referenced
            else
                reportedSelection = self.handleStruct.jTable.getSelectedRows()+1;% Java is 0 referenced
            end
        end
        function set.inputStruct(self, val)
            assert(isstruct(val) || iscellstr(val),'inputStruct must be a structure array or a cellstr');
            
            if iscellstr(val)
                cellOfStrs = val; cellOfStrs = cellOfStrs(:);
                self.inputStruct = struct('Choices',cellOfStrs);
            else
                self.inputStruct = val(:);
            end
        end
    end
end
