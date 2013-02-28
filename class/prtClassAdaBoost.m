classdef prtClassAdaBoost < prtClass
    %prtClassAdaBoost AdaBoost classifier
    %
    %    CLASSIFIER = prtClassAdaBoost returns a AdaBoost classifier
    %
    %    CLASSIFIER = prtClassAdaBoost(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassAdaBoost object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassAdaBoost object inherits all properties from the abstract
    %    class prtClass. In addition is has the following properties:
    %
    %    baseClassifier     - the prtClass object that forms the "weak" or
    %                         "Base" classifier for the AdaBoost.  This
    %                         classifier is iteratively trained on each of
    %                         the features in succession.
    %    maxIters            - Number of iterations to run (maximum number of weak
    %                         classifiers to train)
    %    deltaPeThreshold (.05) - Specify the minimum error distance (from
    %                        0.5) allowed.  Smaller values result in more
    %                        complicated adaBoost classifiers, larger
    %                        values in less complicated classifiers.
    %    
    %    downSampleBootstrap (false) - Specify whether (and how many)
    %                           bootstrap-by class bootstrap samples to
    %                           take at each iteration.  False or 0 uses
    %                           the default number of bootstrap samples.
    %                           Any other integer specifies the number of
    %                           samples to use from
    %                           ds.bootstrapDataByClass.
    %
    %    AdaBoost is a meta algorithm for training ensembles of weak
    %    classifiers on different sub-sets of the complete data set, with
    %    later classifiers trained to focus on data points that were
    %    mis-classified in earlier iterations.  A complete description of the
    %    algorithm for AdaBoost is beyond the scope of this help entry, but
    %    more information AdaBoost can be found at the following URL:
    %
    %    http://en.wikipedia.org/wiki/AdaBoost
    %
    %    The PRT AdaBoost uses individual features to constitute each weak
    %    learner in each iteration.  At each iteration, the feature
    %    corresponding to the best weak learner operating on the current
    %    weighted data distribution is used in the aggregate classifier.
    %
    %    A prtClassAdaBoost object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT
    %    method from prtClass.
    %
    %    Example:
    %
    %    TestDataSet = prtDataGenUnimodal;       % Create some test and
    %    TrainingDataSet = prtDataGenUnimodal;   % training data
    %    classifier = prtClassAdaBoost;                     % Create a classifier
    %    classifier = classifier.train(TrainingDataSet);    % Train
    %    classified = run(classifier, TestDataSet);         % Test
    %    subplot(2,1,1);
    %    classifier.plot;
    %    subplot(2,1,2);
    %    [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %    h = plot(pf,pd,'linewidth',3);
    %    title('ROC'); xlabel('Pf'); ylabel('Pd');
    %
    %    See also: prtClassAdaBoostFastAuc

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


    
    properties (SetAccess=private)
        name = 'AdaBoost'    % AdaBoost
        nameAbbreviation = 'AdaBoost'  % AdaBoost
        isNativeMary = false;   % False
    end
    
    properties
        baseClassifier = prtClassFld; % The weak classifier
        maxIters = 30;  % Max number of iterations
        deltaPeThreshold = .05;
        downSampleBootstrap = false;
    end
    properties (Hidden)
        classifierArray = [];
        alpha = [];
        verbose = false;
    end
    
    methods
        % Constructor
        function self = prtClassAdaBoost(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        % Set function
        function self = set.baseClassifier(self,val)
            if (~isa(val,'prtClass'))
                error('prtClassAdaBoost:baseClassifier','baseClassifier parameter must be a prtClass');
            end
            self.baseClassifier = val;
        end
        
        
        function self = set.maxIters(self,val)
            if ~prtUtilIsPositiveScalarInteger(val)
                error('prt:prtClassAdaBoost:nBoosts','nBoosts must be a positive scalar integer');
            end
            self.maxIters = val;
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            
            
            if ~dataSet.isBinary
                error('prtClassAdaBoost:nonBinaryTraining','Input dataSet for prtClassAdaBoost.train must be binary');
            end
            
            d = ones(dataSet.nObservations,1)./dataSet.nObservations;
            
            classifier = self.baseClassifier + prtDecisionBinaryMinPe;
            classifier.verboseStorage = false;
            
            y = double(dataSet.getTargetsAsBinaryMatrix);
            y = y(:,2);
            y(y == 0) = -1;
            validData = true;
            
            for t = 1:self.maxIters
                if t == 1
                    dataSetBootstrap = dataSet;
                    if self.downSampleBootstrap
                        dataSetBootstrap = dataSetBootstrap.bootstrap(self.downSampleBootstrap);
                    end
                else
                    dataSetBootstrap = dataSet.bootstrap(dataSet.nObservations,d);
                    if self.downSampleBootstrap
                        dataSetBootstrap = dataSetBootstrap.bootstrap(self.downSampleBootstrap);
                    end
                    if dataSetBootstrap.isUnary 
                        %dumb luck, but indicative of a low probability d... just exit for now
                        validData = false; 
                    end
                end
                if ~validData
                    break;
                end
                
                pe = nan(dataSet.nFeatures,1);
                if self.verbose
                    fprintf('\nIter: %d ',t);
                end
                for feature = 1:dataSet.nFeatures
                    if ~mod(feature,1000) & self.verbose
                        %disp(feature./dataSet.nFeatures);
                        if feature == 1000
                            fprintf('\n');
                        end
                        fprintf('.');
                    end
                    
                    tempClassifier = prtFeatSelStatic('selectedFeatures',feature) + self.baseClassifier + prtDecisionBinaryMinPe;
                    tempClassifier.verboseStorage = false;
                    %tempClassifier.verboseFeatureNames = false;
                    
                    classifier = train(tempClassifier,dataSetBootstrap);
                    yOut = run(classifier,dataSet);
                    
                    [~,correctLogical] = prtScorePercentCorrect(yOut);
                    pe(feature) = sum(double(~correctLogical).*d);
                end
                [minDeltaPe,minInd] = max(abs(pe-.5));
                
                if minDeltaPe < self.deltaPeThreshold
                    return;
                else
                    feature = minInd;
                    tempClassifier = prtFeatSelStatic('selectedFeatures',feature) + self.baseClassifier + prtDecisionBinaryMinPe;
                    theClassifier = train(tempClassifier,dataSetBootstrap);
                    if t == 1
                        self.classifierArray = theClassifier;
                    else
                        self.classifierArray(t) = theClassifier;
                    end
                    self.alpha(t) = 1/2*log((1-pe(minInd))/pe(minInd));
                    
                    yOut = run(self.classifierArray(t),dataSet);
                    h = double(yOut.getObservations);
                    h(h == 0) = -1;
                    
                    d = d.*exp(-self.alpha(t).*y.*h);
                    
                    if sum(d) == 0
                        return;
                    end
                    d = d./sum(d);
                end
                
            end
        end
        
        function DataSetOut = runAction(self,DataSet)
            DataSetOut = prtDataSetClass(zeros(DataSet.nObservations,1));
            
            for t = 1:length(self.classifierArray)
                theObs = run(self.classifierArray(t),DataSet);
                X = theObs.getObservations;
                X(X == 0) = -1;
                currObs = self.alpha(t)*X;
                DataSetOut = DataSetOut.setObservations(DataSetOut.getObservations + currObs);
            end
            
        end
        
    end
    
    methods (Static)
        %used by sub-classes like prtClassAdaBoostFastAuc
        function [pFa,pD,tau,auc] = fastRoc(ds,y)
            [sortedDS, sortingInds] = sort(ds,'descend');
            nanSpots = isnan(sortedDS);
            
            % Sort y
            sortedY = y(sortingInds);
            nH1 = sum(sortedY);
            nH0 = length(sortedY)-nH1;
            
            % Start making
            pFa = double(~sortedY); % number of false alarms as a function of threshold
            pD = double(sortedY); % number of detections as a function of threshold
            
            pD(nanSpots & ~~sortedY) = 0; % NaNs are not counted as detections
            pFa(nanSpots & ~sortedY) = 0; % or false alarms
            
            pD = cumsum(pD)/nH1;
            pFa = cumsum(pFa)/nH0;
            
            pD = cat(1,0,pD);
            pFa = cat(1,0,pFa);
            
            tau = cat(1,inf,sortedDS(:));
            if nargout > 3
                %this is faster than prtScoreRoc if we've already calculated pd and pf,
                %which we have:
                auc = trapz(pFa,pD);
            else
                auc = [];
            end
            
        end
    end
end
