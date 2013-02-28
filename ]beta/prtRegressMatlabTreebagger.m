classdef prtRegressMatlabTreebagger < prtRegress
    %prtRegressMatlabTreebagger Insert description of class here
    %

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
