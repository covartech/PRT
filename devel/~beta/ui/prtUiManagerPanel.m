classdef prtUiManagerPanel < prtUiManager
    properties (Dependent)
        title
        fontSize
    end
    
    methods
        function self = prtUiManagerPanel(varargin)
            if nargin
                self = prtUtilAssignStringValuePairs(self, varargin{:});
            end
            
           if ~self.hgIsValid
               self.create()
           end
        end
        function create(self)
            self.managedHandle = uipanel;
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