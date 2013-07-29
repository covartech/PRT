% PRTBRVMVT - PRT BRV Multivariate Normal Observation Model
%
% Impliments all abstract properties and methods from prtBrvObsModel.
%
% Additional Properties:
%   model - prtBrvMvnHierarchy object that contains the parameters of the
%       prior/posterior
% Additional Hidden Properties:
%   initFuzzyFactor - Used to weaken the results of kmeans in the
%       mixture initialization process. Between 0 and 1 (inclusivly) and
%       probably greater than 0.9. Default 1.
%   initModifiyPrior - Specifies weather to modify the covariance of the
%       prior to more closely match that of the training data during
%       mixture initialization.
%
% Also inherits from prtBrv, prtBrvVbOnline, prtBrvVbOnlineMembershipModel

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



classdef prtBrvMvt < prtBrv & prtBrvVbMembershipModel
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties required by prtAction
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        name = 'Multi-varite Student T Bayesian Random Variable';
        nameAbbreviation = 'BRVMVT';
    end
    
    properties (SetAccess = protected)
        isSupervised = false;
        isCrossValidateValid = true;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrv
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    methods
        function self = estimateParameters(self, x)
            self = conjugateUpdate(self, self, x);
        end
        
        function y = predictivePdf(self, x)
            y = prtRvUtilStudentTPdf(x, self.model.meanMean, self.model.covPhi./self.model.covNu, self.model.covNu);
        end
        function y = predictiveLogPdf(self, x)
            y = prtRvUtilStudentTLogPdf(x, self.model.meanMean, self.model.covPhi./self.model.covNu, self.model.covNu);
        end
        
        function val = getNumDimensions(self)
            val = length(self.model.meanMean);
        end
        
        function self = initialize(self, x)
            x = self.parseInputData(x);
            if ~self.model.isValid
                self.model = self.model.defaultParameters(size(x,2));
                
                self.nu = 10;
                
                self.uA = 1e-6;
                self.uB = 1e-6;
            end
        end
    
        % Optional methods
        %------------------------------------------------------------------
        function kld = conjugateKld(self, priorObj)
            kld = prtRvUtilMvnWishartKld(self.model.meanBeta,...
                self.model.covNu,self.model.meanMean,self.model.covPhi,...
                priorObj.model.meanBeta,priorObj.model.covNu,...
                priorObj.model.meanMean,priorObj.model.covPhi);
        end
        
        function s = posteriorMeanStruct(self)
            nDimensions = length(self.model.meanMean);

            s.mean = self.model.meanMean;
            s.covariance = 1/self.model.covNu .* self.model.covPhi;
            s.degreesOfFreedom = self.model.covNu + 1 - nDimensions;
        end
        
        function plotCollection(selfs,colors)
            
            nComponents = length(selfs);
            
            if nargin < 2
                colors = prtPlotUtilClassColors(nComponents);
            end
            
            nDimensions = selfs(1).nDimensions;
            
            if nDimensions < 3
                meanMat = zeros(nDimensions,nComponents);
                covMat = zeros([nDimensions nDimensions nComponents]);
                
                for s = 1:nComponents
                    pm = selfs(s).posteriorMeanStruct;
                    meanMat(:,s) = pm.mean;
                    covMat(:,:,s) = pm.covariance;
                end
            end
                
            plotLimits = zeros(nComponents,length(selfs(1).plotLimits));
            for s = 1:nComponents
                plotLimits(s,:) = selfs(s).plotLimits();
            end
            
            
            if nDimensions == 1
                plotLimits = [min(plotLimits(:,1)),max(plotLimits(:,2))];
            elseif nDimensions == 2
                plotLimits = [min(plotLimits(:,1)),max(plotLimits(:,2)),min(plotLimits(:,3)),max(plotLimits(:,4))];
            end
            
            if nDimensions == 1
                maxVar = max(arrayfun(@(S)S.model.covPhi/S.model.covNu,selfs));
                meanPdfSamples = linspace(min(meanMat)-sqrt(maxVar)*2,max(meanMat)+sqrt(maxVar)*2,1000)';
                for s = 1:nComponents
                    h = plot(meanPdfSamples,exp(prtRvUtilMvnLogPdf(meanPdfSamples,meanMat(:,s),1/selfs(s).model.covNu.*selfs(s).model.covPhi)));
                    set(h,'color',colors(s,:));
                    hold on
                end
                hold off
                v = axis;
                ylim([0 v(4)]);
                title('Posterior Mean Source PDFs');
                xlim(plotLimits)
                
            elseif nDimensions == 2
                for s = 1:nComponents
                    ellipseHandle = prtPlotUtilMvnEllipse(meanMat(:,s)',squeeze(covMat(:,:,s)));
                    set(ellipseHandle,'Color',colors(s,:));
                    hold on
                    plot(meanMat(1,s),meanMat(2,s),'x','color',colors(s,:),'markerSize',8);
                end
                hold off;
                title('Posterior Mean Source PDFs');
                axis(plotLimits)
                
            else
    
                for s = 1:nComponents
                    cMean = selfs(s).model.meanMean;
                    cCov = selfs(s).model.covPhi./selfs(s).model.covNu;
                    cStds = sqrt(diag(cCov));
                    
                    plot(1:length(cMean),cMean,'x-','color',colors(s,:));
                    hold on
                    for iDim = 1:length(cMean)
                        plot(iDim*[1 1],cStds(iDim)*2*[-1 1]+cMean(iDim),'color',colors(s,:))
                    end
                end
                hold off
                title('Posterior Mean Conditional PDF')
                xlim([0.5 length(cMean)+0.5]);
            end
        end
        
        function val = plotLimits(self)
            
            pm = self.posteriorMeanStruct;
            
            minX = min(pm.mean, [], 1)' - 2*sqrt(diag(pm.covariance));
            maxX = max(pm.mean, [], 1)' + 2*sqrt(diag(pm.covariance));
            
            val = zeros(1,2*self.nDimensions);
            val(1:2:self.nDimensions*2-1) = minX;
            val(2:2:self.nDimensions*2) = maxX;
            
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrvVb
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    methods
        function [self, training] = vbBatch(self,x)
            % Since we are purely conjugate we actually don't need vbBatch
            % However we must implement it.
            self = conjugateUpdate(self,x);
            training = struct([]);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrvMembershipModel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    methods
        function [phiMat, priorObjs] = collectionInitialize(selfs, priorObjs, x) % Vector of objects
            
            nClusters = length(selfs);
            
            fuzzyFactor = selfs(1).initFudgeFactor;
            modifyPrior = selfs(1).initModifiyPrior;
            
            if nClusters < size(x,1)
                % Run K-Means
                [classMeans, kmYout] = prtUtilKmeans(x,nClusters,'handleEmptyClusters','random'); %#ok<ASGLU>
                
                N_bar = hist(kmYout,1:nClusters);
                [sortedN_bar, sortedClusters] = sort(N_bar,'descend'); %#ok<ASGLU>
                Yout = kmYout;
                
                for iCluster = 1:nClusters
                    Yout(kmYout==sortedClusters(iCluster)) = iCluster;
                end
                
                phiMat = zeros(size(x,1),nClusters);
                phiMat(sub2ind(size(phiMat),(1:size(x,1))',Yout)) = 1;
                
                phiMat(logical(phiMat)) = fuzzyFactor;
                phiMat(~logical(phiMat)) = (1-fuzzyFactor)./nClusters;
            else
                phiMat = eye(size(x,1));
                phiMat = cat(2,phiMat,zeros(size(x,1),nClusters-size(phiMat,2)));
            end
            
            for iCluster = 1:nClusters
                priorObjs(iCluster).model = priorObjs(iCluster).model.defaultParameters(size(x,2));
            end

            if modifyPrior
                oldCovPhi = priorObjs(1).model.covPhi;
                
                % Gives problems sometimes
                covMat = zeros([size(x,2) size(x,2) nClusters]);
                for iCluster = 1:nClusters
                    cX = x(phiMat(:,iCluster)>(1-fuzzyFactor),:);
                    if isempty(cX) || size(cX,1)==1
                        covMat = oldCovPhi*priorObjs(1).model.covNu;
                    else
                        covMat(:,:,iCluster) = cov(cX);
                    end
                end
                
                newCov = mean(covMat,3);
                priorObjs(1).model.covPhi = newCov.*priorObjs(1).model.covNu;
                
                if det(priorObjs(1).model.covPhi./priorObjs(1).model.covNu) < eps
                    % Abandon ship
                    priorObjs(1).model.covPhi = oldCovPhi;
                end
                
                for iPrior = 2:length(priorObjs)
                    priorObjs(iPrior) = priorObjs(1);
                end
            end
        end
        
        function self = weightedConjugateUpdate(self, priorSelf, x, weights)
            x = self.parseInputData(x);
            
            if nargin < 4 || isempty(weights)
                weights = ones(size(x,1),1);
            end

            priorSelf = priorSelf.initialize(x);
            
            self.nu = priorSelf.nu;
            self.uA = priorSelf.uA;
            self.uB = priorSelf.uB;
            
            nIterations = 10;
            
            for iter = 1:nIterations
                
                u = self.uA./self.uB;
                
                modWeights = weights.*u;
                
                N_bar = sum(modWeights,1);
            
                % We want to do simply this
                %muBar = 1./N_bar.*sum(bsxfun(@times,X,weights));
                % but to avoid divide by zero warnings we do this.
                muBar = sum(bsxfun(@times,x,modWeights),1);
                if N_bar > 0 % It is possible to use a higher threshold here
                    muBar = muBar./N_bar;
                else
                    % We include these lines incase the threshold above is
                    % changes to be different than zero
                    N_bar = 0;
                    modWeights = zeros(size(x,1),1);
                
                    muBar = zeros(1,size(x,2));
                end
                
                xWeightedDemeaned = bsxfun(@times,bsxfun(@minus,x,muBar),sqrt(modWeights));
                sigmaBar = xWeightedDemeaned'*xWeightedDemeaned;
            
                meanPriorDifference = muBar - priorSelf.model.meanMean;
            
                % meanBeta = nu
                % covNu = gamma
                
                self.model = priorSelf.model;
                self.model.meanBeta = N_bar + priorSelf.model.meanBeta; %nu
                self.model.meanMean = (muBar.*N_bar + priorSelf.model.meanMean.*priorSelf.model.meanBeta) ./ (N_bar + priorSelf.model.meanBeta);
                self.model.covNu = N_bar + priorSelf.model.covNu;
                self.model.covPhi = sigmaBar + priorSelf.model.covPhi +...
                    N_bar*priorSelf.model.meanBeta/self.model.meanBeta*(meanPriorDifference'*meanPriorDifference);
                
                % Update U parameters
                nDims = size(x,2);
                
                xDemeaned = bsxfun(@minus,x,self.model.meanMean);
                
                T = chol(self.model.covPhi/self.model.covNu);
                xNorm = xDemeaned / T;
                term = sum(xNorm.^2,2);
                
                self.uA = (nDims + self.nu)/2;
                self.uB = 1/2*term(:) + nDims/2/self.model.meanBeta + self.nu/2;
                
                % Update degrees of freedom (nu)
                
                
                % Imposing a Gamma Prior and Posterior -> Non conjugate but
                priorNuA = 1e-6;
                priorNuB = 1e-6;
                nuA = priorNuA + sum(modWeights,1)/2;
                nuB = priorNuB - 1/2*(sum(modWeights,1) + sum(modWeights.*(psi(max(self.uA,eps)) - log(self.uB) - self.uA./self.uB)));
                self.nu = nuA./nuB;
                
                % Free Form point estimate. Maximum Likelihood (slower and finiky)
                %self.nu = max(fzero(@(x)(log(x/2) - psi(max(x/2,eps)) + (1 + 1/N_bar*sum(modWeights.*(psi(self.uA) - log(self.uB) - self.uA./self.uB)))),self.nu),eps);

                
%                 mu = self.model.meanMean;
%                 sig = sqrt(self.model.covPhi/self.model.covNu);
%                 
%                 subplot(5,1,1:3)
%                 fill([1 size(x,1) size(x,1) 1 1],mu + 2*sig*[1 1 -1 -1 1],[0.6 0.6 0.6]);
%                 hold on
%                 plot([1 size(x,1)], mu*ones(1,2),'k');
%                 plot(x);
%                 hold off
%                 xlim([1 size(x,1)])
%                 title('Selected Data Downtrack Slice with Guassian Statistics','FontSize',16);
%                 xlabel('Down Track');
%                 
%                 subplot(5,1,4);
%                 plot(prtRvUtilMvnLogPdf(x, mu, sig.^2));
%                 xlim([1 size(x,1)])
%                 title('Gaussian Log-Likelihood','FontSize',16);
%                 xlabel('Down Track');
%                 ylabel([-50 0]);
%                 
%                 subplot(5,1,5)
%                 plot(self.uA./self.uB)
%                 xlim([1 size(x,1)])
%                 title('Student-T Nosie Variance','FontSize',16);
%                 xlabel('Down Track');
%                 
%                 disp(self.nu)
%                 
%                 drawnow;
%                 pause
            end
            
        end
        
        function self = conjugateUpdate(self, prior, x)
            x = self.parseInputData(x);
            
            self = weightedConjugateUpdate(self, prior, x, ones(size(x,1),1));
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrvVbMembershipModel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
	methods
        function y = conjugateVariationalAverageLogLikelihood(self, x)
            nDims = size(x,2);
            
            u = self.uA./self.uB;
            logU = nDims/2*(psi(self.uA) -self.uB);
            
            innerPsiTerm = (self.model.covNu + 1 - (1:nDims)')./2;
            lnDetGammaTilde = sum(psi(innerPsiTerm)) - prtUtilLogDet(self.model.covPhi) + nDims*log(2);
            
            xDemeaned = bsxfun(@minus,x,self.model.meanMean);
            
            T = chol(self.model.covPhi/self.model.covNu);
            xNorm = xDemeaned / T;
            term = sum(xNorm.^2,2);
            
            % % I don't know where I got this one. I seemed to have made it
            % % up late at night.
            %y = 1/2*lnDetGammaTilde - 1/2*term(:).*u - nDims/2/self.model.meanBeta + nDims*logU + self.nu/2*log(self.nu/2) -gammaln(self.nu/2) + (self.nu/2 - 1).*logU  - self.nu/2.*u;
            
            % % This one appears mostly correct (This is what Archameau says
            % % Svensen used
            %y = 1/2*lnDetGammaTilde - 1/2*term(:).*u - nDims/2/self.model.meanBeta + nDims/2*logU;
            
            % This is what Archameau says to use. It integrates out the
            % latent params
            y = gammaln((nDims + self.nu)/2) - gammaln(self.nu/2) - nDims/2*log(self.nu) + 1/2*lnDetGammaTilde - (nDims + self.nu)/2*log(1 + 1./self.nu*term(:) + nDims/self.model.meanBeta/self.nu);
            
            
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties for prtBrvMvn use
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        model = prtBrvMvnHierarchy;
        nu
        
        uA
        uB
    end    
    
    properties (Hidden)
        initFudgeFactor = 0.9; % Between zero and 1, probably > 0.9
        initModifiyPrior = true;
    end
    
    methods
        function self = prtBrvMvt(varargin)
            if nargin < 1
                return
            end
            self = constructorInputParse(self,varargin{:});
        end
    end
    
    methods (Hidden)
        function x = parseInputData(self,x) %#ok<INUSL>
            if isnumeric(x)
                return
            elseif prtUtilIsSubClass(class(x),'prtDataSetBase')
                x = x.getObservations();
            else 
                error('prt:prtBrvMvt:parseInputData','prtBrvMvt requires a prtDataSet or a numeric 2-D matrix');
            end
        end
    end
end
