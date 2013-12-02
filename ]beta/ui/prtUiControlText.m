classdef prtUiControlText < hgsetget

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
        javaHandle
    end

    properties (Dependent)
        backgroundColor
        font
        fontSize
        verticalAlignment
        horizontalAlignment
        string
        units
        userData
        visible
        parent
        position
    end
    methods
        function self = prtUiControlText(parent, varargin)
            
            if mod(length(varargin),2)
                % Odd number of inputs
                pixelPos = varargin{1};
                varargin = varargin(2:end); % varargin is string value pairs
            else
                pixelPos = getpixelposition(parent);
            end
            
            %jLabel = javaObjectEDT('javax.swing.JLabel','');
            %[self.javaHandle, self.handle]  = javacomponent(jLabel,pixelPos, parent);
            [self.javaHandle, self.handle]  = javacomponent('javax.swing.JLabel',pixelPos, parent);
            
            self = prtUtilAssignStringValuePairs(self, varargin{:});
        end
        function set.backgroundColor(self, val)
            set(self.javaHandle,'Background',java.awt.Color(val(1),val(2),val(3)));
        end
        function val = get.backgroundColor(self)
            val = get(self.javaHandle,'Background');
            val = cat(2,val.getRed,val.getGreen,val.getBlue);
        end
        function set.font(self,val)
            cFont = self.javaHandle.getFont;
            set(self.javaHandle,'Font',java.awt.Font(val,cFont.getStyle,cFont.getSize))
        end
        function val = get.font(self)
            val = self.javaHandle.getFont.getFamily;
        end
        function set.fontSize(self, val)
            cFont = self.javaHandle.getFont;
            set(self.javaHandle,'Font',java.awt.Font(cFont.getFamily,cFont.getStyle,val))
        end
        function val = get.fontSize(self)
            val = get(self.javaHandle,'Font');
            val = val.getSize;
        end
        function set.string(self, val)
            if isempty(strfind(lower(val),'<html>'))
                val = cat(2,'<html>',val,'</html>');
            end
            
            set(self.javaHandle,'Text',val)
        end
        function val = get.string(self)
            val = get(self.javaHandle,'Text');
        end
        
        function val = get.verticalAlignment(self)
            val = self.javaHandle.getVerticalAlignment;
        end
        function set.verticalAlignment(self,val)
            if ischar(val)
                switch lower(val)
                    case 'top'
                        val = javax.swing.JLabel.TOP;
                    case 'bottom'
                        val = javax.swing.JLabel.BOTTOM;
                    case 'middle'
                        val = javax.swing.JLabel.CENTER;
                    otherwise
                        error('verticalAlignment must be top, bottom or middle');
                end
            end
                        
            self.javaHandle.setVerticalAlignment(val);
        end
        function val = get.horizontalAlignment(self)
            val = self.javaHandle.getVerticalAlignment;
        end
        function set.horizontalAlignment(self,val)
            if ischar(val)
                switch val
                    case 'left'
                        val = javax.swing.JLabel.LEFT;
                    case 'right'
                        val = javax.swing.JLabel.RIGHT;
                    case 'center'
                        val = javax.swing.JLabel.CENTER;
                    otherwise
                        error('horizontalAlignment must be left, right or center');
                end
            end
                        
            self.javaHandle.setHorizontalAlignment(val);
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
        function set.visible(self, val)
            set(self.handle,'visible',val);
        end
        function val = get.visible(self)
            val = get(self.handle,'visible');
        end
        
        function set.parent(self, val)
            set(self.handle,'parent',val)
        end
        function val = get.parent(self)
            val = get(self.handle,'parent');
        end
        
        function val =get.position(self)
            val = get(self.handle,'position');
        end
        function set.position(self,val)
            set(self.handle, 'position',val)
        end
        
%         function delete(self)
%             try
%                 delete(self.handle)
%             end
%             try
%                 delete(self.javaHandle)
%             end
%         end
    end
end
