classdef prtDecisionOneClassPd < prtDecision
    % WRITE THE HELP

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


    
    % prtDecisionBinaryMinPe Decision object for minimum probability of
    % error in binary classification
    %
    % prtDec = prtDecisionBinaryMinPe creates a prtDecisionBinaryMinPe
    % object, which can be used find a decision threshold in a binary
    % classification problem that minimizes the probability of error.
    %
    % prtDecision objects are intended to be used either as members of
    % prtAlgorithm or prtClass objects.
    %
    % Example 1:
    %
    % ds = prtDataGenBimodal;              % Load a data set
    % classifier = prtClassKnn;            % Create a clasifier
    % classifier = classifier.train(ds);   % Train the classifier
    % yOutClassifier = classifier.run(ds); % Run the classifier
    %
    % % Construct a prtAlgorithm object consisting of a prtClass object and
    % % a prtDecision object
    % algo = prtClassKnn + prtDecisionBinaryMinPe;
    %
    % algo = algo.train(ds);        % Train the algorithm
    % yOutAlgorithm = algo.run(ds); % Run the algorithm
    %
    % % Plot and compare the results
    % subplot(2,1,1); stem(yOutClassifier.getObservations); title('KNN Output');
    % subplot(2,1,2); stem(yOutAlgorithm.getObservations); title('KNN + Decision Output');
    %
    % Example 2:
    %
    % ds = prtDataGenBimodal;              % Load a data set
    % classifier = prtClassKnn;            % Create a clasifier
    % classifier = classifier.train(ds);   % Train the classifier
    %
    % % Plot the trained classifier
    % subplot(2,1,1); plot(classifier); title('KNN');
    %
    % % Set the classifiers internealDecider to be a prtDecsion object
    % classifier.internalDecider = prtDecisionBinaryMinPe;
    %
    % classifier = classifier.train(ds); % Train the classifier
    % subplot(2,1,2); plot(classifier); title('KNN + Decision');
    %
    % See also: prtDecisionBinary, prtDecisionBinarySpecifiedPd,
    % prtDecisionBinarySpecifiedPf, prtDecisionMap
    
    properties (SetAccess = private)
        name = 'MinPe'   % MinPe
        nameAbbreviation = 'MINPE';  % MINPE
        
    end
    properties (SetAccess = public)
        pd
    end
    properties (Hidden = true)
        threshold
        uniqueClasses
    end
    methods
        
        function obj = prtDecisionOneClassPd(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end
    methods (Access=protected,Hidden=true)
        function Obj = trainAction(Obj,dataSet)
            
            if dataSet.nFeatures > 1
                error('prt:prtDecisionOneClassPd','prtDecisionOneClassPd can not be used on algorithms that output multi-column results; consider using prtDecisionMap instead');
            end
            if dataSet.nClasses ~= 1
                error('prt:prtDecisionOneClassPd:nonBinaryData','prtDecisionOneClassPd expects input data to have 1 class, but dataSet.nClasses = %d',dataSet.nClasses);
            end
            
            threshVals = sort(dataSet.getX, 'descend');
            numVals = numel(threshVals);
            
            threshInd = floor(Obj.pd*numVals);
            Obj.threshold = threshVals(threshInd);
            Obj.classList = dataSet.uniqueClasses;
            
        end
    end
    methods
        function threshold = getThreshold(Obj)
            % THRESH = getThreshold returns the objects threshold
            threshold = Obj.threshold;
        end
        function uniqueClasses = getUniqueClasses(Obj)
            uniqueClasses = Obj.uniqueClasses;
        end
    end
    methods (Access = protected, Hidden = true)
        function ClassObj = preTrainProcessing(ClassObj, DataSet)
            % Overload preTrainProcessing() so that we can determine mary
            % output status
            assert(DataSet.isLabeled & DataSet.nClasses == 1,'The prtDataSetClass input to the train() method of a prtDecisionBinary must have non-empty targets and have more than one class.');
            
            ClassObj = preTrainProcessing@prtAction(ClassObj,DataSet);
        end
        
        function DS = runAction(Obj,DS)
 %           theClasses = Obj.classList;
            DS = DS.setObservations(DS.getObservations >= Obj.getThreshold);
        end
    end
end
