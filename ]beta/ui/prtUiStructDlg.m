classdef prtUiStructDlg < prtUiManagerPanel
    properties
        inputStruct
        outputStruct
        
        windowSize = [500 300];
        
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
        uicorewidth    = 400; %can be overrided by the option struct
        
        uitextheight   = 13;
        uiheightunit   = 20;
        
        uimultieditfac = 4; %can be overrided by the option struct
        uilistboxfac   = 4; %can be overrided by the option struct
        uitablemaxrow  = 4; %can be overrided by the option struct
        
        uibuttonwidth  = 60;
        uibuttonheight = 20;
        
        dxunit = 10;
        dyunit = 10;
        
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
            
            waitfor(self.overlayPanel);
            
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
                'tag','hciMessage',...
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
                    'HorizontalAlignment','left'...
                    );
                
                self.figheight = self.figheight + self.uitextheight + self.dyunit/2;
                
                self.handles = [self.handles; {h [] uiwidth self.uitextheight 'text' ''}];
                
                switch type
                    
                    case 'table'
                        h = uitable(self.overlayPanel,...
                            'Enable',self.enablemode,...
                            'Data',fvalue,...
                            'ColumnEditable',true,...
                            'Units','pixel'...
                            );
                        hBtn = [];
                        
                        uitableheight = min(18*(self.uitablemaxrow)+22,...
                            18*(size(fvalue,1))+22);
                        
                        currwidth  = uiwidth;
                        currheight = uitableheight;
                        self.figheight  = self.figheight + currheight;
                        
                    case 'checkbox'
                        h = uicontrol(self.overlayPanel,...
                            'Enable',self.enablemode,...
                            'Style',type,...
                            'Value',fvalue,...
                            'HorizontalAlignment','left'...
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
                            'BackgroundColor','white'...
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
                            'BackgroundColor','white'...
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
                            'Max',3 ...
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
                            'Max',3 ...
                            );
                        hBtn = [];
                        
                        currwidth  = uiwidth;
                        currheight = self.uilistboxfac*self.uiheightunit;
                        self.figheight  = self.figheight + currheight;
                        
                    case 'struct'
                        h = uicontrol(self.overlayPanel,...
                            'Style','edit',...
                            'String','<Struct>',...
                            'Enable','off',...
                            'HorizontalAlignment','left',...
                            'BackgroundColor','white'...
                            );
                        
                        currwidth  = uiwidth;
                        currheight = self.uiheightunit;
                        self.figheight  = self.figheight + currheight;
                        
                        hBtn = uicontrol(self.overlayPanel,...
                            'Style','pushbutton',...
                            'String','...',...
                            'Callback',{@self.subStructOpenFcn,fname}...
                            );
                        
                    otherwise
                        h = uicontrol(self.overlayPanel,...
                            'Style','edit',...
                            'String',['<' class(fvalue) '>'],...
                            'Enable','off',...
                            'HorizontalAlignment','left',...
                            'BackgroundColor','white'...
                            );
                        
                        hBtn = [];
                        
                        currwidth  = uiwidth;
                        currheight = self.uiheightunit;
                        self.figheight  = self.figheight + currheight;
                end
                
                self.figheight = self.figheight + self.dyunit;
                
                self.handles = [self.handles; {h hBtn currwidth currheight type fname}];
            end
            
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
            set(self.scrollable,'Units','pixels','ScrollArea',[1 1-self.figheight self.figwidth self.figheight])
            set(self.scrollable,'Units','normalized');
            
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
                    width = width - self.dxunit - self.uibuttonwidth/2;
                    set(hBtn,'Position',[x+width+self.dxunit y-height+self.uiheightunit self.uibuttonwidth/2 self.uibuttonheight]);
                end
                
                set(h,'Position',[x y-height+self.uiheightunit width height]);
                
                y = y - height - dy;
                
            end
            
            usableWidth = (pos(3)-self.uirightmargin-self.uilefttmargin-self.scrollable.scrollBarWidth);
            
            set(self.okButton,'Position',[self.uilefttmargin+usableWidth/2-self.dxunit-self.uibuttonwidth y-self.dyunit/2 self.uibuttonwidth self.uibuttonheight]);
            set(self.cancelButton,'Position',[self.uilefttmargin+usableWidth/2+self.dxunit y-self.dyunit/2 self.uibuttonwidth self.uibuttonheight]);
            
            %set(self.scrollable,'Units','pixels',
            %initScrollArea
            newScrollArea = [1 1 self.figwidth self.figheight];
            newScrollArea(1) = 1-(-(initScrollArea(1)-1)/initScrollArea(3)*self.figwidth);
            newScrollArea(2) = 1-(-(initScrollArea(2)-1)/initScrollArea(4)*self.figheight);
            
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
                        
                    otherwise
                        self.controls = [self.controls; {'unknown' fname}];
                        
                end
                
            end
        end
        function cancelCallback(self, varargin)
            self.outputStruct = self.inputStruct;
            close(self)
        end    
        function okCallback(self, varargin)
        
            if isequal(self.dlgmode,'edit')
                
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
                        case 'struct'
                            %do nothing
                        otherwise
                            %do nothing
                    end
                end
            end
            
            close(self)
        end
        function close(self)
            if self.madeThisWindow
                try %#ok<TRYNC>
                    close(self.fig);
                end
            else
                delete(self.overlayPanel);
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
            
            newObject = prtUiStructDlg('inputStruct',newInputStruct);
            
            self.outputStruct.(fname) = newObject.outputStruct;
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