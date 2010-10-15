classdef prtPreProcMinMaxRows < prtPreProc
    % xxx Need Help xxx
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'MinMax Rows'
        nameAbbreviation = 'MMR'
        isSupervised = false;
    end
    
    properties
        %no properties
    end
    properties (SetAccess=private)
        % General Classifier Properties
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
            theData = DataSet.getObservations;
            minVals = min(theData,[],2);
            maxVals = max(theData,[],2);
            theData = bsxfun(@rdivide,bsxfun(@minus,theData,minVals),(maxVals-minVals));
            DataSet = DataSet.setObservations(theData);
        end
        
    end
    
end