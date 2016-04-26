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
    % prtDecisionBinarySpecifiedPf, prtDecisionMap







    methods (Abstract)
        threshold = getThreshold(Obj) 
        % THRESH = getThreshold returns the objects threshold
    end
    methods
        function obj = prtDecisionBinary()
            obj.classTrain = 'prtDataSetClass';
            obj.classRun = 'prtDataSetStandard';
            obj.classRunRetained = true;
            
            obj.isSupervised = true;
        end
    end
    
    methods (Access=protected,Hidden=true)
        function DS = runAction(Obj,DS)
            theClasses = Obj.classList;
            DS = DS.setObservations(theClasses((DS.getObservations >= Obj.getThreshold) + 1));
        end
         function xOut = runActionFast(Obj,xIn,ds) %#ok<INUSD>
            theClasses = Obj.classList;
            xOut = theClasses((xIn >= Obj.getThreshold) + 1);
        end
    end
    
    methods (Access = protected, Hidden = true)
        function ClassObj = preTrainProcessing(ClassObj, DataSet)
            % Overload preTrainProcessing() so that we can determine mary
            % output status
            assert(DataSet.isLabeled & DataSet.nClasses > 1,'The prtDataSetClass input to the train() method of a prtDecisionBinary must have non-empty targets and have more than one class.');
            
            ClassObj = preTrainProcessing@prtAction(ClassObj,DataSet);
        end
    end
    
    
    methods (Hidden)
        function str = exportSimpleText(self) %#ok<MANU>
            titleText = sprintf('%% prtDecisionBinaryMinPe\n');
            decisionThresholdText = prtUtilMatrixToText(self.threshold,'varName','minPeDecisionThreshold');
            str = sprintf('%s%s%s',titleText,decisionThresholdText);
        end
    end
end
