classdef prtDecisionBinarySpecifiedPd < prtDecisionBinary
    % prtDecisionBinarySpecifiedPd Decision object for a specified Pd
    %
    % prtDec = prtDecisionBinarySpecifiedPd creates a prtDecisionBinarySpecifiedPd
    % object, which can be used find a decision threshold in a binary
    % classification problem for a specific probability of detection Pd.
    %
    % A prtDecisionBinarySpecifiedPd has the following member:
    %
    % pd - The specified probability of detection, which must be between 0
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
    % dec = prtDecisionBinarySpecifiedPd;
    % dec.pd = .7;   % Set the desired probility of detection.
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


    
    %
    % prtDecisionBinarySpecifiedPd prt Decision action to find a threshold in a
    % binary problem to approximately acheive a specified probability of
    % detection
    %
    
    properties (SetAccess = private)
        name = 'SpecifiedPd'   %SpecifiedPd
        nameAbbreviation = 'SpecPd'; % SpecPd
    end
    properties
        pd  % The desired probability of detection
    end
    properties (Hidden = true)
        threshold
    end
    methods
        function obj = set.pd(obj,value)
            assert(isscalar(value) && value >= 0 && value <= 1,'pd parameter must be scalar in [0,1], value provided is %s',mat2str(value));
            obj.pd = value;
        end
    end
    methods
        function obj = prtDecisionBinarySpecifiedPd(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end
    methods (Access=protected,Hidden=true)
        
        
        function Obj = trainAction(Obj,dataSet)
            
            if dataSet.nFeatures > 1
                error('prt:prtDecisionBinarySpecifiedPd','prtDecisionBinarySpecifiedPd can not be used on algorithms that output multi-column results; consider using prtDecisionMap instead');
            end
            if dataSet.nClasses ~= 2
                error('prt:prtDecisionBinarySpecifiedPd:nonBinaryData','prtDecisionBinarySpecifiedPd expects input data to have 2 classes, but dataSet.nClasses = %d',dataSet.nClasses);
            end
            
            [rocPf,rocPd,thresh] = prtScoreRoc(dataSet.getObservations,dataSet.getTargets); %#ok<ASGLU>
            thresh = thresh(:);
            
            if isempty(Obj.pd)
                error('prt:prtDecisionBinarySpecifiedPd:invalidPd','Attempt to train prtDecisionBinarySpecifiedPd withoug setting pd');
            end
            
            index = find(rocPd >= Obj.pd,1);
            Obj.threshold = thresh(index);
            
            %disp(Obj.threshold)
            Obj.classList = dataSet.uniqueClasses;
        end
    end
    methods
        function threshold = getThreshold(Obj)
            threshold = Obj.threshold;
        end
    end
end
