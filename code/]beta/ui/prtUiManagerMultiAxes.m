classdef prtUiManagerMultiAxes < prtUiManagerPanel

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
    properties (SetAccess = 'protected', GetAccess = 'protected', Hidden)

        axesManagersDepHelper
    end
    properties (Dependent)
        axesManagers
        nAxes
    end
    methods
        function self = prtUiManagerMultiAxes(varargin)
            if nargin
                self = prtUtilAssignStringValuePairs(self, varargin{:});
            end
            
            if ~self.hgIsValid
               self.create()
           end
        end
        
        function set.axesManagers(self,val)
            if iscell(val)
                self.axesManagersDepHelper = val(:);
            else
                self.axesManagersDepHelper = num2cell(val(:));
            end
        end
        function val = get.axesManagers(self)
            val = self.axesManagersDepHelper;
        end
        function set.nAxes(self,val) %#ok<MANU,INUSD>
            error('prt:prtGuiManagerMultiAxes:badSet','propeties nAxes is read only');
        end
        function val = get.nAxes(self)
            val = length(self.axesManagers);
        end
        
        function setAll(self, propName, propVal)
            for iAxes = 1:self.nAxes
                set(self.axesManagers{iAxes}, propName, propVal);
            end
        end
        function setAllHandles(self, propName, propVal)
            for iAxes = 1:self.nAxes
                set(self.axesManagers{iAxes}.managedHandle, propName, propVal);
            end
        end
    end
end
