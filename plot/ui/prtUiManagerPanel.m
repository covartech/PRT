classdef prtUiManagerPanel < prtUiManager





    properties (Dependent)
        title
        fontSize
    end
    
    methods
        function self = prtUiManagerPanel(varargin)
           self = self@prtUiManager(varargin{:});
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
