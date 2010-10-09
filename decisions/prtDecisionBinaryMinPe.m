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
            
            if dataSet.nObservations > 1
                error('prt:prtDecisionBinaryMinPe','prtDecisionBinaryMinPe can not be used on algorithms that output multi-column results; consider using prtDecisionMap instead');
            end
            [pf,pd,auc,thresh] = prtScoreRoc(dataSet.getObservations,dataSet.getTargets);
            pe = prtUtilPfPd2Pe(pf,pd);
            [v,minPeIndex] = min(pe);
            Obj.threshold = thresh(minPeIndex);
            Obj.classList = dataSet.uniqueClasses;
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