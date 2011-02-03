classdef prtPreProc < prtAction
    % prtPreProc  Base class for prt pre processing objects
    %
    % PreProcessors are currently have no additional properties or methods
    %
    % This is an abstract class and cannot be instantiated.
    % 
    % A prtPreProc object inherits all methods and properties from the
    % prtAction class
    %
    %   See Also: prtPreProc,
    %   prtOutlierRemoval,prtPreProcNstdOutlierRemove,
    %   prtOutlierRemovalMissingData,
    %   prtPreProcNstdOutlierRemoveTrainingOnly, prtOutlierRemovalNStd,
    %   prtPreProcPca, prtPreProcPls, prtPreProcHistEq,
    %   prtPreProcZeroMeanColumns, prtPreProcLda, prtPreProcZeroMeanRows,
    %   prtPreProcLogDisc, prtPreProcZmuv, prtPreProcMinMaxRows                    

    properties (SetAccess = protected)
        isSupervised = false;
    end
    
    methods
        function obj = prtPreProc()
            % As an action subclass we must set the properties to reflect
            % our dataset requirements
            obj.classInput = 'prtDataSetStandard';
            obj.classOutput = 'prtDataSetStandard';
            obj.classInputOutputRetained = true;
        end
    end
    methods (Hidden = true)
        function featureNames = updateFeatureNames(obj,featureNames)
            for i = 1:length(featureNames)
                featureNames{i} = sprintf('%s_{%s}',featureNames{i},obj.nameAbbreviation);
            end
        end
    end
end
