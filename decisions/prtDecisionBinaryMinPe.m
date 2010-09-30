classdef prtDecisionBinaryMinPe < prtDecisionBinary
    properties (SetAccess = private)
        name = 'MinPe'
        nameAbbreviation = 'MINPE';
        isSupervised = true;
    end
    properties (Hidden = true)
        threshold
        uniqueClasses
    end
    methods (Access = protected)
        function Obj = trainAction(Obj,dataSet)
            [pf,pd,auc,thresh] = prtScoreRoc(dataSet.getObservations,dataSet.getTargets);
            pe = prtUtilPfPd2Pe(pf,pd);
            keyboard
            [v,minPeIndex] = min(pe);
            Obj.threshold = thresh(minPeIndex);
            Obj.uniqueClasses = dataSet.uniqueClasses;
        end
    end
    methods
        function threshold = getThreshold(Obj)
            threshold = Obj.threshold;
        end
        function uniqueClasses = getUniqueClasses(Obj)
            uniqueClasses = Obj.uniqueClasses;
        end
    end
end