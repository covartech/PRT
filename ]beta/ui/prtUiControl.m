classdef prtUiControl < hgsetget

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

        handle
    end

    properties (Dependent)
        backgroundColor
        beingDeleted
        busyAction
        buttonDownFcn
        callback
        cData
        children
        createFcn
        deleteFcn
        enable
        extent
        fontAngle
        fontName
        fontSize
        fontUnits
        fontWeight
        foregroundColor
        handleVisibility
        hitTest
        horizontalAlignment
        interruptible
        keyPressFcn
        listboxTop
        max
        min
        parent
        position
        selected
        selectionHighlight
        sliderStep
        string
        style
        tag
        tooltipString
        type
        uiContextMenu
        units
        userData
        value
        visible
    end
    methods
        function self = prtUiControl(varargin)
            self.handle = uicontrol(varargin{:});
        end
        
        function set.backgroundColor(self, val)
            set(self.handle,'backgroundColor',val);
        end
        function val = get.backgroundColor(self)
            val = get(self.handle,'backgroundColor');
        end
        function set.beingDeleted(self, val)
            set(self.handle,'beingDeleted',val);
        end
        function val = get.beingDeleted(self)
            val = get(self.handle,'beingDeleted');
        end
        function set.busyAction(self, val)
            set(self.handle,'busyAction',val);
        end
        function val = get.busyAction(self)
            val = get(self.handle,'busyAction');
        end
        function set.buttonDownFcn(self, val)
            set(self.handle,'buttonDownFcn',val);
        end
        function val = get.buttonDownFcn(self)
            val = get(self.handle,'buttonDownFcn');
        end
        function set.callback(self, val)
            set(self.handle,'callback',val);
        end
        function val = get.callback(self)
            val = get(self.handle,'callback');
        end
        function set.cData(self, val)
            set(self.handle,'cData',val);
        end
        function val = get.cData(self)
            val = get(self.handle,'cData');
        end
        function set.children(self, val)
            set(self.handle,'children',val);
        end
        function val = get.children(self)
            val = get(self.handle,'children');
        end
        function set.createFcn(self, val)
            set(self.handle,'createFcn',val);
        end
        function val = get.createFcn(self)
            val = get(self.handle,'createFcn');
        end
        function set.deleteFcn(self, val)
            set(self.handle,'deleteFcn',val);
        end
        function val = get.deleteFcn(self)
            val = get(self.handle,'deleteFcn');
        end
        function set.enable(self, val)
            set(self.handle,'enable',val);
        end
        function val = get.enable(self)
            val = get(self.handle,'enable');
        end
        function set.extent(self, val)
            set(self.handle,'extent',val);
        end
        function val = get.extent(self)
            val = get(self.handle,'extent');
        end
        function set.fontAngle(self, val)
            set(self.handle,'fontAngle',val);
        end
        function val = get.fontAngle(self)
            val = get(self.handle,'fontAngle');
        end
        function set.fontName(self, val)
            set(self.handle,'fontName',val);
        end
        function val = get.fontName(self)
            val = get(self.handle,'fontName');
        end
        function set.fontSize(self, val)
            set(self.handle,'fontSize',val);
        end
        function val = get.fontSize(self)
            val = get(self.handle,'fontSize');
        end
        function set.fontUnits(self, val)
            set(self.handle,'fontUnits',val);
        end
        function val = get.fontUnits(self)
            val = get(self.handle,'fontUnits');
        end
        function set.fontWeight(self, val)
            set(self.handle,'fontWeight',val);
        end
        function val = get.fontWeight(self)
            val = get(self.handle,'fontWeight');
        end
        function set.foregroundColor(self, val)
            set(self.handle,'foregroundColor',val);
        end
        function val = get.foregroundColor(self)
            val = get(self.handle,'foregroundColor');
        end
        function set.handleVisibility(self, val)
            set(self.handle,'handleVisibility',val);
        end
        function val = get.handleVisibility(self)
            val = get(self.handle,'handleVisibility');
        end
        function set.hitTest(self, val)
            set(self.handle,'hitTest',val);
        end
        function val = get.hitTest(self)
            val = get(self.handle,'hitTest');
        end
        function set.horizontalAlignment(self, val)
            set(self.handle,'horizontalAlignment',val);
        end
        function val = get.horizontalAlignment(self)
            val = get(self.handle,'horizontalAlignment');
        end
        function set.interruptible(self, val)
            set(self.handle,'interruptible',val);
        end
        function val = get.interruptible(self)
            val = get(self.handle,'interruptible');
        end
        function set.keyPressFcn(self, val)
            set(self.handle,'keyPressFcn',val);
        end
        function val = get.keyPressFcn(self)
            val = get(self.handle,'keyPressFcn');
        end
        function set.listboxTop(self, val)
            set(self.handle,'listboxTop',val);
        end
        function val = get.listboxTop(self)
            val = get(self.handle,'listboxTop');
        end
        function set.max(self, val)
            set(self.handle,'max',val);
        end
        function val = get.max(self)
            val = get(self.handle,'max');
        end
        function set.min(self, val)
            set(self.handle,'min',val);
        end
        function val = get.min(self)
            val = get(self.handle,'min');
        end
        function set.parent(self, val)
            set(self.handle,'parent',val);
        end
        function val = get.parent(self)
            val = get(self.handle,'parent');
        end
        function set.position(self, val)
            set(self.handle,'position',val);
        end
        function val = get.position(self)
            val = get(self.handle,'position');
        end
        function set.selected(self, val)
            set(self.handle,'selected',val);
        end
        function val = get.selected(self)
            val = get(self.handle,'selected');
        end
        function set.selectionHighlight(self, val)
            set(self.handle,'selectionHighlight',val);
        end
        function val = get.selectionHighlight(self)
            val = get(self.handle,'selectionHighlight');
        end
        function set.sliderStep(self, val)
            set(self.handle,'sliderStep',val);
        end
        function val = get.sliderStep(self)
            val = get(self.handle,'sliderStep');
        end
        function set.string(self, val)
            set(self.handle,'string',val);
        end
        function val = get.string(self)
            val = get(self.handle,'string');
        end
        function set.style(self, val)
            set(self.handle,'style',val);
        end
        function val = get.style(self)
            val = get(self.handle,'style');
        end
        function set.tag(self, val)
            set(self.handle,'tag',val);
        end
        function val = get.tag(self)
            val = get(self.handle,'tag');
        end
        function set.tooltipString(self, val)
            set(self.handle,'tooltipString',val);
        end
        function val = get.tooltipString(self)
            val = get(self.handle,'tooltipString');
        end
        function set.type(self, val)
            set(self.handle,'type',val);
        end
        function val = get.type(self)
            val = get(self.handle,'type');
        end
        function set.uiContextMenu(self, val)
            set(self.handle,'uiContextMenu',val);
        end
        function val = get.uiContextMenu(self)
            val = get(self.handle,'uiContextMenu');
        end
        function set.units(self, val)
            set(self.handle,'units',val);
        end
        function val = get.units(self)
            val = get(self.handle,'units');
        end
        function set.userData(self, val)
            set(self.handle,'userData',val);
        end
        function val = get.userData(self)
            val = get(self.handle,'userData');
        end
        function set.value(self, val)
            set(self.handle,'value',val);
        end
        function val = get.value(self)
            val = get(self.handle,'value');
        end
        function set.visible(self, val)
            set(self.handle,'visible',val);
        end
        function val = get.visible(self)
            val = get(self.handle,'visible');
        end
    end
end
