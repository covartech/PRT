classdef prtFeatSelStatic < prtFeatSel %
    % prtFeatSelStatic
    %  Static feature selection object.
    %
    %   % Example usage:
    %   nNoiseFeatures = 10;
    %   DS = prtDataBimodal;
    %   DS = DS.setObservations(cat(2,DS.getObservations,randn(DS.nObservations,nNoiseFeatures)));
    %   
    %   StaticFeatSel = prtFeatSelStatic;
    %   StaticFeatSel.selectedFeatures = [1 2];
    %   StaticFeatSel = StaticFeatSel.train(DS);  %this is pro-forma only; training does nothing
    %   
    %   DataSetDownSelected = StaticFeatSel.run(DS);
    %   explore(DataSetDownSelected);
    
    properties (SetAccess=private) 
        % Required by prtAction
        name = 'Static Feature Selection'
        nameAbbreviation = 'StaticFeatSel'
        isSupervised = false;
    end 
    
    properties 
        % General Classifier Properties
        selectedFeatures = nan;
    end
    
    
    
    methods 
                
        % Constructor %%
        
        function Obj = prtFeatSelStatic(varargin) 
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        
    end
    methods (Access = protected)
        
        % Train %%
        
        function Obj = trainAction(Obj,~)
            if isnan(Obj.selectedFeatures)
                error('Manually set selectedFeatures field of prtFeatSelStatic to succesfully train and run');
            end
        end
        
        % Run %
                
        function DataSet = runAction(Obj,DataSet) %%
            if isnan(Obj.selectedFeatures)
                error('Manually set selectedFeatures field of prtFeatSelStatic to succesfully train and run');
            end
            DataSet = DataSet.retainFeatures(Obj.selectedFeatures);
        end
        
    end
    
    
end
