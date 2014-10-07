classdef prtUiRocSelector < prtUiManagerPanel

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

        prtDs
        
        pf = [];
        pd = [];
        thresholds = [];
        selectedIndex = [];
        
        handleStruct
    end
    
    properties (Hidden, SetAccess='protected', GetAccess='protected')
        retainObsUpdateCallbackDepHelper = [];
        retainObsDepHelper = [];
    end
    properties (Dependent)
        retainObs
        retainObsUpdateCallback
    end
    
    methods 
        function self = prtUiRocSelector(varargin)
            if nargin == 1
                self.prtDs = varargin{1};
            else
                self = prtUtilAssignStringValuePairs(self,varargin{:});
            end
            
            if nargin~=0 && ~self.hgIsValid
               self.create()
            end
            
            init(self);
        end
        
        function init(self)
            self.handleStruct.axes = axes('parent',self.managedHandle,'units','normalized','position',[0.1 0.1 0.85 0.8]);
            hold on
            grid on
            self.handleStruct.rocLine = plot(self.handleStruct.axes,nan,nan,'k');
            self.handleStruct.selectX = plot(self.handleStruct.axes,nan,nan,'kx','MarkerSize',12,'HitTest','off');
            hold off
            self.handleStruct.title = title(self.handleStruct.axes,'');
            set(self.handleStruct.rocLine,'HitTest','on','ButtonDownFcn',@(h,e)self.infoUpdate());
            
            self.updateRoc();
        end
        function updateRoc(self)
            
            self.selectedIndex = [];
            set(self.handleStruct.selectX,'XData',nan','YData',nan);
            set(self.handleStruct.title,'String','')
            
            if isempty(self.prtDs)
                set(self.handleStruct.rocLine,'XData',nan','YData',nan);
                self.selectedIndex = [];
                return
            end
            
            try
                if ~isempty(self.retainObs)
                    [self.pf ,self.pd, self.thresholds] = prtScoreRoc(self.prtDs.retainObservations(self.retainObs));
                else
                    [self.pf ,self.pd, self.thresholds] = prtScoreRoc(self.prtDs);
                end
            catch ME
                msgbox(ME.message,ME.identifier,'Error','Modal')
                set(self.handleStruct.rocLine,'XData',nan','YData',nan);
                return
            end
            set(self.handleStruct.rocLine,'XData',self.pf,'YData',self.pd);
            axis(self.handleStruct.axes,[0 1 0 1]);
        end
        function infoUpdate(self)
            cp = get(self.handleStruct.axes,'CurrentPoint');
            self.selectedIndex = mean(find(cp(1,1) > self.pf,1,'last'),find(cp(1,2) < self.pd,1,'first'));
            
            set(self.handleStruct.selectX,'XData',self.pf(self.selectedIndex),'YData',self.pd(self.selectedIndex));
            set(self.handleStruct.title,'String',sprintf('Pd = %0.3f, Pf = %0.3f, Theshold = %g',self.pd(self.selectedIndex), self.pf(self.selectedIndex),self.thresholds(self.selectedIndex)));
            
        end
        
        function val = get.retainObsUpdateCallback(self)
            val = self.retainObsUpdateCallbackDepHelper;
        end
        function set.retainObsUpdateCallback(self,val)
            assert(isempty(val) || (isa(val, 'function_handle') && nargin(val)==1),'retainObsUpdateCallback must be a function handle that accepts one input')
            
            self.retainObsUpdateCallbackDepHelper = val;
        end
        function val = get.retainObs(self)
            val = self.retainObsDepHelper;
        end
        function set.retainObs(self, val)
            if ~isempty(self.retainObsUpdateCallback)
                self.retainObsUpdateCallback(val)
            end
            self.retainObsDepHelper = val;
            self.updateRoc();
        end
        function updateRetainObs(self, val)
            self.retainObs = val;
        end        
        
    end
end
