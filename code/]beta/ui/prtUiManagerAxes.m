classdef prtUiManagerAxes < prtUiManager

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

        xlabel
        ylabel
        zlabel
        title
        fontSize
        titleFontSize
        fixedXLims
        fixedYLims
        fixedZLims
        hold
        
        defaultPosition = [0.1300    0.1100    0.7750    0.8150];
    end
    
    properties (Constant)
        factoryDefaultPosition = [0.1300    0.1100    0.7750    0.8150];
    end
    
    properties (Hidden = true)
        fixedLims = nan(1,6);
    end
    
    methods
        function self = prtUiManagerAxes(varargin)
            if nargin
                self = prtUtilAssignStringValuePairs(self, varargin{:});
            end
            
            if ~self.hgIsValid
               self.create()
           end
        end
        
        function set.xlabel(self,str)
            xlabel(self.managedHandle,str)
        end
        function val = get.xlabel(self)
            val = get(get(self.managedHandle,'xlabel'),'string');
        end
        
        function set.ylabel(self,str)
            ylabel(self.managedHandle,str)
        end
        function val = get.ylabel(self)
            val = get(get(self.managedHandle,'ylabel'),'string');
        end
        
        function set.zlabel(self,str)
            zlabel(self.managedHandle,str)
        end
        function val = get.zlabel(self)
            val = get(get(self.managedHandle,'zlabel'),'string');
        end
        
        function set.title(self,str)
            title(self.managedHandle,str)
        end
        function val = get.title(self)
            val = get(get(self.managedHandle,'title'),'string');
        end
        
        function val = get.fontSize(self)
            val = get(self.managedHandle,'fontSize');
        end
        function set.fontSize(self,val)
            set(self.managedHandle, 'fontsize', val);
        end
        function val = get.titleFontSize(self)
            val = get(get(self.managedHandle,'title'), 'fontsize');
        end
        function set.titleFontSize(self, val)
            set(get(self.managedHandle,'title'), 'fontsize', val);
        end
        
        function val = get.hold(self)
            nextPlotVal = get(self.managedHandle,'nextplot');
            
            switch lower(nextPlotVal)
                case 'add'
                    val = 'on';
                case 'replace'
                    val = 'off';
                otherwise
                    val = '?';
            end
        end
        function set.hold(self, val)
            assert(ischar(val),'prt:prtUiManagerAxes:badHold','bad hold value. hold must be a string that is either ''off'' or ''on''');
            
            if strcmpi(val,'off')
                nextPlotVal = 'replace';
            elseif strcmpi(val,'on')
                nextPlotVal = 'add';
            else
                error('prt:prtUiManagerAxes:badHold','bad hold value. hold must be a string that is either ''off'' or ''on''');
            end
            set(self.managedHandle,'NextPlot',nextPlotVal);
        end
        
        
        
        function varargout = xlim(self,varargin)
            if nargin == 1
                varargout = {xlim(self.managedHandle)};
            elseif nargin == 2
                xlim(self.managedHandle, varargin{:});
                varargout = {};
            else
                error('prt:prtGuiManagerAxes:xlim','Invalid number of input arguments.');
            end
        end
        function varargout = ylim(self,varargin)
            if nargin == 1
                varargout = {ylim(self.managedHandle)};
            elseif nargin == 2
                ylim(self.managedHandle, varargin{:});
                varargout = {};
            else
                error('prt:prtGuiManagerAxes:ylim','Invalid number of input arguments.');
            end
        end
        function varargout = zlim(self,varargin)
            if nargin == 1
                varargout = {zlim(self.managedHandle)};
            elseif nargin == 2
                zlim(self.managedHandle, varargin{:});
                varargout = {};
            else
                error('prt:prtGuiManagerAxes:zlim','Invalid number of input arguments.');
            end
        end

        function cla(self)
            cla(self.managedHandle);
        end
        
        function set.fixedXLims(self,val)
            
            if ischar(val)
                switch lower(val)
                    case 'off'
                        self.fixedLims(1:2) = nan(1,2);
                    otherwise
                        error('prt:prtGuiManagerAxes:badLimits','input must be "off" or an 1x2 numeric vector');
                end
            end
            assert(isnumeric(val) && length(val) == 2, 'prt:prtGuiManagerAxes:badLimits','input must be "off" or an 1x2 numeric vector');
            
            self.fixedLims(1:2) = sort(val,'ascend');
            setAxesConstraints(self);
        end
        function val = get.fixedXLims(self)
            val = self.fixedLims(1:2);
        end
        
        function set.fixedYLims(self,val)
            
            if ischar(val)
                switch lower(val)
                    case 'off'
                        self.fixedLims(3:4) = nan(1,2);
                    otherwise
                        error('prt:prtGuiManagerAxes:badLimits','input must be "off" or an 1x2 numeric vector');
                end
            end
            assert(isnumeric(val) && length(val) == 2, 'prt:prtGuiManagerAxes:badLimits','input must be "off" or an 1x2 numeric vector');
            
            self.fixedLims(3:4) = sort(val,'ascend');
            setAxesConstraints(self);
        end
        function val = get.fixedYLims(self)
            val = self.fixedLims(3:4);
        end
        
        function set.fixedZLims(self,val)
            if ischar(val)
                switch lower(val)
                    case 'off'
                        self.fixedLims(5:6) = nan(1,2);
                    otherwise
                        error('prt:prtGuiManagerAxes:badLimits','input must be "off" or an 1x2 numeric vector');
                end
            end
            assert(isnumeric(val) && length(val) == 2, 'prt:prtGuiManagerAxes:badLimits','input must be "off" or an 1x2 numeric vector');
            
            self.fixedLims(5:6) = sort(val,'ascend');
            setAxesConstraints(self);
        end
        function val = get.fixedZLims(self)
            val = self.fixedLims(5:6);
        end
        
        function setAxesConstraints(self)
            
            % Set Fixed Axis Limits
            placesToKeep = isnan(self.fixedLims);
            cAxis = axis;
            if any(~placesToKeep(1:2)) % Some X Lims set.
                cXAxis = cAxis(1:2);
                cFixedLims = self.fixedLims(1:2);
                cXAxis(~placesToKeep(1:2)) = cFixedLims(~placesToKeep(1:2));
                
                xlim(self.managedHandle, cXAxis);
            end
            if any(~placesToKeep(3:4)) % Some Y Lims set.
                cYAxis = cAxis(3:4);
                cFixedLims = self.fixedLims(3:4);
                cYAxis(~placesToKeep(3:4)) = cFixedLims(~placesToKeep(3:4));
                
                ylim(self.managedHandle, cYAxis);
            end
            if any(~placesToKeep(5:6)) % Some Z Lims set.
                cZAxis = cAxis(5:6);
                cFixedLims = self.fixedLims(5:6);
                cZAxis(~placesToKeep(5:6)) = cFixedLims(~placesToKeep(5:6));
                
                zlim(self.managedHandle, cZAxis);
            end
        end
        
        function create(self)
            self.managedHandle = gca;
        end
    end
end
