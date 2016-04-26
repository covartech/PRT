classdef prtRegressMatlabTreebagger < prtRegress
    %prtRegressMatlabTreebagger Insert description of class here
    %







    properties (SetAccess=private)
        name = 'MatlabTreebagger'                  % Insert the name of the regressor
        nameAbbreviation = 'MatlabTreebagger'      % A short abbreviation of the name
    end
    
    properties
        % forest
        nTrees = 100;
        treeBaggerParamValuePairs = {};
    end
    
    properties (SetAccess = protected)
        forest
    end

    methods
        
        %Define a constructor
        function Obj = prtRegressMatlabTreebagger(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.nTrees(Obj,val)
            assert(isscalar(val) && isnumeric(val) && all(val == round(val)) && all(val > 0),'prt:prtClassMatlabTreeBagger:nTrees','nTrees must be a numeric scalar int-valued double greater than 0, but value provided was %s',mat2str(val));
            Obj.nTrees = val;
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.forest = TreeBagger(Obj.nTrees,DataSet.getObservations,DataSet.getTargets,'method','r',Obj.treeBaggerParamValuePairs{:});
        end
        
        function DataSet = runAction(Obj,DataSet)
            scores = predict(Obj.forest,DataSet.getObservations);
            DataSet = DataSet.setObservations(scores);
        end
        
    end
    
end
