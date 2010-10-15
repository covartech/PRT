classdef prtPreProc < prtAction
    % xxx Need Help xxx
    %
    % PreProcessors are currently have no additional properties or methods
    % This is a placeholder for consistency with other action types
    methods (Hidden = true)
        function featureNames = updateFeatureNames(obj,featureNames)
            for i = 1:length(featureNames)
                featureNames{i} = sprintf('%s_{%s}',featureNames{i},obj.nameAbbreviation);
            end
        end
    end
end
