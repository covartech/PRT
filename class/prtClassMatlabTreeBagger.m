classdef prtClassMatlabTreeBagger < prtClass
    % prtClassMatlabTreeBagger  TreeBagger classifier using the MATLAB function "treeBagger.m" (requires statistics toolbox)
    %
    %  CLASSIFIER = prtClassMatlabTreeBagger returns a tree-bagger
    %  classifier build using the MATLAB Statistics toolbox (additonal 
    %  product, not included).  As an alternative, consider using
    %  prtClassTreeBaggingCap, which also implements a random forest
    %  classification scheme.
    %
    %  A prtClassMatlabTreeBagger object inherits all properties from the
    %  abstract class prtClass. In addition is has the following
    %  properties:
    % 
    %   nTrees - The number of trees to use in the MATLAB TreeBagger
    %
    %   treeBaggerParamValuePairs - A cell array of parameter value pairs
    %   to be passed to the MATLAB function "treeBagger". A complete list
    %   of the valid parameters and their allowed values can be found in
    %   the help entru for "treeBagger.m"
    %
    %  % Example usage:
    %
    %   TestDataSet = prtDataGenBimodal;       % Create some test and
    %   TrainingDataSet = prtDataGenBimodal;   % training data
    %   classifier = prtClassMatlabTreeBagger;           % Create a classifier
    %   classifier = classifier.train(TrainingDataSet);    % Train
    %   classified = run(classifier, TestDataSet);         % Test
    %   subplot(2,1,1);
    %   classifier.plot;
    %   subplot(2,1,2);
    %   [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %   h = plot(pf,pd,'linewidth',3);
    %   title('ROC'); xlabel('Pf'); ylabel('Pd');
    %
    % % Example usage setting the treeBaggerParamValuePairs cell array:
    %   TestDataSet = prtDataGenBimodal;       % Create some test and
    %   TrainingDataSet = prtDataGenBimodal;   % training data
    %   classifier = prtClassMatlabTreeBagger('treeBaggerParamValuePairs',{'nVarToSample','all'});
    %   classifier = classifier.train(TrainingDataSet);    % Train
    %   classified = run(classifier, TestDataSet);         % Test
    %   subplot(2,1,1);
    %   classifier.plot;
    %   subplot(2,1,2);
    %   [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %   h = plot(pf,pd,'linewidth',3);
    %   title('ROC'); xlabel('Pf'); ylabel('Pd');
    %
    %







    properties (SetAccess=private)
        name = 'MATLAB Tree Bagger';  % MATLAB Tree Bagger
        nameAbbreviation = 'MLTB'; % MLTB
        isNativeMary = true; % False
    end
    
    properties 
        
        nTrees = 100;  % The number of trees
        treeBaggerParamValuePairs = {};
    end
    
    properties (SetAccess = protected)
        forest
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
            [dontNeed, x] = predict(Obj.forest,DataSet.getObservations); %#ok<ASGLU>
            DataSet = DataSet.setObservations(x);
        end
        
    end
end
