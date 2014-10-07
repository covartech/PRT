% PRTBRVMVB - PRT BRV Multivariate Binary Observation Model

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


classdef prtBrvMvb < prtBrv & prtBrvVbOnline & prtBrvVbMembershipModel & prtBrvVbOnlineMembershipModel
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties required by prtAction
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        name = 'Multi-varite Binary Bayesian Random Variable';
        nameAbbreviation = 'BRVMVB';
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
            %%%% FIXME
            % The true predictive here is a product of beta-binomials
            % Since that isn't implemented yet we use the average
            % variational loglikelihood
            
            y = conjugateVariationalAverageLogLikelihood(self, x);
        end
        
        function val = getNumDimensions(self)
            val = length(self.model.countOfOnes);
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
            betaKlds = zeros(1,length(obj.model.countOfOnes));
            for iDim = 1:length(obj.model.countOfOnes)
                betaKlds(iDim) = prtRvUtilDirichletKld([obj.model.countOfZeros(iDim) obj.model.countOfOnes(iDim)],[priorObj.model.countOfZeros(iDim) priorObj.model.countOfOnes(iDim)]);
            end
            
            kld = sum(betaKlds);
        end
        
        function s = posteriorMeanStruct(obj)
            s.probabilities = obj.model.countOfOnes./(obj.model.countOfOnes + obj.model.countOfZeros);
        end
        
        function plotCollection(objs,colors)
            
            nComponents = length(objs);
            
            if nargin < 2
                colors = prtPlotUtilClassColors(nComponents);
            end
            
            countOfOnesMat = cell2mat(arrayfun(@(c)c.model.countOfOnes,objs,'uniformOutput',false));
            countOfZerosMat = cell2mat(arrayfun(@(c)c.model.countOfZeros,objs,'uniformOutput',false));
            
            probMat = countOfOnesMat ./ (countOfOnesMat + countOfZerosMat);
            
            h = plot(probMat');
            
            for iLine = 1:length(h)
                set(h(iLine),'color',colors(iLine,:));
            end
            title('Posterior Mean Probabilities')
            ylim([0 1])
            xlim([1 size(probMat,2)])
            
        end
        
        function val = plotLimits(self)
            val = [1 self.nDimensions 0 1];
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
        
        function [phiMat, priorObjs] = collectionInitialize(objs, priorObjs, X) % Vector of objects
            
            learningInitialMembershipFactor = objs(1).initFudgeFactor;
            
            [classMeans,kmMembership] = prtUtilKmeans(X,length(objs),'handleEmptyClusters','random','distanceMetricFn',@prtDistanceHamming,'maxIterations',100,'logicalMeans',true); %#ok<ASGLU>
            
            phiMat = zeros(size(X,1),length(objs));
            for iComp = 1:length(objs)
                phiMat(kmMembership == iComp, iComp) = learningInitialMembershipFactor;
            end
            phiMat(phiMat==0) = (1-learningInitialMembershipFactor)./(length(objs)-1);
            
            % We should normalize this just in case the
            % learningInitialMembershipFactor was set poorly
            phiMat = bsxfun(@rdivide,phiMat,sum(phiMat,2));
        
        end
        
        function obj = weightedConjugateUpdate(obj, priorObj, x, weights)
            
            x = obj.parseInputData(x);
            priorObj = priorObj.initialize(x);
            
            if nargin < 4 || isempty(weights)
                weights = ones(size(x,1),1);
            end
            
            obj.model.countOfOnes = sum(bsxfun(@times,x,weights)) + priorObj.model.countOfOnes;
            
            obj.model.countOfZeros = sum(bsxfun(@times,~x,weights)) + priorObj.model.countOfZeros;
            
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
        function y = conjugateVariationalAverageLogLikelihood(obj, x)

            [logProb0, logProb1] = obj.expectedValueLogProbabilities;
            
            y = sum(bsxfun(@times,x,logProb1) + bsxfun(@times,~x,logProb0),2);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrvVbOnlineMembershipModel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    methods
        function obj = vbOnlineInitialize(obj, x) %#ok<INUSD>
            
            randDraw = (rand(1,obj.nDimensions)>0.5);
            
            obj.model.countOfOnes = randDraw+0.5;
            obj.model.countOfZeros  = (1-randDraw) + 0.5;
        end
        
        function [self, training] = vbOnlineUpdate(self, priorObj, x, lambda, D, prevObj)
            x = self.parseInputData(x);
            [self, training] = vbOnlineWeightedUpdate(self, priorObj, x, ones(size(x,1),1), lambda, D, prevObj);
        end
        
        function [obj, training] = vbOnlineWeightedUpdate(obj, priorObj, x, weights, lambda, D, prevObj)
            x = obj.parseInputData(x);
            
            S = size(x,1);
            
            if nargin < 4 || isempty(weights)
                weights = ones(size(x,1),1);
            end
            
            obj.model.countOfOnes = (D/S*sum(bsxfun(@times,x,weights)) + priorObj.model.countOfOnes)*lambda + prevObj.model.countOfOnes*(1-lambda);
            obj.model.countOfZeros = (D/S*sum(bsxfun(@times,~x,weights)) + priorObj.model.countOfZeros)*lambda + prevObj.model.countOfZeros*(1-lambda);
            
            training = struct([]);
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties for prtBrvMvb use
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        model = prtBrvMvbHierarchy;
    end    
    
    properties (Hidden)
        initFudgeFactor = 1; % Between zero and 1, probably > 0.9
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrvMvb use
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function self = prtBrvMvb(varargin)
            if nargin < 1
                return
            end
            self = constructorInputParse(self,varargin{:});
        end
        
        function [logProb0, logProb1] = expectedValueLogProbabilities(obj)
            psi1 = psi(obj.model.countOfOnes);
            psi0 = psi(obj.model.countOfZeros);

            psiSum = psi(obj.model.countOfOnes+obj.model.countOfZeros);
            
            logProb1 = psi1 - psiSum;
            logProb0 = psi0 - psiSum;
        end
        
        function model = modelDraw(obj)
            model.probabilities = zeros(1,length(obj.model.countOfOnes));
            for iDim = 1:length(obj.model.countOfOnes)
                model.probabilities(iDim) = prtRvUtilDirichletRnd([obj.model.countOfZeros(iDim) obj.model.countOfOnes(iDim)]);
            end
        end
    end
    
    methods (Hidden)
        function x = parseInputData(self,x) %#ok<MANU>
            if isnumeric(x) || islogical(x)
                return
            elseif prtUtilIsSubClass(class(x),'prtDataSetBase')
                x = x.getObservations();
            else 
                error('prt:prtBrvMvb:parseInputData','prtBrvMvb requires a prtDataSet or a numeric 2-D matrix');
            end
        end
    end
end
