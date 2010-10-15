classdef prtPreProcZeroMeanRows < prtPreProc
    % xxx Need Help xxx
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Zero-Mean Rows'
        nameAbbreviation = 'ZMR'
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
        function Obj = prtPreProcZeroMeanRows(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            %do nothing
        end
        
        function DataSet = runAction(Obj,DataSet)
            DataSet = DataSet.setObservations(bsxfun(@minus,DataSet.getObservations,mean(DataSet.getObservations,2)));
        end
        
    end
    
end