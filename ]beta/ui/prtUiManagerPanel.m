classdef prtUiManagerPanel < prtUiManager

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

        title
        fontSize
    end
    
    methods
        function self = prtUiManagerPanel(varargin)
           if nargin
                self = prtUtilAssignStringValuePairs(self, varargin{:});
           end
            
           if nargin~=0 && ~self.hgIsValid
               self.create()
           end
        end
        
        function create(self)
            self.managedHandle = uipanel('BackgroundColor',get(0,'DefaultFigureColor'),...
                'BorderType','none');
        end
        
        function set.title(self,str)
            set(self.managedHandle,'title',str)
        end
        function val = get.title(self)
            val = get(self.managedHandle,'title');
        end
        
        function val = get.fontSize(self)
            val = get(self.managedHandle,'fontSize');
        end
        function set.fontSize(self,val)
            set(self.managedHandle, 'fontsize', val);
        end
        
    end
end
