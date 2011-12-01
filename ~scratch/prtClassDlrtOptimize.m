classdef prtClassDlrtOptimize < prtClassDlrt
    properties
        possibleKValues = 2:10;
        evalMetric = @(classifier, dataSet)prtEvalPercentCorrect(classifier, dataSet, 2);
        evaluations = [];
    end
    
    methods 
        function Obj = prtClassDlrtOptimize(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            Obj.verboseStorage = true;
        end
    end
    methods (Access=protected, Hidden = true)
        function Obj = trainAction(Obj,DataSet)
            
            nKs = length(Obj.possibleKValues);
            evals = zeros(nKs,1);
            for iK = 1:nKs
                cDlrt = prtClassDlrt('k',Obj.possibleKValues(iK));
                
                evals(iK) = Obj.evalMetric(cDlrt, DataSet);
            end

            [maxEval, maxInd] = max(evals);
            Obj.k = Obj.possibleKValues(maxInd);
            Obj.evaluations = evals;
            
        end
    end
end