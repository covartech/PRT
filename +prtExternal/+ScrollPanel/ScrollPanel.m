classdef ScrollPanel < hgsetget
%SCROLLPANEL A uipanel container with scrolling capabilities
%   Uipanels provide containment and groups axes and their children.  The
%   ScrollPanel provides the ability to define a scrollable area and the
%   panel is the viewport onto that area.
%
%   ScrollPanel does support the border properties of the uipanel object,
%   but in a slightly different way.  The border of the ScrollPanel does
%   not intrude upon the client area, but extends outward from it.  The
%   border of a panel is lightweight and would be obscured by the scrolling
%   objects in the scroll area.  The position of the object with the border
%   may be set using the OuterPosition property.
%
%   ScrollPanel properties:
%       Parent        - Identifies the figure or uipanel that contains the
%                       ScrollPanel object.
%       ScrollArea    - Defines the area relative the the object's position
%                       that can be scrolled through.  This area may never
%                       be less than the object's area.
%       Position      - The position of the object relative to its
%                       containing parent.  This position also serves as a
%                       viewport or window into the ScrollArea.
%       OuterPosition - The position of the object relative to its
%                       container, but including the border.
%       Backgroundcolor - The color of the viewport area.
%       Units         - The units of the ScrollPanel object as well as the
%                       ScrollArea.  The units of th me.
%       Visible       - Sets the visibility of the object.
%       ScrollMode    - Controls the appearance of scrollbars on the panel.
%                       'auto'       - automatically shows the appropriate
%                                      verticle or horizontal scrollbar if the
%                                      height or width of the ScrollArea is
%                                      greater than the height or width of the
%                                      object's position. This setting is the
%                                      default.
%                       'verticle'   - Will always display only a verticle
%                                      scrollbar.
%                       'horizontal' - will always display only a
%                                      horizontal scrollbar.
%                       'both'       - will always display both scrollbars.
%       handle        - This handle value should be used parent Handle
%                       Graphics objects to the ScrollPanel object, e.g.
%                       set(ax, 'Parent', h.handle).
%       BorderWidth, BorderPanel, Highlight Color, Shadow color - the
%                       properties of the ScrollPanel object equivalent to
%                       the ones on the uipanel object.
%   
%
%   Examples:
%
%       Create a plot larger than the viewport panels position:
%           h=ScrollPanel;
%           set(h,'Position',[.25 .25 .5 .5];
%           set(h, 'ScrollArea', [0 0 2 2])
%           ax=axes('parent',h.handle)
%           plot(ax,magic(3))
%
%       Scroll around a large image:
%           imdata = imread('ngc6543a.jpg');
%           h=ScrollPanel('Position',[.25 .25 .5 .5], ...
%                         'ScrollArea', [0 0 3 3]);
%           axes('Parent', h.handle, 'Position', [0 0 1 1]);
%           image(imdata);
%
%   An important point to note is that the ScrollPanel object has the same
%   limitations as the uipanel object in terms of clipping.  Heavyweight
%   objects such as uicontrols will not be clipped.  Since scrolling will
%   tend to move these heavyweight object outside the viewport position,
%   care much be used to achieve the desired result.
%
%   The use of OpenGL and surface objects in general is also problematic
%   since they are heavyweight.  So, it is advisable to stick to 2D without
%   transparency.
%
%   See also UIPANEL.

%   Author: Jason Kinchen, MATLAB 7.11.0.514 (R2010b)
%   Contact: jason.kinchen@gmail.com
%   Revision: 1.0 (12-Dec-2010)
%
%   Comments:
%

    properties (Hidden=true) %(Hidden = true, Access = private) % Edited for the PRT
        hBorderPanel            % A panel to manage the borders that won't clipped.
        hViewportPanel          % The main panel
        hScrollingPanel         % The container for the ScrollingArea
        hVScrollBar
        hHScrollBar
        
        privateMode = 'auto'    % The dependent workaround for the ScrollMode property
    end
    
    properties (Hidden = true, SetAccess = private)
        scrollBarWidth = 15;
    end
    
    properties (Dependent)
        %PARENT Parent object of the SCROLLBAR.
        %   Since ScrollPanel is not an internal Handle Graphics object,
        %   parenting must be done explicitly.  Use this property to set
        %   the parent container of the ScrollPanel object.
        %
        %   See also UIPANEL.
        Parent
        
        %SCROLLAREA The position vector relative to the object's Position.
        %   The ScrollArea property of the ScrollPanel defines the region
        %   that the main viewport panel may scroll.
        %
        %   See also UIPANEL.
        ScrollArea
        
        %POSITION This position vector defines where the visible viewport
        %   of the ScrollPanel appears relative to it's parent.
        %
        %   See also UIPANEL.
        Position
        
        %OUTERPOSITION This position vector defines the postion of the
        %   including the client region and the border.  Use this property
        %   to place the object if its place in the container is more
        %   important than the size of the scrolling viewport.
        OuterPosition
        
        %BACKGROUNDCOLOR The background color of the ScrollArea using a
        %   ColorSpec.
        %
        %   See also UIPANEL.
        BackgroundColor
        
        %UNITS The units (pixels, points, characters, inches, centimeters,
        %   normalized) of both the main viewport and the ScrollArea.
        %
        %   See also UIPANEL.
        Units
        
        %VISIBLE Hides or shows the ScrollPanel without changing any other
        %   property values.
        %
        %   See also UIPANEL.
        Visible
        
        %SCROLLMODE Determines how the scrollbars appear.  Valid values are:
        %      'auto'       - automatically shows the appropriate
        %                     verticle or horizontal scrollbar if the
        %                     height or width of the ScrollArea is
        %                     greater than the height or width of the
        %                     object's position.
        %      'verticle'   - Will always display only a verticle
        %                     scrollbar.
        %      'horizontal' - will always display only a
        %                     horizontal scrollbar.
        %       'both'      - will always display both scrollbars.
        %
        %   See also UIPANEL.
        ScrollMode = 'auto';
        
        %BORDERWIDTH The width of the main viewport panel's border in
        %   pixels.
        %
        %   See also UIPANEL.
        BorderWidth = 1;
        
        %BORDERTYPE 
        %   none | {etchedin} | etchedout | beveledin | beveledout | line
        %
        %   Border of the main viewport. Used to define the panel area graphically.
        %   Etched and beveled borders provide a 3-D look. Use the HighlightColor
        %   and ShadowColor properties to specify the border color of etched and 
        %   beveled borders. A line border is 2-D. Use the ForegroundColor 
        %   property to specify its color. 
        %
        %   See also UIPANEL.
        BorderType = 'etchedin';
        
        %FOREGROUNDCOLOR Color used for the 2-D border line. A three-element 
        %   RGB vector or one of the MATLAB predefined names, specifying the 
        %   font or line color. See the ColorSpec reference page for more 
        %   information on specifying color.
        %
        %   See also UIPANEL.
        ForegroundColor = [1 1 1];
        
        %HIGHLIGHTCOLOR 3-D frame highlight color. A three-element RGB vector 
        %   or one of the MATLAB predefined names, specifying the highlight 
        %   color. See the ColorSpec reference page for more information on 
        %   specifying color.
        %
        %   See also UIPANEL, COLORSPEC.
        HighlightColor = [1 1 1];
        
        %SHADOWCOLOR 3-D frame shadow color. A three-element RGB vector or 
        %   one of the MATLAB predefined names, specifying the shadow color. 
        %   See the ColorSpec reference page for more information on specifying 
        %   color.
        %
        %   See also UIPANEL, COLORSPEC.
        ShadowColor = [.5 .5 .5];
        
    end
    properties (SetAccess = private)
        %HANDLE Since ScrollPanel is not a builtin Handle Graphics object,
        %   this property is used to directly parent object to the
        %   ScrollArea.  This handle should not be used to parent the
        %   ScrollPanel object to some other container.  Use the Parent
        %   property for that.
        %
        %   See also UIPANEL.
        handle
    end
    
    methods
        % The ScrollPanel constructor which takes parameter-value pairs.
        function obj = ScrollPanel(varargin)
            fig = gcf;
            % Detect if the Parent was passed in, otherwise use current
            % figure.
            for i = 1 : 2 : length(varargin)
                name = varargin{i};
                value = varargin{i+1};
                switch name
                    case 'Parent'
                      	fig = value;
                    break;
                    otherwise;
                end
            end
            
            % Create the objects that make up the ScrollPanel.
            obj.hBorderPanel = uipanel('Parent', fig, ...'BackgroundColor', 'b',...
                                       'HandleVisibility', 'off');
                                     
            obj.hViewportPanel = uipanel('Parent', fig, ...'BackgroundColor', 'r',...
                                         'BorderType', 'none',...
                                         'HandleVisibility', 'off');
            obj.Parent = fig;
            % The ScrollArea defaults to the same size as the Main Viewport
            % panel.
            obj.hScrollingPanel = uipanel('Parent', obj.hViewportPanel, ...
                                          'BorderType', 'none',...
                                          'HandleVisibility','off');
                                      
            % The slider uicontrols (scrollbars) are created invisible, but
            % are positioned in anticipation of being used.
            obj.hVScrollBar = uicontrol('Style', 'slider',...
                                       'Parent', obj.hViewportPanel,...
                                       'Units','pixels',...
                                       'Visible', 'off',...
                                       'Enable', 'off',...
                                       'HandleVisibility', 'off');

            obj.hHScrollBar = uicontrol('Style', 'slider',...
                                       'Parent', obj.hViewportPanel,...
                                       'Units','pixels',...
                                       'Position', [0 0 1 .05],...
                                       'Visible', 'off',...
                                       'Enable', 'off',...
                                       'HandleVisibility', 'off');

            % Setup the scrollbar listeners.
            addlistener(obj.hVScrollBar, 'ContinuousValueChange', @obj.scroll);
            addlistener(obj.hHScrollBar, 'ContinuousValueChange', @obj.scroll);
            % Setup the main viewport's size listener.  Lot's of stuff
            % needs to happen when that viewport changes.
            if verLessThan('matlab','8.4')
                addlistener(obj.hViewportPanel, 'SizeChange', @obj.resize);
            else
                obj.hViewportPanel.SizeChangedFcn = @obj.resize;
            end
            
            % The ScrollingPanel is the exposed handle so that objects can
            % be children of it.
            obj.handle = obj.hScrollingPanel;
            
            % Work through the parameter-value pairs and set the initial
            % state of the properties.
            for i = 1 : 2 : length(varargin)
                name = varargin{i};
                value = varargin{i+1};
                switch name
                    case 'Parent'
                        obj.Parent = value;
                    case 'Units'
                        obj.Units = value;
                    case 'Position'
                        obj.Position = value;
                        drawnow;
                    case 'OuterPostion'
                        obj.ScrollArea = value;
                    case 'ScrollArea'
                        obj.ScrollArea = value;
                    case 'ScrollMode'
                        obj.ScrollMode = value;
                    case 'Visible'
                        obj.Visible = value;
                    case 'BorderWidth'
                        obj.BorderWidth = value;
                    case 'BorderType'
                        obj.BorderType = value;
                    case 'ForeGroundColor'
                        obj.ForeGroundColor = value;
                    case 'HighlightColor'
                        obj.HighlightColor = value;
                    case 'ShadowColor'
                        obj.ShadowColor = value;
                    otherwise
                        error(['Invalid property ' name]);
                end
            end
            obj.privateMode = obj.ScrollMode;
            obj.setSBPosition('both');
        end
        
        function set.Parent(obj, val)
            set(obj.hViewportPanel, 'Parent', val);
        end
        function val = get.Parent(obj)
            val = get(obj.hViewportPanel, 'Parent');
        end
        function set.ScrollArea(obj, pos)
            % If normalized, the position relative to the figure window is
            % not useful.  From the ScrollArea's perspective, it is from
            % zero -> one.
            if (strcmp(get(obj.hViewportPanel, 'Units'), 'normalized'))
                mPos = [0 0 1 1];
            else
                mPos = get(obj.hViewportPanel, 'Position');
                mPos(1:2)=[0 0];
            end

            % The ScrollArea must completely contain the main viewport
            % area.  If it is larger than the viewport, it must either be
            % inside it's position rectangle or lined up on the sides.
            newSPos(1:2:3) = limitLines(mPos(1:2:3), pos(1:2:3));
            newSPos(2:2:4) = limitLines(mPos(2:2:4), pos(2:2:4));
            if (strcmp(get(obj.hViewportPanel, 'Units'), 'pixels'))
                newSPos(1:2) = newSPos(1:2) + 1;
            end

            if pos(3) > mPos(3) || pos(4) > mPos(4)
                set(obj.hScrollingPanel, 'Position', newSPos);
                
                % In auto mode, the appropriate scrollbars must appear if the
                % length or width of the ScrollArea is greater than that of
                % the main viewport.
                if strcmp(obj.ScrollMode, 'auto')
                    if newSPos(3) > mPos(3)
                        set(obj.hHScrollBar, 'Visible', 'on', 'Enable', 'on');
                    else
                        set(obj.hHScrollBar, 'Visible', 'off', 'Enable', 'off');
                    end
                    if newSPos(4) > mPos(4)
                        set(obj.hVScrollBar, 'Visible', 'on', 'Enable', 'on');
                    else
                        set(obj.hVScrollBar, 'Visible', 'off', 'Enable', 'off');
                    end
                end
            else
                % The ScrollArea cannot be smaller than the main viewport,
                % so if we get here, the height and width is stored in the
                % position vector, the origin needs to be zero, unless the
                % units are pixels, which are 1 based.
                if strcmp(get(obj.hViewportPanel, 'Units'), 'pixels')
                    set(obj.hScrollingPanel, 'Position', [1 1 mPos(3) mPos(4)]);
                else
                    set(obj.hScrollingPanel, 'Position', [0 0 mPos(3) mPos(4)]);
                end

                %  Scrollbars need to go away if the ScrollArea and main
                %  viewport are the same size.
                if strcmp(obj.ScrollMode, 'auto')
                    set(obj.hHScrollBar, 'Visible', 'off', 'Enable', 'off');
                    set(obj.hVScrollBar, 'Visible', 'off', 'Enable', 'off');
                end
            end

            % Make sure the scrollbars are the right size and the thumbs
            % are set to the right position and width.
            obj.setSBPosition('both');                 
        end
        function pos = get.ScrollArea(obj)
            pos = get(obj.hScrollingPanel, 'Position');
        end
        function set.Position(obj, pos)
            % Go ahead and set the main viewport's position.
            drawnow;
            
            set(obj.hViewportPanel, 'Position', pos);
            setBorderPosition(obj);
            
            if (strcmp(get(obj.hViewportPanel, 'Units'), 'normalized'))
                pos = [0 0 1 1];
            end
            sPos = get(obj.hScrollingPanel, 'Position');
            if sPos(3) <= pos(3)
                % Don't let the width become smaller than the viewport, and
                % turn off the scrollbar if in auto mode.
                sPos(3) = max([pos(3) sPos(3)]);
                if strcmp(obj.ScrollMode, 'auto')
                    set(obj.hHScrollBar, 'Enable', 'off', 'Visible', 'off');
                end
            else
                if strcmp(obj.ScrollMode, 'auto')
                    set(obj.hHScrollBar, 'Enable', 'on', 'Visible', 'on');
                end
            end
            if sPos(4) <= pos(4)
                % Don't let the height become smaller than the viewport,
                % and turn off the scrollbar if in auto mode.
                sPos(4) = max([pos(4) sPos(4)]);
                if strcmp(obj.ScrollMode, 'auto')
                    set(obj.hVScrollBar, 'Enable', 'off', 'Visible', 'off');
                end
            else
                if strcmp(obj.ScrollMode, 'auto')
                    set(obj.hVScrollBar, 'Enable', 'on', 'Visible', 'on');
                end
            end
            set(obj.hScrollingPanel, 'Position', sPos);
            set(obj.hBorderPanel, 'Position', pos);
            setSBPosition(obj, 'both')
            
            
            
        end
        
        % Set/Get the following properties on the appropriate container.
        function pos = get.Position(obj)
            pos = get(obj.hViewportPanel, 'Position');
        end
        function set.OuterPosition(obj, pos)
        % The OuterPostion extends out from the position. The borderwidth
        % is always in pixels so we do all the adjustments in pixels.
            set(obj.hBorderPanel, 'Position', pos);
            drawnow;
            % The above lines set the postion in the current units and the
            % line below gets the new positoin in pixels.
            pxPos = getpixelposition(obj.hBorderPanel);
            
            % The position of the viewport panel must be adjusted in by the
            % BorderWidth.
            pxPos = [pxPos(1) + borderAdjust(obj) ...
                     pxPos(2) + borderAdjust(obj) ...
                     pxPos(3) - 2 * borderAdjust(obj) ...
                     pxPos(4) - 2 * borderAdjust(obj)];
            drawnow;
            setpixelposition(obj.hViewportPanel, pxPos);
            obj.setSBPosition('both');
        end
        function pos = get.OuterPosition(obj)
            pos = get(obj.hBorderPanel, 'Position');
        end
        function set.BackgroundColor(obj, color)
            set(obj.hScrollingPanel, 'BackgroundColor', color);
            %set(obj.hBorderPanel, 'BackgroundColor', color); %Editted for PRT
            set(obj.hViewportPanel, 'BackgroundColor', color); %Editted for PRT
        end
        function color = get.BackgroundColor(obj)
            color = set(obj.hScrollingPanel, 'BackgroundColor');
        end
        function set.Units(obj, units)
            set(obj.hBorderPanel', 'Units', units');
            set(obj.hViewportPanel, 'Units', units);
            set(obj.hScrollingPanel, 'Units', units);
        end
        function units = get.Units(obj)
            units = get(obj.hViewportPanel, 'Units');
        end
        function set.Visible(obj, val)
            set(obj.hViewportPanel, 'Visible', val)
        end
        function val = get.Visible(obj)
            val = get(obj.hViewportPanel, 'Visible');
        end
        function set.ScrollMode(obj, val)
            % Check that the value passed in is a valid value.
            valid = {'auto', 'verticle', 'horizontal', 'both'};
            if any(cellfun(@(x) strcmp(x,val),valid))
                % Since this is a dependent property, we need to save the
                % actual value in the private property.
                obj.privateMode = val;
                switch(val)
                    case 'auto'
                        % If auto mode is turned on, all the right things
                        % happen if we call the set method using the
                        % current value.
                        set(obj, 'ScrollArea', get(obj, 'ScrollArea'));
                    case 'verticle'
                        % Enable the verticle, disable the horizontal.
                        set(obj.hVScrollBar, 'Enable', 'on', 'Visible', 'on');
                        set(obj.hHScrollBar, 'Enable', 'off', 'Visible', 'off');
                        obj.setSBPosition('verticle');
                    case 'horizontal'
                        % Enable the horizontal, disable the verticle.
                        set(obj.hHScrollBar, 'Enable', 'on', 'Visible', 'on');
                        set(obj.hVScrollBar, 'Enable', 'off', 'Visible', 'off');
                        obj.setSBPosition('horizontal');
                    case 'both'
                        % Enable the horizontal and the verticle.
                        set(obj.hVScrollBar, 'Enable', 'on', 'Visible', 'on');
                        set(obj.hHScrollBar, 'Enable', 'on', 'Visible', 'on');
                        obj.setSBPosition('both');
                end

            else
                error('ScrollPanel:setScrollMode:badScrollModeValue',...
                      ['Bad property value ' val ' for ScrollMode.']);
            end
        end
        function val = get.ScrollMode(obj)
            val = obj.privateMode;
        end
        function set.BorderWidth(obj, val)
            set(obj.hBorderPanel, 'BorderWidth', val);
            setBorderPosition(obj);
        end
        function val = get.BorderWidth(obj)
            val = get(obj.hBorderPanel, 'BorderWidth');
        end
        function set.BorderType(obj, val)
            set(obj.hBorderPanel, 'BorderType', val);
            setBorderPosition(obj);
        end
        function val = get.BorderType(obj)
            val = get(obj.hBorderPanel, 'BorderType');
        end
        function set.ForegroundColor(obj, val)
            set(obj.hBorderPanel, 'ForegroundColor', val);
        end
        function val = get.ForegroundColor(obj)
            val = get(obj.hBorderPanel, 'ForegroundColor');
        end
        function set.HighlightColor(obj, val)
            set(obj.hBorderPanel, 'HighlightColor', val);
        end
        function val = get.HighlightColor(obj)
            val = get(obj.hBorderPanel, 'HighlightColor');
        end
        function set.ShadowColor(obj, val)
            set(obj.hBorderPanel, 'ShadowColor', val);
        end
        function val = get.ShadowColor(obj)
            val = get(obj.hBorderPanel, 'ShadowColor');
        end
        function delete(obj)
            if ishghandle(obj.hBorderPanel)
                delete(obj.hBorderPanel);
            end
            if ishghandle(obj.hViewportPanel)
                delete(obj.hViewportPanel);
            end
        end
    end
    methods (Access = protected)
        % Don't want to allow the user to call these.
        function setSBPosition(obj, scrollbar)
            % The scrollbars in in pixel units, so we need to get the
            % main viewport's position in pixels.
            pos = getpixelposition(obj.hViewportPanel);
            
            % We are doing similiar position calculations for horizontal
            % and verticle scrollbars.  The following just sets up the
            % appropriate variables.
            
            if strcmp(scrollbar, 'verticle') || strcmp(scrollbar, 'both')
                hScrollBar = obj.hVScrollBar;
                otherhScrollBar = obj.hHScrollBar;
                origin_i = 2;
                length_i = 4;
                scrPos = [1 + pos(3) - obj.scrollBarWidth ...
                          1 ...
                          obj.scrollBarWidth ...
                          pos(length_i)];
                bothPos = [scrPos(1) ...
                           scrPos(2) + obj.scrollBarWidth ...
                           scrPos(3) ...
                           scrPos(4) - obj.scrollBarWidth];
            else
                hScrollBar = obj.hHScrollBar;
                otherhScrollBar = obj.hVScrollBar;
                origin_i = 1;
                length_i = 3;
                scrPos = [1 ...
                          1 ...
                          pos(3)...
                          obj.scrollBarWidth];
                bothPos = [scrPos(1) ...
                           scrPos(2) ...
                           scrPos(3) - obj.scrollBarWidth ...
                           scrPos(4)];
            end

            % Use the private property scrollBarWidth and set the
            % one-based position based on the viewport's area.  The length
            % of the scrollbar is slightly shorter if the other one is
            % visible.
            if strcmp(get(otherhScrollBar, 'Visible'), 'on')
                set(hScrollBar, 'Position', bothPos);
            else
                set(hScrollBar, 'Position', scrPos);
            end
            sPos = get(obj.hScrollingPanel', 'Position');
            
            % Get the viewport panel's position to calculate the thumbsize
            % and positon of the thumb.
            if strcmp(get(obj.hViewportPanel, 'Units'), 'normalized')
                mPos = [0 0 1 1];
            else
                mPos = get(obj.hViewportPanel, 'Position');
            end
            
            %Stepsize determines the thumb size.
            step = get(hScrollBar, 'SliderStep');
            step(2) = min(max(step(1)*2, mPos(length_i)/(sPos(length_i) - mPos(length_i))),0.5);
            
            set(hScrollBar, 'SliderStep', step);
            
            if mPos(origin_i) == sPos(origin_i)
                slpos = 0;
            else if mPos(origin_i) + mPos(length_i) == sPos(origin_i) + sPos(length_i)
                slpos = 1;
                else
                    slpos = min([1, (mPos(origin_i) - sPos(origin_i))/(sPos(length_i)-mPos(length_i))]);
                end
            end
            
            set(hScrollBar, 'Value', slpos);
            
            if strcmp(scrollbar, 'both')
                setSBPosition(obj, 'horizontal');
            end
        end
        function val = borderAdjust(obj)
            val = get(obj.hBorderPanel, 'BorderWidth');
            switch get(obj.hBorderPanel, 'BorderType')
                case 'etchedin'
                    val = val * 2;
                case 'etchedout'
                    val = val * 2;
                case 'none'
                    val = 0;
                otherwise
            end
        end
        function setBorderPosition(obj)
            pxPos = getpixelposition(obj.hViewportPanel);
            setpixelposition(obj.hBorderPanel, [pxPos(1) - borderAdjust(obj) ...
                                                pxPos(2) - borderAdjust(obj) ...
                                                pxPos(3) + 2*borderAdjust(obj) ...
                                                pxPos(4) + 2*borderAdjust(obj)]);
        end
        function resize(obj, ~, ~)
            % After the viewport position is set, we need to move the
            % scrollbars back to the edges.
            drawnow;
            obj.setSBPosition('both');
            setBorderPosition(obj);
        end      
        function scroll(obj, src, ~)
            % Again, normalized coordinates will need to be set manually
            % because it returns those relative to the figure window.
            if strcmp(get(obj.hViewportPanel, 'Units'), 'normalized')
                mPos = [0 0 1 1];
            else
                mPos = get(obj.hViewportPanel, 'Position');
            end
            
            sPos = get(obj.hScrollingPanel, 'Position');
            
            % Setup the variables for the appropriate scrollbar.
            if src == obj.hVScrollBar
                hScrollBar = obj.hVScrollBar;
                length_i = 4;
            else
                hScrollBar = obj.hHScrollBar;
                length_i = 3;
            end

            % Get the position of the slider, calcuate the ratio of
            % viewport to ScrollArea and set the new position of the
            % ScrollArea.
            value = get(hScrollBar, 'Value');
            pos = (sPos(length_i) - mPos(length_i))*(-value);
            if strcmp(get(obj.hScrollingPanel, 'Units'), 'pixels')
                pos = pos + 1;
            end
            if src == obj.hVScrollBar
                sPos = [sPos(1) pos sPos(3) sPos(4)];
            else
                sPos = [pos sPos(2) sPos(3) sPos(4)];
            end
            set(obj.hScrollingPanel, 'Position', sPos);
        end
    end
    methods (Hidden = true)
        function [h v] = getSBPosition(obj)
            h = get(obj.hHScrollBar, 'Position');
            v = get(obj.hVScrollBar, 'Position');
        end
    end
end

function newLine = limitLines(smallLine, largeLine)
% Limit a longer line to the endpoints of the smaller line.  In other
% words, the extents of the smaller line must be within those of the larger
% line.
    sStart = smallLine(1);
    sEnd = smallLine(1) + smallLine(2);
    
    lStart = largeLine(1);
    lEnd = largeLine(1) + largeLine(2);
    lLength = largeLine(2);

    if lStart < sStart && lEnd < sEnd
        newLine(2) = lLength;
        newLine(1) = sEnd - lLength;
    else if lStart > sStart
            newLine(1) = sStart;
            newLine(2) = lLength;
        else
            newLine = largeLine;
        end
    end
end








