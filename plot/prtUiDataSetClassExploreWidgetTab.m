classdef prtUiDataSetClassExploreWidgetTab < prtUiManagerPanel
    properties
        widget
    end
    methods
        function self = prtUiDataSetClassExploreWidgetTab(varargin)
            if nargin
                self = prtUtilAssignStringValuePairs(self, varargin{:});
            end
            
            if ~self.hgIsValid
               self.create()
            end
        end
    end
end