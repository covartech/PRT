classdef prtOutlierRemovalFn < prtOutlierRemoval
    % prtOutlierRemovalBooleanObservations  Removesa range of data values from a prtDataSet
    %







    properties (SetAccess=private)
        % Required by prtAction
        name = 'Boolean Observation-wise Outlier Removal';  % NonFinite Data Outlier Removal
        nameAbbreviation = 'RangeDataRemove'   % NonFiniteDataRemove
    end
    
    properties
        removeFn = @(x) min(x,[],2) > -.4 & max(x,[],2) < .4; 
    end
    
    methods
        
        % Allow for string, value pairs
        function Obj = prtOutlierRemovalBooleanObservations(varargin)
            
            %Need to check this with the string - setting the string in
            %prtOutlierRemoval should change this value...
            Obj.isCrossValidateValid = true;
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,~)
            %Nothing to do
        end
        
        function outlierIndices = calculateOutlierIndices(self,DataSet) %#ok<MANU> This is OK - don't make it static.
            outlierVec = self.observationRangeFn(DataSet.getX);
            outlierIndices = repmat(outlierVec,1,DataSet.nFeatures);
        end
        
    end
    
end
