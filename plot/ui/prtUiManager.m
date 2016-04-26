classdef prtUiManager < hgsetget





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
        function self = prtUiManager(varargin)
            self = prtUtilAssignStringValuePairs(self, varargin{:});
            
            if nargin == 0 && ~strcmpi(class(self),'prtUiManager')
                return
            end
            if ~self.hgIsValid
                self.create();
            end
        end
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
