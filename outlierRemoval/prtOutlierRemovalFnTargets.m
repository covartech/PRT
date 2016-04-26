classdef prtOutlierRemovalFnTargets < prtOutlierRemoval
    % prtOutlierRemovalBooleanObservations  Removes a range of classes from
    %   a prtDataSet
    %







    properties (SetAccess=private)
        % Required by prtAction
        name = 'Boolean Observation-wise Outlier Removal';  % NonFinite Data Outlier Removal
        nameAbbreviation = 'RangeLabelRemove'   % NonFiniteDataRemove
    end
    
    properties
        removeFn = @(y) y < 1; 
    end
    
    methods
        
        % Allow for string, value pairs
        function Obj = prtOutlierRemovalFnTargets(varargin)
            
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
            outlierVec = self.removeFn(DataSet.targets);
            outlierIndices = repmat(outlierVec,1,DataSet.nFeatures);
        end
        
    end
    
end
