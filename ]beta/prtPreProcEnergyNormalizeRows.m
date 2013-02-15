classdef prtPreProcEnergyNormalizeRows < prtPreProc
    % prtPreProcEnergyNormalizeRows Normalize the rows of the data to have unit
    % energy
    %
    
    properties (SetAccess=private)
        
        name = 'Energy Normalize Rows'  %  MinMax Rows
        nameAbbreviation = 'ENR'  % MMR
    end
    
    properties
        %no properties
        energyOffset = 0;
    end
    
    methods
        
        function self = prtPreProcEnergyNormalizeRows(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function self = trainAction(self,DataSet) %#ok<INUSD>
            %do nothing
        end
        
        function DataSet = runAction(self,DataSet) %#ok<MANU>
            
            theData = DataSet.getObservations;
            theData = bsxfun(@rdivide,theData,self.energyOffset + sqrt(sum(theData.^2,2)));
            DataSet = DataSet.setObservations(theData);
        end
        
    end
    
end