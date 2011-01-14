classdef prtOutlierRemovalMissingData < prtOutlierRemoval
    % prtPreProcMissingDataOutlierRemove  Removes missing data from a prtDataSet
    %
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Missing Data Outlier Removal';  % Missing Data Outlier Removal
        nameAbbreviation = 'missinDataRemove'   % MissingDataRemove
        isSupervised = false;  % False
    end
    
    methods
        
          % Allow for string, value pairs
        function Obj = prtOutlierRemovalMissingData(varargin)
            
            %Need to check this with the string - setting the string in
            %prtOutlierRemoval should change this value... 
            Obj.isCrossValidateValid = true;  
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            %Nothing to do
        end
        
        function outlierIndices = calculateOutlierIndices(Obj,DataSet)
            outlierIndices = isnan(DataSet.getObservations);
        end
        
    end
    
end