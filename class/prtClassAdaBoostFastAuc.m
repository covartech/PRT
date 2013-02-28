classdef prtClassAdaBoostFastAuc < prtClassAdaBoost
    %prtClassAdaBoostFastAuc AdaBoost classifier (fast training)
    %
    %   prtClassAdaBoostFastAuc is a version of prtClassAdaBoost that can
    %   be trained significantly more quickly than prtClassAdaBoost.
    %   prtClassAdaBoostFastAuc acheives this by assuming a linear
    %   classifier when picking the feature to be used in the weak learner.
    %   Unlike regular adaBoost, where the weak learner is trained and
    %   evaluated on each feature, in prtClassAdaBoostFastAuc, the feature
    %   is selected using simple ROC metrics, and this feature is used to
    %   train the weak learner for the current iteration.  This can be
    %   significantly faster than prtClassAdaBoost when the base learner is
    %   slow, or there are a very large number of features.
    %
    %   a = prtClassAdaBoostFastAuc;
    %   a = a.train(prtDataGenBimodal);
    %   plot(a)
    %
    %    See also: prtClassAdaBoost

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
        % Constructor
        function self = prtClassAdaBoostFastAuc(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            
            d = ones(dataSet.nObservations,1)./dataSet.nObservations;
            
            classifier = self.baseClassifier + prtDecisionBinaryMinPe;
            classifier.verboseStorage = false;
            %classifier.verboseFeatureNames = false;
            
            y = double(dataSet.getTargetsAsBinaryMatrix);
            y = y(:,2);
            y(y == 0) = -1;
            
            globalX = dataSet.getX;
            globalY = dataSet.getY;
            rocFlip = ones(1,dataSet.nFeatures);
            
            for t = 1:self.maxIters
                if t == 1
                    dataSetBootstrap = dataSet;
                    if self.downSampleBootstrap
                        dataSetBootstrap = dataSetBootstrap.bootstrap(self.downSampleBootstrap);
                    end
                else
                    dataSetBootstrap = dataSet.bootstrap(dataSet.nObservations,d);
                    if self.downSampleBootstrap
                        dataSetBootstrap = dataSetBootstrap.bootstrapByClass(self.downSampleBootstrap);
                    end
                end
                
                localX = dataSetBootstrap.getX;
                localY = dataSetBootstrap.getY;
                if length(unique(localY)) < 2
                    %d told us not to re-sample
                    return;
                end
                
                pe = nan(1,size(localX,2));
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
                    
                    %Evaluate the ROC curve for a feature:
                    [pf,pd,tau,auc] = prtClassAdaBoost.fastRoc(localX(:,feature)*rocFlip(feature),localY); 
                    if auc < .5
                        rocFlip(feature) = -1*rocFlip(feature);
                        %try again, flip the ROC
                        [pf,pd,tau] = prtClassAdaBoost.fastRoc(localX(:,feature)*rocFlip(feature),localY); 
                    end
                    
                    %Figure out the optimal expected threshold:
                    tempPe = prtUtilPfPd2Pe(pf,pd);
                    [~,ind] = min(tempPe);
                    threshold = tau(ind);
                    
                    %Use the threshold to estimate pe(feature) from all the
                    %data 
                    decisions = globalX(:,feature)*rocFlip(feature) >= threshold;
                    correctLogical = decisions == (globalY == 1);
                    pe(feature) = sum(double(~correctLogical).*d);
                end
                [minDeltaPe,minInd] = max(abs(pe-.5));
                
                if minDeltaPe < self.deltaPeThreshold
                    return;
                else
                    
                    baseClass = self.baseClassifier;
                    baseClass.verboseStorage = false;
                    algo = prtFeatSelStatic('selectedFeatures',minInd) + baseClass + prtDecisionBinaryMinPe;
                    algo.verboseStorage = false;
                    %algo.verboseFeatureNames = false;
                    
                    if t == 1
                        self.classifierArray = train(algo,dataSetBootstrap);
                    else
                        self.classifierArray(t) = train(algo,dataSetBootstrap);
                    end
                    
                    yOut = run(self.classifierArray(t),dataSet);
                    wrong = yOut.getX ~= yOut.getY;
                    eps_t = sum(d.*wrong);
                    
                    if eps_t == 0 %nothing wrong!
                        self.alpha(t) = 10;
                    else
                        self.alpha(t) = 1/2*log((1-eps_t)/eps_t);
                    end
                    
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
        
    end
end
