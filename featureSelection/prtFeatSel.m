classdef prtFeatSel < prtAction 
    % prtFeatSel 
    
    methods (Hidden = true)
        function featureNames = updateFeatureNames(obj,featureNames)
            %Do nothing; this is handled by each feature selector because
            %they use retainFeatures (or they should)
        end
    end
end
