function varargout = structdlg(varargin)
%  STRUCTDLG Struct dialog box.
%
%    ANSWER = STRUCTDLG(S) creates a modal dialog box that returns user
%    input for multiple prompts in the struct ANSWER. S is the default struct. 
%    Each prompt string will inherit the S' fields name.
%    ANSWER will be the same struct as S except for fields of type "cell array of string"
%    that will be returned as a single string (that selected by the user).
%    Dialog supports field of following types:
%       - numeric   (both scalar and multi-dimensional)
%       - string    (both single-line and multi-line)
%       - logical   (both scalar and multi-dimensional)
%       - cellarray (both strings and heterogeneous data-types)
%       - struct
%  
%    NOTE: for heterogeneous cellarray only numeric logical and strings are supported.
%   
%    STRUCTDLG uses UIWAIT to suspend execution until the user responds.
%  
%    ANSWER = STRUCTDLG(S,NAME) specifies dialog title
%
%    ANSWER = STRUCTDLG(S,NAME,OPTIONS) specifies the option structure.
%    Allowed options are:   
%       
%    |==================|=================|=================================|
%    | STRUCT FIELD     | DEFAULT VALUE   | DESCRIPTION                     |
%    |==================|=================|=================================|
%    | MultiEditHeight  | 4               | scale factor                    |
%    |------------------|-----------------|---------------------------------|
%    | ListboxHeight    | 4               | scale factor                    | 
%    |------------------|-----------------|---------------------------------|
%    | TableMaxRowNum   | 4               | max number of row               |
%    |------------------|-----------------|---------------------------------|
%    | DialogWidth      | 400             | expressed in default units. It  |
%    |                  |                 | does not include left and right |
%    |                  |                 | margins                         |
%    |------------------|-----------------|---------------------------------|
%    | FontName         | Arial           | Affects all controls            |
%    |==================|=================|=================================|
%
%   
%
%    Example 1:
%
%       s = struct;
%       s.ScalarValue = 1.2;
%       s.MatrixData = rand(10);
%       s.SingleLineString = 'This is a single line string';
%       s.MultipleLineString1 = sprintf('This is\na multi-line\nstring');
%       s.MultipleLineString2 = strvcat({'This is','a multi-line','string','too'});
%       s.LogicalValue = true;
%       s.LogicalArray = [true false false true];
%       s.CellArrayOfStringRow = {'Choice one','Choice two','Choice three'};
%       s.CellArrayOfStringCol = {'Item1';'Item2';'Item3'};
%       s.SubStruct = struct('FieldA',0,'FieldB','Hello!','FieldC',rand(10));
%       s.UnhandledDataType = Simulink.Parameter;
%       s.HeterogeneousCellArray = {...
%                                   'Key1' rand 'string1' true;...
%                                   'Key2' rand 'string2' false;...
%                                   'Key3' rand 'string3' true;...
%                                   'Key4' rand 'string4' true;...
%                                   };
%
%       options.DialogWidth = 500;
%       options.FontName = 'Verdana'
%
%       sout = structdlg(s,'Title',options);
%
%
%    Example 2:
%
%       s = struct;
%       s.TextToShow = sprintf('The function is useful also\nif you need to display a simple text');
%
%       structdlg(s,'Text Viewer');
%
%

    %%Check input arguments
    switch nargin
        case 0
            error('structdlg:tooFewInputArguments','Too few input arguments');
        case 1
            sdata    = varargin{1};
            dlgtitle = 'Struct Dialog';
            options  = struct;
        case 2
            sdata    = varargin{1};
            dlgtitle = varargin{2};
            options  = struct;
        case 3
            sdata    = varargin{1};
            dlgtitle = varargin{2};
            options  = varargin{3};
       otherwise
            error('structdlg:tooManyInputArguments','Too many input arguments');
    end
    
    %%Check output arguments
    switch nargout
        case 0
            fcnoutput = false;
            dlgmode = 'readonly';
            enablemode = 'inactive';
        case 1
            fcnoutput = true;
            dlgmode = 'edit';
            enablemode = 'on';
        otherwise
            error('structdlg:tooManyOutputArguments','Too many output arguments');
    end
   
    %%Check input consistency
    validateattributes(sdata,{'struct'},{'scalar'});
    validateattributes(dlgtitle,{'char'},{'row','nonempty'});
    validateattributes(options,{'struct'},{'scalar'});
   
    %%Parse struct data
    dataf = fields(sdata);
    
    controls = {};
    handles  = {};

    for i=1:numel(dataf)
        
        fname  = dataf{i};
        fvalue = sdata.(fname);
        fclass = class(fvalue);
        
        switch fclass
            
            case {'double', 'single',...
                  'int8',   'uint8',...
                  'int16',  'uint16',...
                  'int32',  'uint32',...
                  'int64',  'uint64'}
              
                controls = [controls; {'table' fname}];
              
            case 'logical'
                if numel(fvalue)>1
                    controls = [controls; {'table' fname}];
                else
                    controls = [controls; {'checkbox' fname}];
                end
                
            case 'char'
                %look for multiline string
                if size(fvalue,1)==1 && size(fvalue,2)>1 && ~isempty(strfind(fvalue,char(10)))
                    controls = [controls; {'multiedit' fname}];
                elseif all(size(fvalue)>[1 1])
                    controls = [controls; {'multiedit' fname}];
                else
                    controls = [controls; {'edit' fname}];
                end
                
            case 'cell'
                if iscellstr(fvalue) && size(fvalue,1)==1 %row vector
                    controls = [controls; {'popupmenu' fname}];
                elseif iscellstr(fvalue) && size(fvalue,2)==1 %col vector
                    controls = [controls; {'listbox' fname}];
                else
                    controls = [controls; {'table' fname}];
                end
                
            case 'struct'
                controls = [controls; {'struct' fname}];
                
            otherwise 
                controls = [controls; {'unknown' fname}];
                
        end
        
    end
    
    
    %%Define layout constants
    screensize = get(0,'ScreenSize');
    maxx = screensize(3);
    maxy = screensize(4);

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
    
    fontname = 'Arial'; %can be overrided by the option struct
    
    %Optional settings
    if isfield(options,'MultiEditHeight')
        uimultieditfac = max(2,options.MultiEditHeight);
    end
    if isfield(options,'ListboxHeight')
        uilistboxfac = max(2,options.ListboxHeight);
    end
    if isfield(options,'TableMaxRowNum')
        uitablemaxrow = options.TableMaxRowNum;
    end
    if isfield(options,'DialogWidth')
        uicorewidth = options.DialogWidth;
    end
    if isfield(options,'FontName')
        fontname = options.FontName;
    end
    
    %initial value for figure's height and width
    figwidth  = uilefttmargin + uirightmargin + uicorewidth;
    figheight = uitopmargin + uibottommargin;
    
    uiwidth = figwidth - uilefttmargin - uirightmargin;
    
    %%Create the main dialog
    hFig = dialog('Name', dlgtitle,...
                  'Units','pixel',...
                  'Visible','off',...
                  'CloseRequestFcn',@CancelFcn);

    %%Check if struct is empty
    if isempty(controls)
        h = uicontrol(hFig,...
                      'Style','text',...
                      'String','Empty struct',...
                      'FontName',fontname,...
                      'HorizontalAlignment','left'...
                      );
                  
        figheight  = figheight + uitextheight + dyunit/2;
                  
        handles = [handles; {h [] uiwidth uitextheight}];
    end
    
    %%Create an appropriate uicontrol for each field of struct
    for i=1:size(controls,1)
        
        type   = controls{i,1};
        fname  = controls{i,2};
        fvalue = sdata.(fname);
        description = iIdentifier2String(fname);
        
        h = uicontrol(hFig,...
                      'Style','text',...
                      'String',description,...
                      'FontName',fontname,...
                      'HorizontalAlignment','left'...
                      );
                  
        figheight = figheight + uitextheight + dyunit/2;
                  
        handles = [handles; {h [] uiwidth uitextheight 'text' ''}];

        switch type
            
            case 'table'
                h = uitable(hFig,...
                            'Enable',enablemode,...
                            'Data',fvalue,...
                            'FontName',fontname,...
                            'ColumnEditable',true,...
                            'Units','pixel'...
                            );
                hBtn = [];

                uitableheight = min(18*(uitablemaxrow)+22,...
                                    18*(size(fvalue,1))+22);

                currwidth  = uiwidth;
                currheight = uitableheight;
                figheight  = figheight + currheight;
            
            case 'checkbox'
                h = uicontrol(hFig,...
                              'Enable',enablemode,...
                              'Style',type,...
                              'Value',fvalue,...
                              'HorizontalAlignment','left'...
                              );
                hBtn = [];
                
                currwidth  = uiwidth;
                currheight = uiheightunit;
                figheight  = figheight + currheight;
            
            case 'edit'
                h = uicontrol(hFig,...
                              'Enable',enablemode,...
                              'Style',type,...
                              'String',fvalue,...
                              'FontName',fontname,...
                              'HorizontalAlignment','left',...
                              'BackgroundColor','white'...
                              );
                hBtn = [];

                currwidth  = uiwidth;
                currheight = uiheightunit;
                figheight  = figheight + currheight;
                
            case 'popupmenu'
                if isempty(fvalue)
                    fvalue = {''};
                end
          
                h = uicontrol(hFig,...
                              'Enable','on',...
                              'Style',type,...
                              'String',fvalue,...
                              'FontName',fontname,...
                              'HorizontalAlignment','left',...
                              'BackgroundColor','white'...
                              );
                hBtn = [];

                currwidth  = uiwidth;
                currheight = uiheightunit;
                figheight  = figheight + currheight;

            case 'multiedit'
                h = uicontrol(hFig,...
                              'Enable',enablemode,...
                              'Style','edit',...
                              'String',fvalue,...
                              'FontName',fontname,...
                              'HorizontalAlignment','left',...
                              'BackgroundColor','white',...
                              'Min',1,...
                              'Max',3 ...
                              );
                hBtn = [];

                currwidth  = uiwidth;
                currheight = uimultieditfac*uiheightunit;
                figheight  = figheight + currheight;
                     
            case 'listbox'
                h = uicontrol(hFig,...
                              'Enable',enablemode,...
                              'Style','listbox',...
                              'String',fvalue,...
                              'FontName',fontname,...
                              'HorizontalAlignment','left',...
                              'BackgroundColor','white',...
                              'Min',1,...
                              'Max',3 ...
                              );
                hBtn = [];

                currwidth  = uiwidth;
                currheight = uilistboxfac*uiheightunit;
                figheight  = figheight + currheight;
                
            case 'struct'
                h = uicontrol(hFig,...
                              'Style','edit',...
                              'String','<Struct>',...
                              'FontName',fontname,...
                              'Enable','off',...
                              'HorizontalAlignment','left',...
                              'BackgroundColor','white'...
                              );

                currwidth  = uiwidth;
                currheight = uiheightunit;
                figheight  = figheight + currheight;
                
                hBtn = uicontrol(hFig,...
                                 'Style','pushbutton',...
                                 'String','...',...
                                 'Callback',{@SubStructOpenFcn,fname}...
                                 );
                            
            otherwise
                h = uicontrol(hFig,...
                              'Style','edit',...
                              'String',['<' class(fvalue) '>'],...
                              'FontName',fontname,...
                              'Enable','off',...
                              'HorizontalAlignment','left',...
                              'BackgroundColor','white'...
                              );
                          
                hBtn = [];
                          
                currwidth  = uiwidth;
                currheight = uiheightunit;
                figheight  = figheight + currheight;
        end
        
        figheight = figheight + dyunit;
        
        handles = [handles; {h hBtn currwidth currheight type fname}];

    end
    
    %%Add OK and Cancel buttons
    hOk = uicontrol(hFig,...
                    'Style','pushbutton',...
                    'String','OK',...
                    'Callback',@OkFcn,...
                    'KeyPressFcn',@KeypressFcn...
                    );

    hCancel = uicontrol(hFig,...
                        'Style','pushbutton',...
                        'String','Cancel',...
                        'Callback',@CancelFcn,...
                        'KeyPressFcn',@KeypressFcn...
                        );
    
    %%Set dialog position
    figx = maxx/2-figwidth/2;
    figy = maxy/2-figheight/2;
    
    if figy<0
        warning('structdlg:dialogDispaly','Dialog may be not completely displayed');
    end
    
    set(hFig,'Position',[figx figy figwidth figheight]);
    
    ResizeControls();
    
    set(hFig,'Visible','on');
    
    uicontrol(hOk);

    uiwait(hFig);
    
    
    %% Nested functions --------------------------------------------------------
    
    %%Resize callback
    function ResizeControls(hObject,eventdata)%#ok
        
        x = uilefttmargin;
        y = figheight - uitopmargin;
        
        for ni=1:size(handles,1)
           
            h      = handles{ni,1};
            hBtn   = handles{ni,2};
            width  = handles{ni,3};
            height = handles{ni,4};
            
            type = get(h,'Type');
            
            switch type
                
                case 'uicontrol'
                    if isequal(get(h,'Style'),'text')
                        dy = dyunit/2;
                    else
                        dy = dyunit;
                    end
                    
                case 'uitable'
                    dy = dyunit;
                    
                otherwise
                    dy = 0;
            end
            
            if ~isempty(hBtn)
                width = width - dxunit - uibuttonwidth/2;
                set(hBtn,'Position',[x+width+dxunit y-height+uiheightunit uibuttonwidth/2 uibuttonheight]);
            end
            
            set(h,'Position',[x y-height+uiheightunit width height]);
            
            y = y - height - dy;
            
        end
        
        set(hOk,'Position',[figwidth-uirightmargin-2*uibuttonwidth-dxunit y-dyunit/2 uibuttonwidth uibuttonheight]);
        set(hCancel,'Position',[figwidth-uirightmargin-uibuttonwidth y-dyunit/2 uibuttonwidth uibuttonheight]);
    end

    %%KeyPressFcn callback
    function KeypressFcn(hObject,eventdata)
        
        if isequal(eventdata.Key,'return')
            callback = get(hObject,'Callback');
            callback(hObject,[]);
        end
    end

    %%Cancel callback
    function CancelFcn(hObject,eventdata)%#ok
        if fcnoutput 
            varargout{1} = sdata;
        end
        closereq
    end
    
    %%Ok callback
    function OkFcn(hObject,eventdata)%#ok
        
        if isequal(dlgmode,'edit')
            
            answer = sdata;
            
            for ni=1:size(handles,1)
                
                hh    = handles{ni,1};
                type  = handles{ni,5};
                fname = handles{ni,6};
                
                switch type
                    
                    case {'edit','multiedit'}
                        answer.(fname) = get(hh,'String');
                    case 'checkbox'
                        answer.(fname) = logical(get(hh,'Value'));
                    case 'popupmenu'
                        contents = get(hh,'String');
                        answer.(fname) = cellstr(contents{get(hh,'Value')});
                    case 'listbox'
                        contents = get(hh,'String');
                        answer.(fname) = contents(get(hh,'Value'));
                    case 'table'
                        answer.(fname) = get(hh,'Data');
                    case 'struct'
                        %do nothing
                    otherwise
                        %do nothing
                end
            end
            
            varargout{1} = answer;
        end
        
        closereq
    end
        
    %%SubStruct callback
    function SubStructOpenFcn(hObject,eventdata,fname)%#ok
        if fcnoutput
            sdata.(fname) = structdlg(sdata.(fname),iIdentifier2String(fname),options);
        else
            structdlg(sdata.(fname),iIdentifier2String(fname),options);
        end
    end

end


%% Sub functions --------------------------------------------------------
function str = iIdentifier2String(vname)

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
