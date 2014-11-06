classdef prtClassKmeansPrototypesOptimize < prtClassKmeansPrototypesDistance

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
    properties

        possibleKValues = 2:10;
        evalMetric = @(classifier, dataSet)prtEvalPercentCorrect(classifier, dataSet, 2);
        evaluations = [];
    end
    
    methods 
        function Obj = prtClassKmeansPrototypesOptimize(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            Obj.verboseStorage = true;
        end
    end
    methods (Access=protected, Hidden = true)
        function Obj = trainAction(Obj,DataSet)
            
            nKs = length(Obj.possibleKValues);
            evals = zeros(nKs,1);
            for iK = 1:nKs
                cKMP = prtClassKmeansPrototypes('nClustersPerHypothesis',Obj.possibleKValues(iK));
                
                evals(iK) = Obj.evalMetric(cKMP, DataSet);
            end

            [maxEval, maxInd] = max(evals);
            Obj.nClustersPerHypothesis = Obj.possibleKValues(maxInd);
            Obj.evaluations = evals;
            
            Obj = trainAction@prtClassKmeansPrototypes(Obj,DataSet);
        end
    end
end
