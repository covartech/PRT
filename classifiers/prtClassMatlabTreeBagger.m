classdef prtClassMatlabTreeBagger < prtClass
    % xxx NEED HELP xxx
    %
    %DS = prtDataGenBimodal;
    %Nn = prtClassMatlabTreeBagger; 
    % %Or:
    %Nn = prtClassMatlabTreeBagger('treeBaggerParamValuePairs',{'nVarToSample','all'});
    % %or
    %Nn = prtClassMatlabTreeBagger('treeBaggerParamValuePairs',{'nVarToSample',2});
    %Nn = Nn.train(DS);
    %Nn.plot; 
    %yOut = Nn.run(prtDataGenBimodal);
    
    properties (SetAccess=private)
        
        name = 'MATLAB Tree Bagger';
        nameAbbreviation = 'MLTB';
        isNativeMary = true;  % False
    end
    
    properties 
        % forest
        nTrees = 100;
        forest
        treeBaggerParamValuePairs = {};
    end

    methods 
               % Allow for string, value pairs
        function Obj = prtClassMatlabTreeBagger(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.nTrees(Obj,val)
            assert(isscalar(val) && isnumeric(val) && all(val == round(val)) && all(val > 0),'prt:prtClassMatlabTreeBagger:nTrees','nTrees must be a numeric scalar int-valued double greater than 0, but value provided was %s',mat2str(val));
            Obj.nTrees = val;
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.forest = TreeBagger(Obj.nTrees,DataSet.getObservations,DataSet.getTargets,Obj.treeBaggerParamValuePairs{:});
        end
        
        function DataSet = runAction(Obj,DataSet)
            [~,scores] = predict(Obj.forest,DataSet.getObservations);
            DataSet = DataSet.setObservations(scores);
        end
        
    end
end