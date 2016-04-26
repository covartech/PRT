classdef prtPreProcAbsSumNormalizeRows < prtPreProc
    % prtPreProcAbsSumNormalizeRows Normalize the rows to have
    % sum(abs(x))==1
    %







    properties (SetAccess=private)
        
        name = 'Abs Sum Normalize Rows'  %  MinMax Rows
        nameAbbreviation = 'ASNR'  % MMR
    end
    
    properties
        %no properties
    end
    
    methods
        
        function Obj = prtPreProcAbsSumNormalizeRows(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet) %#ok<INUSD>
            %do nothing
        end
        
        function DataSet = runAction(Obj,DataSet) %#ok<MANU>
            
            theData = DataSet.getObservations;
            theData = abs(bsxfun(@rdivide,theData,sum(abs(theData),2)));
            DataSet = DataSet.setObservations(theData);
        end
        
    end
    
end
