%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef prtFeatSel < prtAction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Feature Selectors currently have no additional properties or methods
    % This is a placeholder for consistency with other action types
    
    methods (Hidden = true)
        function featureNames = updateFeatureNames(obj,featureNames)
            %Do nothing; this is handled by each feature selector because
            %they use retainFeatures (or they should)
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%