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
    end
    
    methods
        
        function Obj = prtPreProcEnergyNormalizeRows(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet) %#ok<INUSD>
            %do nothing
        end
        
        function DataSet = runAction(Obj,DataSet) %#ok<MANU>
            
            theData = DataSet.getObservations;
            theData = bsxfun(@rdivide,theData,sqrt(sum(theData.^2,2)));
            DataSet = DataSet.setObservations(theData);
        end
        
    end
    
end