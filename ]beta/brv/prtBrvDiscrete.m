% PRTBRVDISCRETE - PRT BRV Discrete Observation Model
%
% Constructor takes the dimesionality (number of unique outputs)
%
% Impliments all abstract properties and methods from prtBrvObsModel.
%
% Additional Properties:
%   model - prtBrvDiscreteHierarchy object that contains the parameters of
%       the prior/posterior
%
% Also inherits from prtBrvVbOnlineObsModel and therefore impliments
%   vbOnlineWeightedUpdate

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


classdef prtBrvDiscrete < prtBrv & prtBrvVbOnline & prtBrvVbMembershipModel & prtBrvVbOnlineMembershipModel & prtBrvMcmcMembershipModel

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties required by prtAction
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        name = 'Discrete Bayesian Random Variable';
        nameAbbreviation = 'BRVDisc';
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
            y = exp(predictiveLogPdf(self, x));
        end
        function y = predictiveLogPdf(self, x)
            
            % This is the variational approximation
            %y2 = conjugateVariationalAverageLogLikelihood(self, x);
            
            % This is a dirichlet-multinomial density
            xSum = sum(x,2);
            lambdaSum = sum(self.model.lambda);
            y = gammaln(lambdaSum)-gammaln(lambdaSum+xSum) + sum(bsxfun(@minus,gammaln(bsxfun(@plus,x,self.model.lambda(:)')),gammaln(self.model.lambda(:)')),2);
            
        end
        
        function val = getNumDimensions(self)
            val = length(self.model.lambda);
        end
    
        function self = initialize(self, x)
            x = self.parseInputData(x);
            if ~self.model.isValid
                self.model = self.model.defaultParameters(size(x,2));
            end
        end
        
        % Optional methods
        %------------------------------------------------------------------
        function kld = conjugateKld(obj, priorObj)
            kld = prtRvUtilDirichletKld(obj.model.lambda, priorObj.model.lambda);
        end
        
        function s = posteriorMeanStruct(obj)
            s.probabilities = obj.model.lambda./sum(obj.model.lambda);
        end
        
        function plotCollection(objs,colors)
            
            nComponents = length(objs);
            
            if nargin < 2
                cMap = jet(128);
                colors = cMap(gray2ind(mat2gray(1:nComponents),size(cMap,1))+1,:);
            end
            
            nDimensions = length(objs(1).model.lambda);
            
            lambdaMat = zeros([nComponents, nDimensions]);
            for s = 1:nComponents
                lambdaMat(s,:) = objs(s).model.lambda;
            end
            
            if size(lambdaMat,2) <= 10
                probMat = bsxfun(@rdivide,lambdaMat,sum(lambdaMat,2));
                for iSource = 1:size(probMat,1)
                    for jSym = 1:size(probMat,2)
                        cSize = sqrt(probMat(iSource,jSym));
                        if cSize > 0
                            %rectangle('Position',[jSym-cSize/2, iSource-cSize/2, cSize, cSize],'Curvature',[1 1],'FaceColor',colors(iSource,:),'EdgeColor',colors(iSource,:));
                            rectangle('Position',[jSym-cSize/2, iSource-cSize/2, cSize, cSize],'Curvature',[1 1],'FaceColor','none','EdgeColor',colors(iSource,:));
                        end
                    end
                end
                set(gca,'YDir','Rev','Xtick',1:size(probMat,2),'Ytick',1:size(probMat,1));
                title('Observations Prob.')
                xlabel('Observations')
                ylabel('Component')
                xlim([0 size(probMat,2)+1])
                ylim([0 size(probMat,1)+1])
            else
                probMat = bsxfun(@rdivide,lambdaMat,sum(lambdaMat,2));
                holdState = ishold;
                for iSource = 1:size(probMat,1)
                    plot(probMat(iSource,:),'color',colors(iSource,:),'linewidth',1);
                    hold on
                end
                if ~holdState
                    hold off
                end
                title('Observations Prob.')
                xlabel('Observations')
                ylabel('Probability')
                xlim([0 size(probMat,2)+1])
                %ylim([0 1])
            end
            
            
        end
        
        function val = plotLimits(self)
            val = [0 length(self(1).model.lambda)+1 0 length(self(1).model.lambda)+1];
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
        function [phiMat, priorObjs] = collectionInitialize(objs, priorObjs, x) % Vector of objects
            
            nStates = length(objs);
            xNorm = bsxfun(@rdivide,x,sum(x,2));
            [classMeans, Yout] = prtUtilKmeans(xNorm,nStates,'handleEmptyClusters','random'); %#ok<ASGLU>
            
%             minFrames = nStates*10;
%             minFrameLength = 10;
%             frameLength = floor(mean([floor(size(x,1)./minFrames),minFrameLength]));
%             frameInds = buffer((1:size(x,1))',frameLength);
%             
%             nFrames = size(frameInds,2);
%             frameClusteringX = zeros(nFrames,length(priorObjs(1).model.lambda));
%             for iFrame = 1:nFrames
%                 cFrameInds = frameInds(frameInds(:,iFrame)>0,iFrame);
%                 frameClusteringX(iFrame,:) =  mean(x(cFrameInds,:),1);
%             end
%             
%             prune = any(isnan(frameClusteringX),2);
%             frameClusteringX(prune,:) = repmat(mean(frameClusteringX(~prune,:)),sum(prune),1);
%             
%            [classMeans, Yout] = prtUtilKmeans(frameClusteringX,nStates,'handleEmptyClusters','random'); %#ok<ASGLU>
            
            [unwanted, sortedInds] = sort(hist(Yout,1:nStates),'descend'); %#ok<ASGLU>
            phiMat = bsxfun(@eq,Yout,sortedInds);
            
            %phiMat = kron(phiMat,ones(frameLength,1));
            %phiMat = phiMat(1:size(x,1),:);
        end
        
        function obj = weightedConjugateUpdate(obj, priorObj, x, weights)
            x = obj.parseInputData(x);
            %priorObj = priorObj.initialize(x);
            
            if isempty(weights)
                weights = ones(size(x,1),1);
            end
            obj.model.lambda = priorObj.model.lambda + sum(bsxfun(@times,x,weights),1);
        end
        
        function obj = conjugateUpdate(obj, priorObj, x)
            x = obj.parseInputData(x);
            
            obj.model.lambda = priorObj.model.lambda + sum(x,1);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrvVbMembershipModel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    methods
        function y = conjugateVariationalAverageLogLikelihood(obj, x)
            y = sum(bsxfun(@times,x,psi(obj.model.lambda)-psi(sum(obj.model.lambda))),2);
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrvVbOnlineMembershipModel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    methods
        function obj = vbOnlineInitialize(obj, x) %#ok<INUSD>
            randDraw = rand(1,obj.nDimensions);
            randDraw = randDraw./sum(randDraw);
            
            obj.model.lambda = randDraw;
        end
        
        function selfs = vbOnlineCollectionInitialize(selfs, x)
            for iComp = 1:length(selfs)
                cInd = prtRvUtilRandomSample(size(x,1));
                cX = x(cInd,:);
                cX = cX./sum(cX);
                
                selfs(iComp).model.lambda = cX;
            end
        end
        
        function [self, training] = vbOnlineUpdate(self, priorObj, x, lambda, D, prevObj)
            x = self.parseInputData(x);
            [self, training] = vbOnlineWeightedUpdate(self, priorObj, x, ones(size(x,1),1), lambda, D, prevObj);
        end
                
        function [obj, training] = vbOnlineWeightedUpdate(obj, priorObj, x, weights, lambda, D, prevObj) %#ok<INUSL>
            x = obj.parseInputData(x);
            
            S = size(x,1);
            
            obj.model.lambda = prevObj.model.lambda*(1-lambda) + (D/S*sum(x,1) + priorObj.model.lambda)*lambda;
            
            training = struct([]);
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods required by prtBrvMcmc
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function model = draw(self)
            model.probabilities = prtRvUtilDirichletDraw(self.model.lambda);
            %model.covariance = iwishrnd(self.model.covPhi,self.model.covNu); %#STATS
            %model.mean = prtRvUtilMvnDraw(self.model.meanMean,model.covariance/self.model.meanBeta);
        end
        function y = logPdfFromDraw(self, model, x)
            keyboard
        end
        function y = pdfFromDraw(self, model, x)
            keyboard
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties for prtBrvDiscrete use
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        model = prtBrvDiscreteHierarchy;
    end
    
    methods
        function self = prtBrvDiscrete(ds)
            if nargin < 1
                return
            end
            self = self.estimateParameters(ds);
        end        
        
        function val = expectedLogMean(obj)
            val = psi(obj.model.lambda) - psi(sum(obj.model.lambda));
        end
                
        function model = modelDraw(obj,n,varargin)
            if nargin < 2 || isempty(n)
                n = 1;
            end
            model.probabilities = prtRvUtilDirichletRnd(obj.model.lambda,n);
        end
    end
    
    
    methods (Hidden)
        function x = parseInputData(self,x) %#ok<MANU>
            if isnumeric(x)
                return
            elseif prtUtilIsSubClass(class(x),'prtDataSetBase')
                x = x.getObservations();
            else 
                error('prt:prtBrvDiscrete:parseInputData','prtBrvDiscrete requires a prtDataSet or a numeric 2-D matrix');
            end
        end
    end
end
