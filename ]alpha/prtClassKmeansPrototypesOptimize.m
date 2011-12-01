classdef prtClassKmeansPrototypesOptimize < prtClassKmeansPrototypesDistance
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