classdef prtClassKnnOptimize < prtClassKnn
    properties
        possibleKValues = 2:10;
        evalMetric = @(classifier, dataSet)prtEvalPercentCorrect(classifier, dataSet, 2);
    end
    
    methods 
        function Obj = prtClassKnnOptimize(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            Obj.verboseStorage = true;
        end
    end
    methods (Access=protected, Hidden = true)
        function Obj = trainAction(Obj,DataSet)
            
            nKs = length(Obj.possibleKValues);
            evals = zeros(nKs,1);
            for iK = 1:nKs
                cKnn = prtClassKnn('k',Obj.possibleKValues(iK));
                
                evals(iK) = Obj.evalMetric(cKnn, DataSet);
            end

            [maxEval, maxInd] = max(evals);
            Obj.k = Obj.possibleKValues(maxInd);
        end
    end
end