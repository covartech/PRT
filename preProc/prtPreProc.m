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
    %   See Also: prtPreProc, prtPreProcPca, prtPreProcPls,
    %   prtPreProcHistEq, prtPreProcZeroMeanColumns, prtPreProcLda,
    %   prtPreProcZeroMeanRows, prtPreProcLogDisc, prtPreProcZmuv,
    %   prtPreProcMinMaxRows







    properties (SetAccess = protected)
        isSupervised = false;  % False
        isCrossValidateValid = true; % True
    end
    
    methods
        function obj = prtPreProc()
            % As an action subclass we must set the properties to reflect
            % our dataset requirements
            obj.classTrain = 'prtDataSetStandard';
            obj.classRun = 'prtDataSetStandard';
            obj.classRunRetained = true;
        end
	end
	methods (Hidden = true)
        function featureNameModificationFunction = getFeatureNameModificationFunction(obj)
			featureNameModificationFunction = prtUtilFeatureNameModificationFunctionHandleCreator('#strIn#_{%s}', obj.nameAbbreviation);
        end
    end    
end
