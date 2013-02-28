classdef prtPreProcClass < prtPreProc
    % prtPreProcClass
    %
    % prtPreProcClass is an abstract class and cannot be instantiated.
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
