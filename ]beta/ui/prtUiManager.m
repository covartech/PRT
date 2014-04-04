classdef prtUiManager < hgsetget

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
    properties (Dependent)
        managedHandle
        parent
        position
        units
        visible
    end
    properties (SetAccess = 'protected', GetAccess = 'protected', Hidden)
        managedHandleDepHelper = [];
    end
    methods (Abstract)
        create(self)
    end
    methods
        
        function set.managedHandle(self, val)
            self.managedHandleDepHelper = val;
        end
        function val = get.managedHandle(self)
            val = self.managedHandleDepHelper;
            if ~ishandle(val)
                val = [];
            end
        end
        
        function val = hgIsValid(self)
            if isempty(self.managedHandle)
                val = false;
                return
            end
            val = ishandle(self.managedHandle);
        end
        
        function set.parent(self,val)
            set(self.managedHandle,'parent',val);
        end
        function val = get.parent(self)
            val = get(self.managedHandle,'parent');
        end
        function set.position(self,val)
            set(self.managedHandle,'position',val);
        end
        function val = get.position(self)
            val = get(self.managedHandle,'position');
        end
        function set.units(self,val)
            set(self.managedHandle,'units',val);
        end
        function val = get.units(self)
            val = get(self.managedHandle,'units');
        end
        function set.visible(self,val)
            set(self.managedHandle,'visible',val);
        end
        function val = get.visible(self)
            val = get(self.managedHandle,'visible');
        end
        
%         function delete(self)
%         % Having this method named delete() delete the axes makes
%         % clearing of the variable, delete the axes. Cool!
%             try
%               delete(self.managedHandle);
%             end
%         end
    end
end
