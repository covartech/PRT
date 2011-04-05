classdef prtBrvMvn < prtBrvObsModel & prtBrvVbOnlineObsModel
    properties
        name = 'MVN';
        
        model = prtBrvMvnPrior
    end
    
    properties (Hidden)
        initFuzzyFactor = 1; % Between zero and 1, probably > 0.9
        initModifiyPrior = true;
    end
    
    methods
        function obj = prtBrvMvn(varargin)
            if nargin < 1
                return
            end
            obj.model = prtBrvMvnPrior(varargin{1});
        end
        
        function val = nDimensions(obj)
            val = length(obj.model.meanMean);
        end
        
        function y = conjugateVariationalAverageLogLikelihood(obj, x)
            nDims = size(x,2);
            
            %lnDetGammaTilde = sum(psi((Q.covNu + 1 - (1:nDims)')./2)) - log(det(Q.covPhi)) + nDims*log(2);
            %lnDetGammaTilde = sum(psi((Q.covNu + 1 - (1:nDims)')./2)) - logdet(Q.covPhi) - nDims*log(2);
            innerPsiTerm = (obj.model.covNu + 1 - (1:nDims)')./2;
            lnDetGammaTilde = sum(psi(innerPsiTerm)) - prtUtilLogDet(obj.model.covPhi) - nDims*log(2);

            xDemeaned = bsxfun(@minus,x,obj.model.meanMean);
            
            T = chol(obj.model.covPhi/obj.model.covNu);
            xNorm = xDemeaned / T;
            term = sum(xNorm.^2,2);
            
            y = 1/2*lnDetGammaTilde - 1/2*term(:) - nDims/2/obj.model.meanBeta;

        end
        
        function [phiMat, priorObjs] = mixtureInitialize(objs, priorObjs, x) % Vector of objects
            
            nClusters = length(objs);
            
            fuzzyFactor = objs(1).initFuzzyFactor;
            modifyPrior = objs(1).initModifiyPrior;
            
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

            if modifyPrior
                oldCovPhi = priorObjs(1).model.covPhi;
                
                % Gives problems sometimes
                covMat = zeros([size(x,2) size(x,2) nClusters]);
                for iCluster = 1:nClusters
                    cX = x(phiMat(:,iCluster)>0,:);
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
        
        function obj = weightedConjugateUpdate(obj, priorObj, x, weights)
            N_bar = sum(weights);
            
            % We want to do simply this
            %muBar = 1./N_bar.*sum(bsxfun(@times,X,weights));
            % but to avoid divide by zero warnings we do this.
            muBar = sum(bsxfun(@times,x,weights),1);
            if N_bar > 0
                muBar = muBar./N_bar;
            else
                muBar = zeros(1,size(x,2));
            end
            
            xWeightedDemeaned = bsxfun(@times,bsxfun(@minus,x,muBar),sqrt(weights));
            sigmaBar = xWeightedDemeaned'*xWeightedDemeaned;
            
            obj.model = priorObj.model;
            obj.model.meanBeta = N_bar + priorObj.model.meanBeta;
            obj.model.meanMean = (muBar.*N_bar + priorObj.model.meanMean.*priorObj.model.meanBeta) ./ (N_bar + priorObj.model.meanBeta);
            obj.model.covNu = N_bar + priorObj.model.covNu;
            obj.model.covPhi = sigmaBar + N_bar.*priorObj.model.meanBeta.*(muBar - priorObj.model.meanMean)'*(muBar - priorObj.model.meanMean)./(N_bar + priorObj.model.meanBeta) + priorObj.model.covPhi;
        end
        
        function kld = conjugateKld(obj, priorObj)
            kld = prtRvUtilMvnWishartKld(obj.model.meanBeta,...
                obj.model.covNu,obj.model.meanMean,obj.model.covPhi,...
                priorObj.model.meanBeta,priorObj.model.covNu,...
                priorObj.model.meanMean,priorObj.model.covPhi);
        end
        
        function x = posteriorMeanDraw(obj, n, varargin)
            if nargin < 2
                n = 1;
            end
            x = prtRvUtilMvnDraw(obj.model.mean,obj.model.covariance, n);
        end
        
        function s = posteriorMeanStruct(obj)
            nDimensions = length(obj.model.meanMean);

            s.mean = obj.model.meanMean;
            s.covariance = 1/obj.model.covNu .* obj.model.covPhi;
            s.degreesOfFreedom = obj.model.covNu + 1 - nDimensions;
        end
        
        function model = modelDraw(obj)
            model.covariance = iwishrnd(obj.model.covPhi,obj.model.covNu); %#STATS
            model.mean = prtRvUtilMvnDraw(obj.model.meanMean,model.covariance/obj.model.meanBeta);
        end
        
        function plot(objs)
            
            nComponents = length(objs);
            
            colors = prtPlotUtilClassColors(nComponents);
            
            nDimensions = objs(1).nDimensions;
            
            if nDimensions < 3
                meanMat = zeros(nDimensions,nComponents);
                covMat = zeros([nDimensions nDimensions nComponents]);
                for s = 1:nComponents
                    meanMat(:,s) = objs(s).model.meanMean;
                    covMat(:,:,s) = objs(s).model.covPhi./objs(s).model.covNu;
                end
            end
                
            if nDimensions == 1
                maxVar = max(arrayfun(@(S)S.model.covPhi/S.model.covNu,objs));
                meanPdfSamples = linspace(min(meanMat)-sqrt(maxVar)*2,max(meanMat)+sqrt(maxVar)*2,1000)';
                for s = 1:nComponents
                    h = plot(meanPdfSamples,exp(prtRvUtilMvnLogPdf(meanPdfSamples,meanMat(:,s),1/objs(s).model.covNu.*objs(s).model.covPhi)));
                    set(h,'color',colors(s,:));
                    hold on
                end
                v = axis;
                ylim([0 v(4)]);
                
            elseif nDimensions == 2
                for s = 1:nComponents
                    ellipseHandle = prtPlotUtilMvnEllipse(meanMat(:,s)',squeeze(covMat(:,:,s)));
                    set(ellipseHandle,'Color',colors(s,:));
                    hold on
                    plot(meanMat(1,s),meanMat(2,s),'x','color',colors(s,:),'markerSize',8);
                end
                hold off;
                title('Posterior Mean Source PDFs');
                
            else
    
                for s = 1:nComponents
                    cMean = objs(s).model.meanMean;
                    cCov = objs(s).model.covPhi./objs(s).model.covNu;
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
        
        function [obj, training] = vbOnlineWeightedUpdate(obj, priorObj, x, weights, lambda, D)
            S = size(x,1);
            prevObj = obj;
            
            muBar = sum(bsxfun(@times,x,weights),1);
            
            N_bar = sum(weights,1)*D/S;
            
            if sum(weights) > 0
                muBar = muBar./sum(weights,1);
            else
                muBar = zeros(1,size(x,2));
            end
            
            xWeightedDemeaned = bsxfun(@times,bsxfun(@minus,x,muBar),sqrt(weights));
            sigmaBar = xWeightedDemeaned'*xWeightedDemeaned;
            
            obj.model = prevObj.model;
            obj.model.meanBeta = lambda*(N_bar + priorObj.model.meanBeta)  + (1-lambda)*prevObj.model.meanBeta;
            obj.model.meanMean = ((muBar.*N_bar + priorObj.model.meanMean.*priorObj.model.meanBeta) ./ (N_bar + priorObj.model.meanBeta))*lambda + (1-lambda)*prevObj.model.meanMean;
            % (lambda*(muBar*N_bar + priorObj.model.meanMean*priorObj.model.meanBeta) + (1-lambda)*prevObj.model.meanMean.*prevObj.model.meanBeta) ./ obj.model.meanBeta;
            obj.model.covNu = lambda*(N_bar + priorObj.model.covNu) + (1-lambda)*prevObj.model.covNu;
            obj.model.covPhi = (sigmaBar*D/S + N_bar.*priorObj.model.meanBeta.*(muBar - priorObj.model.meanMean)'*(muBar - priorObj.model.meanMean)./(N_bar + priorObj.model.meanBeta) + priorObj.model.covPhi)*lambda + (1-lambda)*prevObj.model.covPhi;
            
            training = struct([]);
        end
    end
end