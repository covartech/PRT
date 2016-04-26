classdef prtUiManagerMultiAxes < prtUiManagerPanel





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
