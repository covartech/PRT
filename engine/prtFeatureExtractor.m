classdef prtFeatureExtractor < prtAction
    % xxx NEED HELP xxx
    methods (Hidden = true)
        function featureNames = updateFeatureNames(obj,featureNames)
            for i = 1:length(featureNames)
                featureNames{i} = sprintf('%s_{%d}',obj.nameAbbreviation);
            end
        end
    end    
end