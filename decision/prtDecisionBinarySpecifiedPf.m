classdef prtDecisionBinarySpecifiedPf < prtDecisionBinary
     % prtDecisionBinarySpecifiedPd Decision object for a specified Pf
    %
    % prtDec = prtDecisionBinarySpecifiedPf creates a prtDecisionBinarySpecifiedPf
    % object, which can be used find a decision threshold in a binary
    % classification problem for a specific probability of false alarm Pf.
    %
    % A prtDecisionBinarySpecifiedPf has the following member:
    %
    % pf - The specified probability of false alarm, which must be between 0
    % and 1.
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
    % dec = prtDecisionBinarySpecifiedPf;
    % dec.pf = .7;   % Set the desired probility of detection.
    % algo = prtClassKnn + dec;
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
    % classifier.internalDecider = dec;
    %
    % classifier = classifier.train(ds); % Train the classifier
    % subplot(2,1,2); plot(classifier); title('KNN + Decision');
    %
    % See also: prtDecisionBinary, prtDecisionBinaryMinPe,
    % ptDecisionBinarySpecifiedPf, prtDecisionMap

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


    
    properties (SetAccess = private)
        name = 'SpecifiedPf'; % SpecifiedPf
        nameAbbreviation = 'SpecPf'; % SpecPf
    end
    properties
        pf % The desired probability of false alarm
    end
    properties (Hidden = true)
        threshold
    end
    methods
        function obj = set.pf(obj,value)
            assert(isscalar(value) && value >= 0 && value <= 1,'d parameter must be scalar in [0,1], value provided is %s',mat2str(value));
            obj.pf = value;
        end
    end
    methods
        function obj = prtDecisionBinarySpecifiedPf(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end
    methods (Access=protected,Hidden=true)
        
        function Obj = trainAction(Obj,dataSet)
            
            if dataSet.nFeatures > 1
                error('prt:prtDecisionBinarySpecifiedPf','prtDecisionBinarySpecifiedPf can not be used on algorithms that output multi-column results; consider using prtDecisionMap instead');
            end
            if dataSet.nClasses ~= 2
                error('prt:prtDecisionBinarySpecifiedPf:nonBinaryData','prtDecisionBinarySpecifiedPf expects input data to have 2 classes, but dataSet.nClasses = %d',dataSet.nClasses);
            end
            
            [rocPf,pd,thresh] = prtScoreRoc(dataSet.getObservations,dataSet.getTargets); %#ok<ASGLU>
            
            if isempty(Obj.pf)
                error('prt:prtDecisionBinarySpecifiedPf:invalidPf','Attempt to train prtDecisionBinarySpecifiedPf withoug setting pf');
            end
            
            index = find(rocPf < Obj.pf,1,'last');
            Obj.threshold = thresh(index);
            Obj.classList = dataSet.uniqueClasses;
        end
    end
    methods
        function threshold = getThreshold(Obj)
             % THRESH = getThreshold returns the objects threshold
            threshold = Obj.threshold;
        end
    end
end
