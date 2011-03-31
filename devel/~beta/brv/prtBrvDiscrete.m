classdef prtBrvDiscrete < prtBrvObsModel & prtBrvVbOnlineObsModel
    properties
        name = 'Discrete';
        
        model = prtBrvDiscretePrior
    end
    
    methods
        function obj = prtBrvDiscrete(varargin)
            if nargin < 1
                return
            end
            obj.model = prtBrvDiscretePrior(varargin{1});
        end        
        
        function val = nDimensions(obj)
            val = length(obj.model.lambda);
        end
        
        function y = conjugateVariationalAverageLogLikelihood(obj, x)
            y = sum(bsxfun(@times,x,psi(obj.model.lambda)-psi(sum(obj.model.lambda))),2);
        end
        
        function val = expectedLogMean(obj)
            val = psi(obj.model.lambda) - psi(sum(obj.model.lambda));
        end
        
        function [phiMat, priorObjs] = mixtureInitialize(objs, priorObjs, x)
            
            nStates = length(objs);
            
            minFrames = nStates*10;
            minFrameLength = 10;
            frameLength = floor(mean([floor(size(x,1)./minFrames),minFrameLength]));
            frameInds = buffer((1:size(x,1))',frameLength);
            
            nFrames = size(frameInds,2);
            frameClusteringX = zeros(nFrames,length(priorObjs(1).model.lambda));
            for iFrame = 1:nFrames
                cFrameInds = frameInds(frameInds(:,iFrame)>0,iFrame);
                frameClusteringX(iFrame,:) =  mean(x(cFrameInds,:),1);
            end
            
            prune = any(isnan(frameClusteringX),2);
            frameClusteringX(prune,:) = repmat(mean(frameClusteringX(~prune,:)),sum(prune),1);
            
            [classMeans, Yout] = prtUtilKmeans(frameClusteringX,nStates,'handleEmptyClusters','random'); %#ok<ASGLU>
            
            [unwanted, sortedInds] = sort(hist(Yout,1:nStates),'descend'); %#ok<ASGLU>
            dsMat = bsxfun(@eq,Yout,sortedInds);
            
            phiMat = kron(dsMat,ones(frameLength,1));
            phiMat = phiMat(1:size(x,1),:);

        end
        
        function obj = weightedConjugateUpdate(obj, priorObj, x, weights)
            obj.model.lambda = priorObj.model.lambda + sum(bsxfun(@times,x,weights),1);
        end
        
        function kld = conjugateKld(obj, priorObj)
            kld = prtRvUtilDirichletKld(obj.model.lambda,priorObj.model.lambda);
        end
        
        function x = posteriorMeanDraw(obj, n, varargin)
            if nargin < 2
                n = 1;
            end
            
            probs = obj.model.lambda./sum(obj.model.lambda);
            x = prtRvUtilRandomSample(probs, n);
        end
        
        function s = posteriorMeanStruct(obj)
            s.probabilities = obj.model.lambda./sum(obj.model.lambda);
        end
        
        function model = modelDraw(obj)
            model.probabilities = prtRvUtilDirichletRnd(obj.model.lambda);
        end
        
        function plot(objs)
            
            nComponents = length(objs);
            
            cMap = jet(128);
            colors = cMap(gray2ind(mat2gray(1:nComponents),size(cMap,1))+1,:);
            
            
            nDimensions = length(objs(1).model.lambda);
            
            lambdaMat = zeros([nComponents, nDimensions]);
            for s = 1:nComponents
                lambdaMat(s,:) = objs(s).model.lambda;
            end
                
            probMat = bsxfun(@rdivide,lambdaMat,sum(lambdaMat,2));
            for iSource = 1:size(probMat,1)
                for jSym = 1:size(probMat,2)
                    cSize = sqrt(probMat(iSource,jSym));
                    if cSize > 0
                        rectangle('Position',[jSym-cSize/2, iSource-cSize/2, cSize, cSize],'Curvature',[1 1],'FaceColor',colors(iSource,:),'EdgeColor',colors(iSource,:));
                    end
                end
            end
            set(gca,'YDir','Rev');
            title('Observations Prob.')
            xlabel('Observations')
            ylabel('Component')
            xlim([0 size(probMat,2)+1])
            ylim([0 size(probMat,1)+1])

        end
        
        function [obj, training] = vbOnlineWeightedUpdate(obj, x, weights, lambda, D) %#ok<INUSL>
            S = size(x,1);
            
            obj.model.lambda = obj.model.lambda*lambda + D/S*sum(x,1)*(1-lambda);
            
            training = struct([]);
        end
    end
end