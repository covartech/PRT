classdef prtPreProcZmuv < prtPreProc
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Zero Mean Unit Variance'
        nameAbbreviation = 'ZMUV'
        isSupervised = true;
    end
    
    properties (SetAccess=private)
        % General Classifier Properties
        means = []; 
        stds = []; 
    end
    
    methods
        
        function Obj = prtPreProcZmuv(varargin)
            % Allow for string, value pairs
            % There are no user settable options though.
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.stds = nanstd(DataSet.getObservations(),0,1);
            Obj.means = nanmean(DataSet.getObservations(),1);
        end
        
        function DataSet = runAction(Obj,DataSet)
            DataSet = DataSet.setObservations(bsxfun(@rdivide,bsxfun(@minus,DataSet.getObservations,Obj.means),Obj.stds));
        end
        
    end
    
end