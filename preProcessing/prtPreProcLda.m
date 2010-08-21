classdef prtPreProcLda < prtPreProc
    % prtPreProcPca   Linear discriminant analysis
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Linear discriminant analysis'
        nameAbbreviation = 'LDA'
        isSupervised = true;
    end
    
    properties
        nComponents = 2;   % The number of LDA components
    end
    properties (SetAccess=private)
        % General Classifier Properties
        projectionMatrix = [];
        globalMean = [];
    end
    
    methods
        
          % Allow for string, value pairs
        function Obj = prtPreProcLda(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods
        function Obj = set.nComponents(Obj,nComp)
            if ~isnumeric(nComp) || ~isscalar(nComp) || nComp < 1 || round(nComp) ~= nComp
                error('prt:prtPreProcPca','nComponents (%s) must be a positive scalar integer',mat2str(nComp));
            end
            Obj.nComponents = nComp;
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            if Obj.nComponents > DataSet.nClasses
                error('prt:prtPreProcLda','Attempt to train LDA pre-processor with more components (%d) than unique classes in data set (%d)',Obj.nComponents,DataSet.nClasses);
            end
            [Obj.projectionMatrix,Obj.globalMean] = prtUtilLinearDiscriminantAnalysis(DataSet,Obj.nComponents);
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            X = DataSet.getObservations;
            X = bsxfun(@minus,X,Obj.globalMean);
            DataSet = DataSet.setObservations(X*Obj.projectionMatrix);
        end
        
    end
    
end