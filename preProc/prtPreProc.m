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

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
