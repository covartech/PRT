%
%ds = prtDataGenBimodal(5e3);
%
%c = train(prtClusterStudentTOnlineVb,ds);



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