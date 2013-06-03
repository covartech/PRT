classdef prtDecisionMap < prtDecision & prtActionBig
    % prtDecisionMap Maximum a-posteriori decision making
    %
    % prtDec = prtDecisionMap creates a prtDecisionBinaryMap
    % object, which can be used to perform Maximu a-posteriori decions.
    %
    % prtDecision objects are intended to be used either as members of
    % prtAlgorithm or prtClass objects.
    %
    % Example 1:
    %
    % ds = prtDataGenMary;                    % Load a data set
    % classifier = prtClassKnn;            % Create a clasifier
    % classifier = classifier.train(ds);   % Train the classifier
    % yOutClassifier = classifier.run(ds); % Run the classifier
    %
    % % Construct a prtAlgorithm object consisting of a prtClass object and
    % % a prtDecision object
    % algo = prtClassKnn + prtDecisionMap; 
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
    % ds = prtDataGenMary;              % Load a data set
    % classifier = prtClassKnn;            % Create a clasifier
    % classifier = classifier.train(ds);   % Train the classifier
    %
    % % Plot the trained classifier
    % subplot(2,1,1); plot(classifier); title('KNN');
    %
    % % Set the classifiers internealDecider to be a prtDecsion object
    % classifier.internalDecider = prtDecisionMap;
    %
    % classifier = classifier.train(ds); % Train the classifier
    % subplot(2,1,2); plot(classifier); title('KNN + Decision');
    %    	
    % See also: prtDecisionBinary, prtDecisionBinarySpecifiedPd,
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


     properties (SetAccess = private)
        name = 'MAP'  % MAP
        nameAbbreviation = 'MAP';  % MAP
     end
    
    properties (SetAccess = private, Hidden = true)
        runBinary = false;
        minPeDecision = [];
    end
    
    methods
        function self = prtDecisionMap(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    methods (Access=protected,Hidden=true)
        
        function self = trainActionBig(self, dataSet)
            if isa(dataSet,'prtDataSetBigClass')
                self.classList = dataSet.uniqueClasses;
            else
                self.classList = 1:dataSet.nFeatures;
            end
            %binary classification
            if dataSet.nClasses == 2 && dataSet.nFeatures == 1
                warning('prtDecisionMap:binaryData','User specified MAP decision, but input data was binary, and classifier provided binary decision statistics.  MAP will default to prtDecisionBinaryMinPe, but there are subtle differences between these approaches.  This warning will only be shown once.  To turn it off permanently, use "warning off prtDecisionMap:binaryData" in your startup M-file');
                warning off prtDecisionMap:binaryData
                self.runBinary = true;
                self.minPeDecision = prtDecisionBinaryMinPe;
                self.minPeDecision = self.minPeDecision.trainBig(dataSet);
            end
        end
        
        function self = trainAction(self, dataSet)
            if isa(dataSet,'prtDataSetClass')
                self.classList = dataSet.uniqueClasses;
            else
                self.classList = 1:dataSet.nFeatures;
            end
            %binary classification
            if dataSet.nClasses == 2 && dataSet.nFeatures == 1
                warning('prtDecisionMap:binaryData','User specified MAP decision, but input data was binary, and classifier provided binary decision statistics.  MAP will default to prtDecisionBinaryMinPe, but there are subtle differences between these approaches.  This warning will only be shown once.  To turn it off permanently, use "warning off prtDecisionMap:binaryData" in your startup M-file');
                warning off prtDecisionMap:binaryData
                self.runBinary = true;
                self.minPeDecision = prtDecisionBinaryMinPe;
                self.minPeDecision = self.minPeDecision.train(dataSet);
            end
        end
        
        function dataSet = runAction(self,dataSet)
            yOut = dataSet.getObservations;
            
            %Under certain strange circumstances, e.g., in prtClassCascade,
            %the self.runBinary flag may be turned on, even when the actual
            %mode of operation should be "m-ary". It's not clear to me when
            %or why this is happening.  So I now check size(yOut,2) in
            %addition to self.runBinary...
            %       -Pete, 2011.11.21
            if size(yOut,2) == 1 && self.runBinary
                dataSet = self.minPeDecision.run(dataSet);
                return;
            else
                if size(yOut,2) > 1
                    [twiddle,index] = max(yOut,[],2); %#ok<ASGLU>
                else
                    error('prt:prtDecisionMap','Cannot run prtDecisionMap on algorithms with single-column output; use prtDecisionBinaryMinPe instead');
                end
            end
            if ~isempty(self.classList)
                if max(index(:)) <= length(self.classList)
                    classList = self.classList(index);
                else
                    classList = index;
                end
            else
                classList = index;
            end
            classList = classList(:);
            dataSet = dataSet.setObservations(classList);
        end
    
        function xOut = runActionFast(self,xIn,ds) %#ok<INUSD>
           [twiddle,index] = max(xIn,[],2); %#ok<ASGLU>
           xOut = self.classList(index);
           xOut = xOut(:);
        end
    end
end
