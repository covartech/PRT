%
%ds = prtDataGenBimodal(5e3);
%
%c = train(prtClusterStudentTOnlineVb,ds);

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




classdef prtClusterStudentTOnlineVb < prtCluster

    properties (SetAccess=private)
        name = 'Student T Online VB Clustering' % GMM Clustering
        nameAbbreviation = 'STOVBCluster' % GMMCluster
    end
    
    
    properties
        batchSize = 1000;
        maxIterations = 100;
        learningRateFunction = @(t)(t+5)^(-0.8);
        
        nClusters = 5;
        
        meanMean
        
        means
        covs
        pi
    end
    
    methods
        function self = prtClusterStudentTOnlineVb(varargin)
            self = prtUtilAssignStringValuePairs(self, varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        function self = trainAction(self, ds)
            
            d = ds.nFeatures;
            
            cDs = ds.bootstrap(self.batchSize);
            self.means = cDs.X(1:self.nClusters,:);
            self.covs = repmat(diag(var(cDs.X)), [1 1 self.nClusters]);
            
            self.pi = ones(1,self.nClusters)/self.nClusters;
            
            
            prior.mean = zeros(1,self.nClusters);
            prior.meanStrength = self.nFeaturesl
            
            for iter = 1:self.maxIterations
                cDs = ds.bootstrap(self.batchSize);
                cX = cDs.X;
                keyboard
                
                studentTGammas = zeros(self.batchSize, self.nClusters);
                logLikes = zeros(self.batchSize, self.nClusters);
                for iComp = 1:self.nClusters
                    cR = chol(self.covs(:,:,iComp));
                    
                    xRinv = bsxfun(@minus,cX,self.means(iComp,:)) / cR;
                    logSqrtDetSigma = sum(log(diag(cR)));
                    
                    studentTGammas(:,iComp) = (d + 1e-6)./(sum(xRinv.^2, 2) + 1e-6);
                    
                    logLikes(:,iComp) = -0.5*sum(xRinv.^2, 2) - logSqrtDetSigma - d*log(2*pi)/2 + d/2*log(studentTGammas(:,iComp)) + 1/2*studentTGammas(:,iComp);
                end
                
                phi = exp(bsxfun(@minus, logLikes, prtUtilSumExp(logLikes')'));
                
                
                
                for iComp = 1:self.nClusters
                    cWeightedPhi = phi(:,iComp).*studentTGammas(:,iComp);
                    cXSum = sum(bsxfun(@times, cX,  cWeightedPhi),1);
                    cN = sum(cWeightedPhi,1);
                
                    cMean = cXSum./cN;
                    
                    cXDeMean = bsxfun(@minus,cX,cMean);
                    cCov = bsxfun(@times, cXDeMean, cWeightedPhi)'*cXDeMean./cN;
                    
                    cPostMean = 
                    
                end
            end
        end
        function ds = runAction(self, ds)
            keyboard
        end
    end
end
