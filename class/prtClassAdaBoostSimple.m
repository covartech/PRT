classdef prtClassAdaBoostSimple < prtClass
    

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
        name = 'AdaBoostSimple'    % AdaBoost
        nameAbbreviation = 'AdaBoostSimple'  % AdaBoost
        isNativeMary = false;   % False
    end
    
    properties
        maxIters = 30;  % Max number of iterations
        deltaPeThreshold = .05;
    end
    
    properties (Hidden)
        alpha = [];
        verbose = false;
    end
    
    methods
        % Constructor
        function self = prtClassAdaBoostSimple(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
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
            y = double(dataSet.getTargetsAsBinaryMatrix);
            y = y(:,2);
            
            for t = 1:self.maxIters
                
                for featureIndex = 1:ds.nFeatures
                    x = 
            
                
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
