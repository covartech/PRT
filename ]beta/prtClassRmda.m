classdef prtClassRmda < prtClass
    %
    % Robust supervised classification with mixture models: Learning from data with uncertain labels
    % Type 	Journal Article
    % Author 	Charles Bouveyron
    % Author 	Stéphane Girard
    % URL 	http://www.sciencedirect.com/science/article/pii/S0031320309001289
    % Volume 	42
    % Issue 	11
    % Pages 	2649-2658
    % Publication 	Pattern Recognition
    % http://ac.els-cdn.com/S0031320309001289/1-s2.0-S0031320309001289-main.pdf?_tid=53d9f482-348b-11e5-a20d-00000aab0f6c&acdnat=1438021051_7285a0d334788ab7dfc144dd6b113f98
    %
    % Example:
    %
    %     ds = prtDataGenXor;
    %
    %     eta = 0.2;
    %     flipLabel = rand(ds.nObservations,1) < eta;
    %
    %     newY = ds.Y;
    %     newY((ds.Y == 0) & flipLabel) = 1;
    %     newY((ds.Y == 1) & flipLabel) = 0;
    %
    %     dsFlippedY = ds;
    %     dsFlippedY.Y = newY;
    %
    %     subplot(2,2,1)
    %     class = train(prtClassRmda('nClusters',4),dsFlippedY);
    %     plot(class)
    %
    %     subplot(2,2,2)
    %     class = train(prtClassRmda('nClusters',10),dsFlippedY);
    %     plot(class)
    %
    %     subplot(2,2,3)
    %     class = train(prtClassMap('rvs',prtRvGmm('nComponents',2)),dsFlippedY);
    %     plot(class)
    %
    %     subplot(2,2,4)
    %     class = train(prtClassMap('rvs',prtRvGmm('nComponents',5)),dsFlippedY);
    %     plot(class)

    
    properties (SetAccess=private)
        name = 'Robust Mixture Discriminant Analysis'
        nameAbbreviation = 'RMDA'
        isNativeMary = true;
    end
    properties
        
        nClusters = 2;
        clusterer = prtClusterGmm('verboseStorage',false); 
        
        optimizeR = false;
        R = [];
    end
    methods
        function self = prtClassRmda(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    methods (Access=protected, Hidden = true)
        function self = trainAction(self, ds)

            % Train clusterer on the data
            self.clusterer.nClusters = self.nClusters;
            self.clusterer = train(self.clusterer,ds);
            
            psiMat = self.clusterer.run(ds);
            psiMat = psiMat.getObservations();
            
            yMat = ds.getTargetsAsBinaryMatrix;
            
            initR = yMat\psiMat;
            initR = bsxfun(@rdivide, initR, sum(initR,1));
            
            
            self.R = initR;
            if self.optimizeR
                
                % I have found the the Levenberg Marquardt optimization below isn't really worth it.
                % Perhaps it is non-convex..
                
                optR = initR;
                prevError = prtClassRmda.optimizationFitness(optR, psiMat, yMat);
                
                nOptIters = 100;
                lambda = 1;
                v = 1.2;
                
                for iter = 1:nOptIters
                    
                    gradient = prtClassRmda.optimizationGradient(optR, psiMat, yMat);
                    
                    [newParam1,currentError1] = prtClassRmda.optimizationTakeStep(optR, psiMat,yMat, gradient, lambda, prevError);
                    [newParam2,currentError2] = prtClassRmda.optimizationTakeStep(optR, psiMat,yMat, gradient, lambda/v, prevError);
                    
                    if currentError2 > prevError && currentError1 > prevError
                        while(currentError2 > prevError && currentError1 > prevError)
                            lambda = lambda*v;
                            [newParam1,currentError1] = prtClassRmda.optimizationTakeStep(optR, psiMat,yMat, gradient, lambda, prevError);
                            [newParam2,currentError2] = prtClassRmda.optimizationTakeStep(optR, psiMat,yMat, gradient, lambda/v, prevError);
                        end
                        if currentError2 <= prevError
                            optR = newParam2;
                            newError = currentError2;
                        else
                            optR = newParam1;
                            newError = currentError1;
                        end
                    elseif currentError2 <= prevError
                        lambda = lambda/v;
                        optR = newParam2;
                        newError = currentError2;
                    else
                        optR = newParam1;
                        newError = currentError1;
                    end
                    

%                     subplot(2,1,1)
%                     plot(psiMat*initR');
%                     subplot(2,1,2)
%                     plot(psiMat*optR')
%                     drawnow;
                    
                    errorChange = (prevError-newError);
                    if errorChange < 0
                        % Things have gone bad and we increased in error somehow...
                        keyboard
                    end
                    
                    if abs(errorChange) < 1e-6
                        break
                    end
                    prevError = newError;
                end
                self.R = optR;
                
%                 figure
%                 conf = psiMat*optR';
%                 confInit = psiMat*initR';
%                 prtScoreRoc(prtDataSetClass(cat(2,confInit(:,2),conf(:,2)),yMat(:,2)))
            end
        end
        function ds = runAction(self, ds)
            psiMat = self.clusterer.run(ds);
            psiMat = psiMat.getObservations();
            
            ds.X = psiMat*self.R';
        end
    end
    methods (Hidden, Static)
        function fit = optimizationFitness(R, psiMat, yMat)
           fit = sum(sum(log(psiMat*R').*yMat,2),1); 
        end
        function del = optimizationGradient(R, psiMat, yMat)
            del = zeros(size(R));
            for iClass = 1:size(yMat,2)
                del(iClass,:) = sum(bsxfun(@times,bsxfun(@rdivide,psiMat, (psiMat*R(iClass,:)')),yMat(:,iClass)),1);
            end
            del = del(:);
        end
        function [newR,newError] = optimizationTakeStep(R, psiMat,yMat, gradient, lambda, currentError)
            lhs = gradient'*gradient + lambda*diag(diag(gradient'*gradient));
            rhs = gradient'*(1-currentError);
            step = lhs\rhs;
               
            newR = R(:) + step';
            newR = reshape(newR, size(R));
            newR = bsxfun(@rdivide,newR,sum(newR,1));
  
            newError = prtClassRmda.optimizationFitness(newR, psiMat, yMat);
        end
    end
end