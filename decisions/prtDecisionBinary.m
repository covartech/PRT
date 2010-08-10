classdef prtDecisionBinary < prtDecision
    methods (Abstract)
        threshold = getThreshold(Obj)
    end
    methods (Access = protected)
        function DS = runAction(Obj,DS)
            DS = DS.setObservations((DS.getObservations < Obj.getThreshold) + 1);
        end
    end
end