classdef prtPreProcZeroMeanColumns < prtPreProc
    
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Zero-Mean Columns'
        nameAbbreviation = 'ZMC'
        isSupervised = false;
    end
    
    properties
        %no properties
    end
    properties (SetAccess=private)
        % General Classifier Properties
        meanVector = [];           % A vector of the means
    end
    
    methods
        
          % Allow for string, value pairs
        function Obj = prtPreProcZeroMeanColumns(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.meanVector = nanmean(DataSet.getObservations(),1);
        end
        
        function DataSet = runAction(Obj,DataSet)
            DataSet = DataSet.setObservations(bsxfun(@minus,DataSet.getObservations,Obj.meanVector));
        end
        
    end
    
end