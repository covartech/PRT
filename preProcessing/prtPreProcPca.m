classdef prtPreProcPca < prtPreProc
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Principal Component Analysis'
        nameAbbreviation = 'PCA'
        isSupervised = true;
    end
    
    properties (SetAccess=private)
        % General Classifier Properties
        means = []; 
        principalComponents = [];
    end
    properties
        nComponents = 3;
    end
    
    methods
       
        function Obj = prtPreProcPca(varargin)
            % Allow for string, value pairs
            % There are no user settable options though.
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.means = nanmean(DataSet.getObservations(),1);
            [~,~,v] = svd(bsxfun(@minus,DataSet.getObservations,Obj.means),'econ');
            Obj.principalComponents = v(:,1:Obj.nComponents);
        end
        
        function DataSet = runAction(Obj,DataSet)
            DataSet = DataSet.setObservations(bsxfun(@minus,DataSet.getObservations,Obj.means)*Obj.principalComponents);
        end
    end
    
end