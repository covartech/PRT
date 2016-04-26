classdef prtFeatSel < prtAction 
    % prtFeatSel





    properties (SetAccess = protected)

        isSupervised = true   %True
        isCrossValidateValid = true; % False
    end
    
    methods
        function obj = prtFeatSel()
            % As an action subclass we must set the properties to reflect
            % our dataset requirements
            obj.classTrain = 'prtDataSetClass';
            obj.classRun = 'prtDataSetStandard';
            obj.classRunRetained = true;
        end
    end
end
