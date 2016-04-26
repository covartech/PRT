classdef prtUiRocSelector < prtUiManagerPanel





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
