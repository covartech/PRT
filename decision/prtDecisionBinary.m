classdef prtDecisionBinary < prtDecision
    % prtDecisionBinary Base class for all prtDecisionBinary objects
    %
    % A prtDecisionBinary object is an abstract class and cannot be
    % instantiated.    
    %
    % prtBinaryDecsion objects find a threshold value that is used to make
    % decisions based on certain criteria.
    %
    % prtDecisionBinary objects all have the following function:
    %
    % getThreshold - return the prtDecisionBinary objects decision
    %                threshold
    %
    % See also: prtDecisionBinaryMinPe, prtDecisionBinarySpecifiedPd,
    % ptDecisionBinarySpecifiedPf, prtDecisionMap
    
    methods (Abstract)
        threshold = getThreshold(Obj) 
        % THRESH = getThreshold returns the objects threshold
    end
    methods (Access=protected,Hidden=true)
        function obj = prtDecisionBinary()
            obj.classInput = 'prtDataSetClass';
            obj.classOutput = 'prtDataSetClass';
        end
        
        function DS = runAction(Obj,DS)
            theClasses = Obj.classList;
            DS = DS.setObservations(theClasses((DS.getObservations >= Obj.getThreshold) + 1));
        end
    end
end