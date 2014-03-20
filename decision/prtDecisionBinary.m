classdef prtDecisionBinary < prtDecision
    % prtDecisionBinary Base class for all prtDecisionBinary objects
    %
    % A prtDecisionBinary object is an abstract class and cannot be
    % instantiated.    
    %
    % prtBinaryDecsion objects find a threshold value that is used to make
    % decisions based on certain criteria.
    %
    % prtDecisionBinary objects all have the following function:
    %
    % getThreshold - return the prtDecisionBinary objects decision
    %                threshold
    %
    % See also: prtDecisionBinaryMinPe, prtDecisionBinarySpecifiedPd,
    % prtDecisionBinarySpecifiedPf, prtDecisionMap

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


    methods (Abstract)
        threshold = getThreshold(Obj) 
        % THRESH = getThreshold returns the objects threshold
    end
    methods
        function obj = prtDecisionBinary()
            obj.classTrain = 'prtDataSetClass';
            obj.classRun = 'prtDataSetStandard';
            obj.classRunRetained = true;
            
            obj.isSupervised = true;
        end
    end
    
    methods (Access=protected,Hidden=true)
        function DS = runAction(Obj,DS)
            theClasses = Obj.classList;
            DS = DS.setObservations(theClasses((DS.getObservations >= Obj.getThreshold) + 1));
        end
         function xOut = runActionFast(Obj,xIn,ds) %#ok<INUSD>
            theClasses = Obj.classList;
            xOut = theClasses((xIn >= Obj.getThreshold) + 1);
        end
    end
    
    methods (Access = protected, Hidden = true)
        function ClassObj = preTrainProcessing(ClassObj, DataSet)
            % Overload preTrainProcessing() so that we can determine mary
            % output status
            assert(DataSet.isLabeled & DataSet.nClasses > 1,'The prtDataSetClass input to the train() method of a prtDecisionBinary must have non-empty targets and have more than one class.');
            
            ClassObj = preTrainProcessing@prtAction(ClassObj,DataSet);
        end
    end
    
    
    methods (Hidden)
        function str = exportSimpleText(self) %#ok<MANU>
            titleText = sprintf('%% prtDecisionBinaryMinPe\n');
            decisionThresholdText = prtUtilMatrixToText(self.threshold,'varName','minPeDecisionThreshold');
            str = sprintf('%s%s%s',titleText,decisionThresholdText);
        end
    end
end
