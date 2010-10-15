classdef prtDecisionBinary < prtDecision
    % xxx NEED HELP xxx
    %
    % Sub-class of prtDecision intended to make binary decision functions
    % easier to write.  These decision objects should only work on binary
    % classification algorithms where the classifier output is
    % nObservations x 1.  For Mary classification decisions, see
    % prtDecisionMap for example.
    %
    % subclasses must implement getThreshold
    
    methods (Abstract)
        threshold = getThreshold(Obj)
    end
    methods (Access = protected)
        function DS = runAction(Obj,DS)
            %theClasses = Obj.getUniqueClasses;
            theClasses = Obj.classList;
            DS = DS.setObservations(theClasses((DS.getObservations >= Obj.getThreshold) + 1));
        end
    end
end