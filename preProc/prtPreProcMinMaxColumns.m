classdef prtPreProcMinMaxColumns < prtPreProc







    properties (SetAccess=private)
        
        name = 'MinMax Columns'  %  MinMax Rows
        nameAbbreviation = 'MMC'  % MMR
    end
    
    properties
        %no properties
        minVals = [];
        maxVals = [];
    end
    
    methods
        
        function self = prtPreProcMinMaxColumns(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function self = trainAction(self,DataSet) %#ok<INUSD>
            %do nothing
            self.minVals = min(DataSet.getObservations);
            self.maxVals = max(DataSet.getObservations);
            invalidInds = find(self.minVals == self.maxVals);
            %Do nothing for invalid indices
            self.minVals(invalidInds) = 0;
            self.maxVals(invalidInds) = 1;
        end
        
        function DataSet = runAction(self,DataSet)
            
            theData = DataSet.getObservations;
            
            theData = bsxfun(@minus,theData,self.minVals);
            theData = bsxfun(@rdivide,theData,self.maxVals - self.minVals);
            
            %what should we do about outliers?  they will not be zero or
            %one...
            DataSet = DataSet.setObservations(theData);
        end
        
    end
    
end
