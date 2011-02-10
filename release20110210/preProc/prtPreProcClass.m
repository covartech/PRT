classdef prtPreProcClass < prtPreProc
    
    methods
        function obj = prtPreProcClass()
            obj.classTrain = 'prtDataSetClass';
            
            obj.isSupervised = true; % Overload this here.
        end
    end
    
    methods (Access = protected, Hidden = true)
        function ClassObj = preTrainProcessing(ClassObj, DataSet)
            % Overload preTrainProcessing() so that we can determine mary
            % output status
            assert(DataSet.isLabeled & DataSet.nClasses > 1,'The prtDataSetClass input to the train() method of a prtPreProcClass must have non-empty targets and have more than one class.');
            
            ClassObj = preTrainProcessing@prtAction(ClassObj,DataSet);
        end
    end
end