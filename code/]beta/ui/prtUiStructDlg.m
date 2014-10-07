classdef prtUiStructDlg < prtUiManagerPanel

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
        % Note: Most of these properties must be set during construction in
        % order to work properly.
        
        inputStruct
        outputStruct
        
        windowSize = [500 300];
        
        closeOnOk = true;
        closeOnCancel = true;
        waitForOk = true;
        allowCancel = true;
        allowOk = true;
        additionalOkCallback = []; %@()someFunction()
        additionalCancelCallback = []; %@()someFunction()
        
        sharedControlCallback = []; %@(h,e)someFunction() , this sets the callback propety of uicontrols, it doesn't work for uicontrols without a callback proeprtu (like uitabl)
        
        titleStr = '';
        
        fig
        scrollable
        overlayPanel
        cancelButton
        okButton
        
        cancelStr = 'Cancel';
        okStr = 'OK';
        
        controls
        handles
        
        figheight
        figwidth
        
        uitopmargin    = 40;
        uibottommargin = 30;
        uilefttmargin  = 30;
        uirightmargin  = 30;
        uicorewidth    = 400;
        
        uitextheight   = 13;
        uiheightunit   = 20;
        
        uimultieditfac = 4;
        uilistboxfac   = 4;
        uitablemaxrow  = 4;
        
        uibuttonwidth  = 60;
        uibuttonheight = 20;
        
        uisidebuttonwidth = 30;
        
        dxunit = 10;
        dyunit = 10;
        
        uiFontSize = 8;
        
        enablemode = 'on'; % 'inactive';
        dlgmode = 'edit'; % 'readonly';
    end
    
    properties (SetAccess = 'protected')
        madeThisWindow = false;
    end
    
    methods
        function self = prtUiStructDlg(varargin)
            
            if nargin == 1
                self.inputStruct = varargin{1};
            else
                self = prtUtilAssignStringValuePairs(self,varargin{:});
            end
            
            if isempty(self.inputStruct)
                error('inputStruct must be specified')
            end
            self.outputStruct = self.inputStruct;
            
            if nargin~=0 && ~self.hgIsValid
                self.create()
            end
            
            init(self);
            
            if self.waitForOk
                waitfor(self.overlayPanel,'visible','off');
            end
            
        end
        function create(self)
            ss = get(0,'ScreenSize');
            screenCenter = ss(3:4)/2;
            
            self.fig = figure('units','pixels',...
                'position',[screenCenter(1)-self.windowSize(1)/2 screenCenter(2)-self.windowSize(2)/2 self.windowSize],...
                'menubar','none',...
                'toolbar','none',...
                'numberTitle','off',...
                'Name',self.titleStr,...
                'tag',cat(2,'prtUiStructDlg',datestr(now,'yyyymmddHHMMSS')),...
                'Interruptible','off',...
                'BusyAction','cancel',...
                'DockControls','off');
            
            self.managedHandle = uipanel(self.fig, ...
                'units','normalized',...
                'BorderType','none',...
                'Position',[0 0 1 1]);
            
            self.madeThisWindow = true;
            
        end
        
        function init(self)
            
            parseDataStruct(self);
            
            createInputUicontrols(self);
        end
        function createInputUicontrols(self)
            % Create an appropriate uicontrol for each field of struct
            
%             self.overlayPanel = uipanel(self.managedHandle, ...
%                 'units','normalized',...
%                 'BorderType','none',...
%                 'Position',[0 0 1 1]);
            
            self.scrollable = prtExternal.ScrollPanel.ScrollPanel('Parent',self.managedHandle,...
                'Units','normalized',...
                'BorderType','none',...
                'Position',[0 0 1 1]);
            
            self.overlayPanel = self.scrollable.handle;
            set(self.scrollable,'BackgroundColor',get(self.managedHandle,'BackgroundColor'))
            
            self.handles  = {};
            
            %pos = getpixelposition(self.managedHandle);
            %self.figheight = pos(4);
            %self.figwidth =pos(3);
            %uiwidth = self.figwidth-self.uilefttmargin-self.uirightmargin;
            
            %initial value for figure's height and width
            self.figwidth  = self.uilefttmargin + self.uirightmargin + self.uicorewidth;
            self.figheight = self.uitopmargin + self.uibottommargin;
                
            uiwidth = self.figwidth - self.uilefttmargin - self.uirightmargin;
            
            for i=1:size(self.controls,1)
                
                type   = self.controls{i,1};
                fname  = self.controls{i,2};
                fvalue = self.inputStruct.(fname);
                description = self.fieldNameToString(fname);
                
                h = uicontrol(self.overlayPanel,...
                    'Style','text',...
                    'String',description,...
                    'HorizontalAlignment','left',...
                    'FontSize',self.uiFontSize,...
                    'BackgroundColor',get(self.managedHandle,'BackgroundColor'));
                
                self.figheight = self.figheight + self.uitextheight + self.dyunit/2;
                
                self.handles = [self.handles; {h [] uiwidth self.uitextheight 'text' ''}];
                
                switch type
                    
                    case 'table'
                        h = uitable(self.overlayPanel,...
                            'Enable',self.enablemode,...
                            'Data',fvalue,...
                            'ColumnEditable',true,...
                            'Units','pixel',...
                            'FontSize',self.uiFontSize...
                            );
                        hBtn = [];
                        
                        %uitableheight = min(18*(self.uitablemaxrow)+22,18*(size(fvalue,1))+22);
                        %uitableheight = (self.uiFontSize*2+2)*min(self.uitablemaxrow,size(fvalue,1))+22;
                        uitableheight = (self.uiFontSize*2)*min(self.uitablemaxrow,size(fvalue,1))+5;
                        
                        currwidth  = uiwidth;
                        currheight = uitableheight;
                        self.figheight  = self.figheight + currheight;
                        
                    case 'checkbox'
                        h = uicontrol(self.overlayPanel,...
                            'Enable',self.enablemode,...
                            'Style',type,...
                            'Value',fvalue,...
                            'HorizontalAlignment','left',...
                            'FontSize',self.uiFontSize...
                            );
                        hBtn = [];
                        
                        currwidth  = uiwidth;
                        currheight = self.uiheightunit;
                        self.figheight  = self.figheight + currheight;
                        
                    case 'edit'
                        h = uicontrol(self.overlayPanel,...
                            'Enable',self.enablemode,...
                            'Style',type,...
                            'String',fvalue,...
                            'HorizontalAlignment','left',...
                            'BackgroundColor','white',...
                            'FontSize',self.uiFontSize...
                            );
                        hBtn = [];
                        
                        currwidth  = uiwidth;
                        currheight = self.uiheightunit;
                        self.figheight  = self.figheight + currheight;
                        
                    case 'popupmenu'
                        if isempty(fvalue)
                            fvalue = {''};
                        end
                        
                        h = uicontrol(self.overlayPanel,...
                            'Enable','on',...
                            'Style',type,...
                            'String',fvalue,...
                            'HorizontalAlignment','left',...
                            'BackgroundColor','white',...
                            'FontSize',self.uiFontSize...
                            );
                        hBtn = [];
                        
                        currwidth  = uiwidth;
                        currheight = self.uiheightunit;
                        self.figheight  = self.figheight + currheight;
                        
                    case 'multiedit'
                        h = uicontrol(self.overlayPanel,...
                            'Enable',self.enablemode,...
                            'Style','edit',...
                            'String',fvalue,...
                            'HorizontalAlignment','left',...
                            'BackgroundColor','white',...
                            'Min',1,...
                            'Max',3, ...
                            'FontSize',self.uiFontSize...
                            );
                        hBtn = [];
                        
                        currwidth  = uiwidth;
                        currheight = self.uimultieditfac*self.uiheightunit;
                        self.figheight  = self.figheight + currheight;
                        
                    case 'listbox'
                        h = uicontrol(self.overlayPanel,...
                            'Enable',self.enablemode,...
                            'Style','listbox',...
                            'String',fvalue,...
                            'HorizontalAlignment','left',...
                            'BackgroundColor','white',...
                            'Min',1,...
                            'Max',3, ...
                            'FontSize',self.uiFontSize...
                            );
                        hBtn = [];
                        
                        currwidth  = uiwidth;
                        currheight = self.uilistboxfac*self.uiheightunit;
                        self.figheight  = self.figheight + currheight;
                        
                    case 'struct'
                        h = uicontrol(self.overlayPanel,...
                            'Style','edit',...
                            'String','Edit -->',...
                            'Enable','off',...
                            'HorizontalAlignment','left',...
                            'BackgroundColor','white',...
                            'FontSize',self.uiFontSize...
                            );
                        
                        currwidth  = uiwidth;
                        currheight = self.uiheightunit;
                        self.figheight  = self.figheight + currheight;
                        
                        hBtn = uicontrol(self.overlayPanel,...
                            'Style','pushbutton',...
                            'String','...',...
                            'Callback',{@self.subStructOpenFcn,fname},...
                            'FontSize',self.uiFontSize...
                            );
                        
                     case 'miscbutton'
                        h = uicontrol(self.overlayPanel,...
                            'Style','edit',...
                            'String','Activate -->',...
                            'Enable','off',...
                            'HorizontalAlignment','left',...
                            'BackgroundColor','white',...
                            'FontSize',self.uiFontSize...
                            );
                        
                        currwidth  = uiwidth;
                        currheight = self.uiheightunit;
                        self.figheight  = self.figheight + currheight;
                        
                        hBtn = uicontrol(self.overlayPanel,...
                            'Style','pushbutton',...
                            'String','...',...
                            'Callback',@(h,e)fvalue(),...
                            'FontSize',self.uiFontSize...
                            );
                    case 'file'
                        h = uicontrol(self.overlayPanel,...
                            'Enable',self.enablemode,...
                            'Style','edit',...
                            'String',fvalue(8:end),...
                            'HorizontalAlignment','left',...
                            'BackgroundColor','white',...
                            'FontSize',self.uiFontSize...
                            );
                        
                        hBtn = uicontrol(self.overlayPanel,...
                            'Style','pushbutton',...
                            'String','...',...
                            'Callback',{@self.fileButtonCallback,fname, h},...
                            'FontSize',self.uiFontSize...
                            );
                        
                        currwidth  = uiwidth;
                        currheight = self.uiheightunit;
                        self.figheight  = self.figheight + currheight;
                        
                    otherwise
                        h = uicontrol(self.overlayPanel,...
                            'Style','edit',...
                            'String',['<' class(fvalue) '>'],...
                            'Enable','off',...
                            'HorizontalAlignment','left',...
                            'BackgroundColor','white',...
                            'FontSize',self.uiFontSize...
                            );
                        
                        hBtn = [];
                        
                        currwidth  = uiwidth;
                        currheight = self.uiheightunit;
                        self.figheight  = self.figheight + currheight;
                end
                
                if ~isempty(self.sharedControlCallback)
                    try % some uicontrols don't have callbacks (like uitable)
                        set(h,'callback',self.sharedControlCallback);
                    catch
                        set(h,'CellEditCallback',self.sharedControlCallback);
                    end
                end
                self.figheight = self.figheight + self.dyunit;
                
                self.handles = [self.handles; {h hBtn currwidth currheight type fname}];
            end
            
            if self.allowCancel || self.allowOk
                %%Add OK and Cancel buttons
                self.okButton = uicontrol(self.overlayPanel,...
                    'Style','pushbutton',...
                    'String',self.okStr,...
                    'Callback',@self.okCallback,...
                    'KeyPressFcn',@self.keyPressFunction...
                    );
                
                self.cancelButton = uicontrol(self.overlayPanel,...
                    'Style','pushbutton',...
                    'String',self.cancelStr,...
                    'Callback',@self.cancelCallback,...
                    'KeyPressFcn',@self.keyPressFunction...
                    );
                
                if ~self.allowCancel
                    set(self.cancelButton,'visible','off')
                end
                
                if ~self.allowOk
                    set(self.okButton,'visible','off')
                end
                
                self.figheight = self.figheight + self.dyunit + self.uibuttonheight;
            end
            %%Set dialog position
            %figx = maxx/2-figwidth/2;
            %figy = maxy/2-figheight/2;
            
            %if figy<0
            %    warning('prt:prtUiStructDlg:dialogDispaly','Dialog may be not completely displayed');
            %end
            
            %set(self.managedHandle,'Position',[figx figy figwidth figheight]);
            
            %ResizeControls();
            self.resizeFunction();
            set(self.managedHandle,'resizeFcn',@self.resizeFunction);
            
            %set(self.scrollable,'Units','pixels','ScrollArea',[1 self.figheight-self.windowSize(2) self.figwidth self.figheight])
            %set(self.scrollable,'Units','normalized');
            
            mPos = get(self.scrollable.hViewportPanel, 'Position');
            sPos = get(self.scrollable.hScrollingPanel,'Position');
            
            set(self.scrollable.hScrollingPanel, 'Position',[sPos(1) -(sPos(4)-mPos(4)) sPos(3:4)]);
            
            
            
            possibleTables = self.handles(2:2:end,:);
            
            for i=1:size(possibleTables,1)
                
                type   = possibleTables{i,5};
                try
                    switch type
                        
                        case 'table'
                            h = possibleTables{i,1};
                            
                            drawnow;
                            cJavaH = findjobj(h);
                            cJavaH.setColumnHeader([]);
                            cJavaH.setRowHeader([]);
                            cJavaH.setBorder([]);
                            cJavaH.repaint();
                    end
                end
            end
            
            
            %set(self.managedHandle,'Visible','on');
            
            %uicontrol(hOk);
        end
        
        
        function resizeFunction(self,varargin)
            set(self.scrollable,'Units','pixels');
            initScrollArea = self.scrollable.ScrollArea;
            
            x = self.uilefttmargin;
            y = self.figheight - self.uitopmargin;
            
            pos = getpixelposition(self.managedHandle);
            
            %scrollablePos = self.scrollable.ScrollPanel;
            
            uiIsUiControl = strcmpi(get(cat(1,self.handles{:,1}),'type'),'uicontrol');
            
            uiIsTextGivenUiControl = strcmpi(get(cat(1,self.handles{uiIsUiControl,1}),'style'),'text');
            
            uiIsText = false(size(uiIsUiControl));
            uiIsText(uiIsUiControl) = uiIsTextGivenUiControl;
            
            uiHeights = cat(1,self.handles{:,4});
            
            totalHeight = sum(uiHeights) + sum(self.dyunit/2.*uiIsText + self.dyunit.*(~uiIsText)) + self.uibuttonheight + self.dyunit*2 + self.uibottommargin + self.uitopmargin*2;
            
            extraVertOffSet = max(pos(4)-totalHeight,0);
            
            for ni=1:size(self.handles,1)
                
                h      = self.handles{ni,1};
                hBtn   = self.handles{ni,2};
                %width  = self.handles{ni,3};
                width = pos(3)-self.uirightmargin-self.scrollable.scrollBarWidth-self.uilefttmargin;
                
                height = self.handles{ni,4};
                
                type = get(h,'Type');
                
                switch type
                    
                    case 'uicontrol'
                        if isequal(get(h,'Style'),'text')
                            dy = self.dyunit/2;
                        else
                            dy = self.dyunit;
                        end
                        
                    case 'uitable'
                        dy = self.dyunit;
                        
                    otherwise
                        dy = 0;
                end
                
                if ~isempty(hBtn)
                    width = width - self.dxunit - self.uisidebuttonwidth;
                    set(hBtn,'Position',[x+width+self.dxunit y-height+self.uiheightunit+extraVertOffSet self.uisidebuttonwidth height]);
                end
                
                set(h,'Position',[x y-height+self.uiheightunit+extraVertOffSet width height]);
                
                y = y - height - dy;
                
            end
            
            usableWidth = (pos(3)-self.uirightmargin-self.uilefttmargin-self.scrollable.scrollBarWidth);
            
            set(self.okButton,'Position',[self.uilefttmargin+usableWidth/2-self.dxunit-self.uibuttonwidth y-self.dyunit/2-self.uibuttonheight self.uibuttonwidth self.uibuttonheight]);
            set(self.cancelButton,'Position',[self.uilefttmargin+usableWidth/2+self.dxunit y-self.dyunit/2-self.uibuttonheight self.uibuttonwidth self.uibuttonheight]);
            
            
            %set(self.scrollable,'Units','pixels',
            %initScrollArea
            newScrollArea = [1 1 self.figwidth self.figheight];
            newScrollArea(1) = 1-(-(initScrollArea(1)-1)/initScrollArea(3)*self.figwidth);
            newScrollArea(2) = 1-(-(initScrollArea(2)-1)/initScrollArea(4)*self.figheight);
            
            %newScrollArea(1) = self.figwidth-initScrollArea(3);
            %newScrollArea(2) = self.figheight-initScrollArea(4);
            
            set(self.scrollable,'Units','pixels','ScrollArea',newScrollArea)
            set(self.scrollable,'Units','normalized');
        end
        
        function parseDataStruct(self)
            %%Parse struct data
            dataf = fields(self.inputStruct);
            
            self.controls = {};
            for i=1:numel(dataf)
                
                fname  = dataf{i};
                fvalue = self.inputStruct.(fname);
                fclass = class(fvalue);
                
                switch fclass
                    
                    case {'double', 'single',...
                            'int8',   'uint8',...
                            'int16',  'uint16',...
                            'int32',  'uint32',...
                            'int64',  'uint64'}
                        
                        self.controls = [self.controls; {'table' fname}];
                        
                    case 'logical'
                        if numel(fvalue)>1
                            self.controls = [self.controls; {'table' fname}];
                        else
                            self.controls = [self.controls; {'checkbox' fname}];
                        end
                        
                    case 'char'
                        
                        % look for file
                        if length(fvalue)>=7 && strcmpi(fvalue(1:7),'#<file>')% && exist(fname(8:end),'file')
                            % File
                            self.controls = [self.controls; {'file' fname}];
                            continue
                        end
                        
                        %look for multiline string
                        if size(fvalue,1)==1 && size(fvalue,2)>1 && ~isempty(strfind(fvalue,char(10)))
                            self.controls = [self.controls; {'multiedit' fname}];
                        elseif all(size(fvalue)>[1 1])
                            self.controls = [self.controls; {'multiedit' fname}];
                        else
                            self.controls = [self.controls; {'edit' fname}];
                        end
                        
                    case 'cell'
                        if iscellstr(fvalue) && size(fvalue,1)==1 %row vector
                            self.controls = [self.controls; {'popupmenu' fname}];
                        elseif iscellstr(fvalue) && size(fvalue,2)==1 %col vector
                            self.controls = [self.controls; {'listbox' fname}];
                        else
                            self.controls = [self.controls; {'table' fname}];
                        end
                        
                    case 'struct'
                        self.controls = [self.controls; {'struct' fname}];
                        
                    case 'function_handle'
                        
                        if nargin(fvalue)==0
                            self.controls = [self.controls; {'miscbutton' fname}];
                        else
                            self.controls = [self.controls; {'unknown' fname}];
                        end
                    otherwise
                        self.controls = [self.controls; {'unknown' fname}];
                        
                end
                
            end
        end
        function cancelCallback(self, varargin)
            self.outputStruct = self.inputStruct;
            if ~isempty(self.additionalCancelCallback)
                feval(self.additionalCancelCallback)
            end
            if self.closeOnCancel 
                close(self)
            else
                for ni = 1:size(self.handles,1)
                    type  = self.handles{ni,5};
                    fname = self.handles{ni,6};
                    
                    switch type
                        
                        case {'edit','multiedit'}
                            set(self.handles{ni,1},'string',self.inputStruct.(fname));  
                        case 'popupmenu'
                            set(self.handles{ni,1},'string',cellstr(self.inputStruct.(fname)));  
                        case 'listbox'
                            set(self.handles{ni,1},'string',self.inputStruct.(fname));  
                        case 'table'
                            set(self.handles{ni,1},'Data',self.inputStruct.(fname));  
                        case 'struct'
                            %do nothing
                        otherwise
                            if ~isempty(fname)
                                set(self.handles{ni,1},'value',self.inputStruct.(fname));  
                            end
                    end        
                end
            end
        end    
        function okCallback(self, varargin)
        
            if isequal(self.dlgmode,'edit')
                parseOutput(self)
            end
            
            if ~isempty(self.additionalOkCallback)
                feval(self.additionalOkCallback)
            end
            
            if self.closeOnOk
                close(self)
            end
        end
        function parseOutput(self)
            for ni=1:size(self.handles,1)
                
                hh    = self.handles{ni,1};
                type  = self.handles{ni,5};
                fname = self.handles{ni,6};
                
                switch type
                    
                    case {'edit','multiedit'}
                        self.outputStruct.(fname) = get(hh,'String');
                    case 'checkbox'
                        self.outputStruct.(fname) = logical(get(hh,'Value'));
                    case 'popupmenu'
                        contents = get(hh,'String');
                        self.outputStruct.(fname) = cellstr(contents{get(hh,'Value')});
                    case 'listbox'
                        contents = get(hh,'String');
                        self.outputStruct.(fname) = contents(get(hh,'Value'));
                    case 'table'
                        self.outputStruct.(fname) = get(hh,'Data');
                    case 'file'
                        self.outputStruct.(fname) = get(hh,'String');
                    case 'struct'
                        %do nothing
                    otherwise
                        %do nothing
                end
            end
        end
        function close(self)
            set(self.overlayPanel,'visible','off');
            if self.madeThisWindow
                try %#ok<TRYNC>
                    close(self.fig);
                end
            end
        end
        
        function keyPressFunction(self, hObject,eventdata) %#ok<MANU>
            if isequal(eventdata.Key,'return')
                callback = get(hObject,'Callback');
                callback(hObject,[]);
            end
        end
        function subStructOpenFcn(self, hObject, eventdata, fname)
            newInputStruct = self.inputStruct.(fname);
            
            newObject = prtUiStructDlg('inputStruct',newInputStruct); % To be cherry you will also need to copy over all size properties. Unfinished at this time.
            
            self.outputStruct.(fname) = newObject.outputStruct;
            
            self.additionalOkCallback();
            
        end
        function fileButtonCallback(self, hObject, eventdata, fname, fieldHandle)
            
            cValue = get(fieldHandle,'string');
            
            [cPath, cFile, cExt] = fileparts(cValue);
            
            [outFile,outPath] = uigetfile('*.mat',cat(2,'Select ', fname), cat(2,cFile,cExt));
           
            if all(outFile == 0)
                % user cancel
                % Do nothing
                return
            end
            
            newValue = fullfile(outPath,outFile);
            
            set(fieldHandle,'string',newValue);
                        
        end
    end
    methods (Static)
        function str = fieldNameToString(vname)
            str = vname;
            
            idx = find((upper(vname)-vname)==0);
            
            if ~isempty(idx)
                
                if idx(1)>1
                    str = [vname(1:idx(1)-1) ' '];
                else
                    str = '';
                end
                
                for i=1:numel(idx)-1
                    str = [str vname(idx(i):idx(i+1)-1) ' '];
                end
                
                str = [str vname(idx(end):end)];
            end
            
            str(1) = upper(str(1));
        end
    end
end

% % clear classes
% 
% s = struct;
% s.ScalarValue = 1.2;
% s.MatrixData = rand(10);
% s.SingleLineString = 'This is a single line string';
% s.MultipleLineString1 = sprintf('This is\na multi-line\nstring');
% s.MultipleLineString2 = strvcat({'This is','a multi-line','string','too'});
% s.LogicalValue = true;
% s.LogicalArray = [true false false true];
% s.CellArrayOfStringRow = {'Choice one','Choice two','Choice three'};
% s.CellArrayOfStringCol = {'Item1';'Item2';'Item3'};
% s.SubStruct = struct('FieldA',0,'FieldB','Hello!','FieldC',rand(10));
% s.HeterogeneousCellArray = {...
%     'Key1' rand 'string1' true;...
%     'Key2' rand 'string2' false;...
%     'Key3' rand 'string3' true;...
%     'Key4' rand 'string4' true;...
%     };
% s.FileName = '#<file>C:\Users\KDM\Documents\New Folder\MATLAB\hci\kdmTodo.txt';
% selectorObj = prtUiStructDlg('inputStruct',s,'uiFontSize',8,'uitextheight',30,'uiheightunit',30,'dyunit',20,'uibuttonwidth',100,'uibuttonheight',50);
% 
% %%
% clear classes
% 
% s.FileName = '#<file>C:\Users\KDM\Documents\New Folder\MATLAB\hci\kdmTodo.txt';
% selectorObj = prtUiStructDlg('inputStruct',s,'uiFontSize',16,'uitextheight',30,'uiheightunit',30,'dyunit',20,'uibuttonwidth',100,'uibuttonheight',50);
% 
% sOut = selectorObj.outputStruct;

