classdef prtUiRocExplorer < prtUiManagerPanel





    properties

        prtDs
       
        rocUiObj = [];
        selectorUiObj = [];
        handleStruct
    end
    
    methods
        function self = prtUiRocExplorer(varargin)
            if nargin == 1
                self.prtDs = varargin{1};
            else
                self = prtUtilAssignStringValuePairs(self,varargin{:});
            end
            
            if nargin~=0 && ~self.hgIsValid
               self.create();
            end
            
            init(self);
        end
        
        function init(self)
            self.handleStruct.topPanel = uipanel('units','normalized','BackgroundColor','white','Position',[0 0.5 1 0.5]);
            self.handleStruct.bottomPanel = uipanel('units','normalized','BackgroundColor','white','Position',[0 0 1 0.5]);
            
            self.rocUiObj = prtUiRocSelector('managedHandle', self.handleStruct.bottomPanel, 'prtDs', self.prtDs);
            self.selectorUiObj = prtUiDataSetStandardObservationInfoSelect('managedHandle', self.handleStruct.topPanel, ...
                'prtDs',self.prtDs, 'retainedObsUpdateCallback',@(x)updateRetainObs(self.rocUiObj, x));
        end
    end
end
