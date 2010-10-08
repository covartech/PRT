classdef prtDecisionBinary < prtDecision
    methods (Abstract)
        threshold = getThreshold(Obj)
        %uniqueClasses = getUniqueClasses(Obj)
    end
    methods (Access = protected)
        function DS = runAction(Obj,DS)
            %theClasses = Obj.getUniqueClasses;
            theClasses = Obj.classList;
            DS = DS.setObservations(theClasses((DS.getObservations >= Obj.getThreshold) + 1));
        end
    end
end