classdef prtFeatSel < prtAction 
    % prtFeatSel
    properties (SetAccess = protected)
        isSupervised = true;
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
    
    methods (Hidden = true)
        function featureNames = updateFeatureNames(obj,featureNames) %#ok<MANU>
            %Do nothing; this is handled by each feature selector because
            %they use retainFeatures (or they should)
        end
    end
end
