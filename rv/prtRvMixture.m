classdef prtRvMixture < prtRv & prtRvMemebershipModel
    % prtRvMixture  Mixture Random Variable
    %
    %   RV = prtRvMixture creates a prtRvMixture object with empty
    %   mixingProportions and components. These parameters can be set
    %   manually or by calling the MLE method.     
    %
    %   The prtRvMixture class is used to implement mixtures of prtRvs. The
    %   base prtRv object must implement the weightedMle() method.
    %
    %   RV = prtRvMixture(PROPERTY1, VALUE1,...) creates a prtRvMixture
    %   object RV with properties as specified by PROPERTY/VALUE pairs.
    %
    %   A prtRvMixture object inherits all properties from the prtRv class.
    %   In addition, it has the following properties:
    %
    %   components        - A vector of prtRv objects. The length of the
    %                       array specifies the number of components in the
    %                       mixture. The component RV objects must all have
    %                       the same dimensionality.
    %   mixingProportions - A discrete probability vector, representing the
    %                       probability of each component in the mixture.
    %
    %  A prtRvMixture object inherits all methods from the prtRv class.
    %  The MLE method can be used to estimate the distribution parameters
    %  from data.
    %
    %  Examples:
    %       ds = prtDataGenOldFaithful;      % Load a data set
    %  
    %       % Create a prtRvMixture object consistig of 2 multivariate
    %       % normal objects
    %       rv = prtRvMixture('components',repmat(prtRvMvn,1,2));
    %
    %       rv = mle(rv,ds);                 % Compute the ML estimate
    %       plotPdf(rv);                     % Plot the estimated PDF
    %       hold on;
    %       plot(ds);                        % Overlay the original data
    %
    %   See also: prtRv, prtRvMvn, prtRvGmm, prtRvMultinomial,
    %   prtRvUniform, prtRvUniformImproper, prtRvVq

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
    properties (SetAccess = private)

        name = 'Mixture Random Variable'
        nameAbbreviation = 'RVMix';
    end
    
    properties (SetAccess = protected)
        isSupervised = false;
        isCrossValidateValid = true;
    end
    
    properties
        components  % A vector of the components
        minimumComponentMembership = 0;
    end
    
    properties (Dependent = true)
        mixingProportions % The mixing proportions
        nComponents       % The number of components
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
    end
    
    properties (SetAccess = 'private', GetAccess = 'private', Hidden=true)
        mixingProportionsDepHelper = prtRvMultinomial;
    end
    
    properties (Hidden = true)
        postMaximizationFunction = @(R)R;
        
        learningResults
        learningMaxIterations = 1000;
        learningConvergenceThreshold = 1e-6;
        learningApproximatelyEqualThreshold = 1e-4;
        
        learningMembershipMatrixInternal = []; % This will be used if a mixture is used in a membership model (like an HMM).
    end
    
    methods
        function R = prtRvMixture(varargin)
            R = constructorInputParse(R,varargin{:});
        end
    end
    
    
    
    % Set methods
    methods
        function R = set.mixingProportions(R,weights)
            if isnumeric(weights)
                if isvector(weights) && prtUtilApproxEqual(sum(weights),1,sqrt(eps)*sqrt(length(weights)))
                    weights = prtRvMultinomial('probabilities',weights(:)');
                else
                    error('prt:prtRvMixture','prtRvMixture mixinigProportions must be a vector of probabilities (that sum to 1) or a prtRvMultinomial');
                end
            end
            
            if ~isempty(weights) % For loading and saving
                assert(isa(weights,'prtRvMultinomial'),'prtRvMixture mixinigProportions must be a vector of probabilities (that sum to 1) or a prtRvMultinomial')
            end
            
            if R.nComponents > 0
                nSpecifiiedComponents = R.nComponents;
                assert(weights.nCategories == nSpecifiiedComponents,'The length of these mixingProportions does not mach the number of components of this prtRvMixture.')
            end
            
            R.mixingProportionsDepHelper = weights;
        end
        function val = get.mixingProportions(R)
            val = R.mixingProportionsDepHelper;

            if ~isValid(val)
                val = [];
            end
        end
        function R = set.components(R,CompArray)
            if ~isempty(CompArray)
                assert(isa(CompArray(1),'prtRv') && isa(CompArray(1),'prtRvMemebershipModel'),'components must be a prtRv and inherit from prtRvMemebershipModel');
                assert(isvector(CompArray),'components must be an array of prtRv objects');
            end
            
            R.components = CompArray;
        end
    end
    
    methods
        
        function R = mle(R,X)
            
            X = R.dataInputParse(X); % Basic error checking etc
            
            [R,membershipMat] = initialComponentMembership(R,X);

            [R,membershipMat] = removeComponents(R, X, membershipMat);
            
            pLogLikelihood = nan;
            R.learningResults.iterationLogLikelihood = [];
            for iteration = 1:R.learningMaxIterations
                
                R = maximizeParameters(R,X,membershipMat);
                
                R = R.postMaximizationFunction(R);
                
                membershipMat = expectedComponentMembership(R,X);
                
                [R, membershipMat, componentsRemoved] = removeComponents(R, X, membershipMat);
                
                cLogLikelihood = sum(logPdf(R,X));
                
                R.learningResults.iterationLogLikelihood(end+1) = cLogLikelihood;
                
                if ~componentsRemoved
                    % No components removed proceed as normal
                    
                    if abs(cLogLikelihood - pLogLikelihood)*abs(mean([cLogLikelihood  pLogLikelihood])) < R.learningConvergenceThreshold
                        break
                    elseif (pLogLikelihood - cLogLikelihood) > R.learningApproximatelyEqualThreshold
                        warning('prt:prtRvMixture:learning','Log-Likelihood has decreased!!! Exiting.');
                        break
                    else
                        pLogLikelihood = cLogLikelihood;
                    end
                else
                    % Components were removed this iteration do not exit.
                    pLogLikelihood = cLogLikelihood;
                end
            end
            R.learningResults.nIterations = iteration;
            R.learningResults.logLikelihood = cLogLikelihood;
            
        end
        
        function [y, componentPdf] = pdf(R,X)
            X = R.dataInputParse(X); % Basic error checking etc
            
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
            
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'PDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            [logy, componentLogPdf] = logPdf(R,X);
            
            y = exp(logy);
            if nargout > 1
                componentPdf = exp(componentLogPdf);
            end
        end
        
        function [logy, componentLogPdf] = logPdf(R,X)
            X = R.dataInputParse(X); % Basic error checking etc
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
            
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'LOGPDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            componentLogPdf = zeros(size(X,1),R.nComponents);
            
            logWeights = log(R.mixingProportions.probabilities);
            for iComp = 1:R.nComponents;
                try
                    componentLogPdf(:,iComp) = logPdf(R.components(iComp),X)+logWeights(iComp);
                catch  %#ok<CTCH>
                    error('prt:prtRvMixture:logPdf','An error was encountered while calculating the logPdf of component %d. Perhaps the number of components is too high.',iComp)
                end
            end
            
            logy = prtUtilSumExp(componentLogPdf')';
        end
        
        function y = cdf(R,X)
            X = R.dataInputParse(X); % Basic error checking etc
            
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
            
            y = zeros(size(X,1),1);
            for iComp = 1:R.nComponents;
                y = y + cdf(R.components(iComp),X)*R.mixingProportions.probabilities(iComp);
            end
        end
        
        function [vals, components] = draw(R,N)
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'DRAW cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            components = drawIntegers(R.mixingProportions,N);
            
            vals = zeros(N,R.nDimensions);
            for iComp = 1:R.nComponents
                cSamples = components==iComp;
                cNSamples = sum(cSamples);
                if cNSamples > 0
                    vals(cSamples,:) = draw(R.components(iComp),cNSamples);
                end
            end
        end
    end
    
    % Get Methods
    methods
        function val = get.nDimensions(R)
            if R.nComponents > 0
                val = R.components(1).nDimensions;
            else
                val = [];
            end
        end
        
        function val = get.nComponents(R)
            val = length(R.components);
        end
    end
    
    methods (Hidden=true)
        function [val, reasonStr] = isValid(R)
            if numel(R) > 1
                val = false(size(R));
                for iR = 1:numel(R)
                    [val(iR), reasonStr] = isValid(R(iR));
                end
                return
            end
            
            
            if ~isempty(R.components)
                val = all(isValid(R.components)) && R.mixingProportions.isValid;
            else
                val = false;
            end
            
            if val
                reasonStr = '';
            else
                unsetComps = isempty(R.components);
                invalidComps = ~all(isValid(R.components));
                badProbs = ~R.mixingProportions.isValid;
                
                if unsetComps && ~badProbs
                    reasonStr = 'because components has not been set';
                elseif unsetComps && badProbs
                    reasonStr = 'because components and mixingProportions have not been set';
                elseif ~unsetComps && badProbs && invalidComps
                    reasonStr = 'because mixingProportions have not been set and some components are not yet valid';
                elseif ~unsetComps && ~badProbs && invalidComps
                    reasonStr = 'because some components are not yet valid';
                elseif ~unsetComps && badProbs && ~invalidComps
                    reasonStr = 'because mixingProportions have not been set';
                else
                    reasonStr = 'because of an unknown reason';
                end
            end
            
        end
    end
    
    methods (Hidden = true)
        function val = plotLimits(R)
            [isValid, reasonStr] = R.isValid;
            if isValid
                allPlotLimits = zeros(R.nComponents,R.nDimensions*2);
                for iComp = 1:R.nComponents
                    try
                        allPlotLimits(iComp,:) = R.components(iComp).plotLimits();
                    catch msg %#ok
                        cval = [Inf -Inf];
                        allPlotLimits(iComp,:) = repmat(cval,1,R.nDimensions);
                    end
                end
                
                val = zeros(1,2*R.nDimensions);
                val(1:2:R.nDimensions*2-1) = min(allPlotLimits(:,(1:2:R.nDimensions*2-1)),[],1);
                val(2:2:R.nDimensions*2) = max(allPlotLimits(:,(2:2:R.nDimensions*2)),[],1);
            else
                error('prtRvMixture:plotLimits','Plotting limits can not be determined for this prtRvMixture. It is not yet valid %s',reasonStr)
            end
        end
    end
    
    methods % for prtRvMembershipModel (so that we can use mixtures in HMMs)
        function self = weightedMle(self, x, weights)
            
            realMembershipMatrix =  bsxfun(@times, self.learningMembershipMatrixInternal, weights);
            
            self = self.maximizeParameters( x, realMembershipMatrix);
            
            self.learningMembershipMatrixInternal = self.expectedComponentMembership(x);
            
            %[R, membershipMat, componentRemoved, componentsToRemove] = removeComponents(R,X,membershipMat)
        end
        
        function [Rs, initMembershipMat] = initializeMixtureMembership(Rs,X)
            
            learningInitialMembershipFactor = 0.9;
            
            nSubComponents = zeros(length(Rs),1);
            for iR = 1:length(Rs)
                nSubComponents(iR) = Rs(iR).nComponents;
            end
            
            nTotalComponents = sum(nSubComponents);
            
            [classMeans,kmMembership] = prtUtilKmeans(X,nTotalComponents,'handleEmptyClusters','random'); %#ok<ASGLU>
            
            initMembershipMatBig = zeros(size(X,1),nTotalComponents);
            for iComp = 1:nTotalComponents
                initMembershipMatBig(kmMembership == iComp, iComp) = 1;
            end
            
            edgePoints = [0; cumsum(nSubComponents)];
            initMembershipMat = zeros(size(X,1), length(Rs));
            for iComp = 1:length(Rs)
                cMembershipMat = initMembershipMatBig(:,(edgePoints(iComp)+1):edgePoints(iComp+1));
                
                initMembershipMat(:,iComp) = sum(cMembershipMat,2);
                
                cMembershipMat = bsxfun(@rdivide,cMembershipMat, initMembershipMat(:,iComp));
                cMembershipMat = cMembershipMat*learningInitialMembershipFactor;
                cMembershipMat(cMembershipMat==0) = (1-learningInitialMembershipFactor)./(nSubComponents(iComp)-1);
                
                cMembershipMat(~isfinite(cMembershipMat)) = 1/nSubComponents(iComp);
                
                cMembershipMat = bsxfun(@rdivide,cMembershipMat, sum(cMembershipMat,2));
               
                Rs(iComp).learningMembershipMatrixInternal = cMembershipMat;
            end
            
            initMembershipMat = initMembershipMat*learningInitialMembershipFactor;
            initMembershipMat(initMembershipMat==0) = (1-learningInitialMembershipFactor)./(length(Rs)-1);
            
            % We should normalize this just in case the
            % learningInitialMembershipFactor was set poorly
            initMembershipMat = bsxfun(@rdivide,initMembershipMat,sum(initMembershipMat,2));
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % These Methods are private helper functions for mle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = 'private')
        
        function [R, initMembershipMat] = initialComponentMembership(R,X)
            [R.components, initMembershipMat] = initializeMixtureMembership(R.components,X);
        end
        
        function membershipMat = expectedComponentMembership(R,X)
            
            [logy, membershipMat] = logPdf(R,X); %#ok

            membershipMat = exp(bsxfun(@minus,membershipMat,prtUtilSumExp(membershipMat')'));
            
        end
        
        function R = maximizeParameters(R,X,membershipMat)
            temp = R.components;
            for iComp = 1:R.nComponents
                try
                    temp(iComp) = weightedMle(temp(iComp),X,membershipMat(:,iComp));
                catch  %#ok<CTCH>
                    error('prt:prtRvMixture:maximizeParameters','An error was encountered while fitting the parameters of component %d. Perhaps the number of components is too high.',iComp)
                end
            end
            R.components = temp;
            
            try
                R.mixingProportions = mle(prtRvMultinomial,membershipMat);
            catch  %#ok<CTCH>
                error('prt:prtRvMixture:maximizeParameters','An error was encountered while maximizing the parameters of the mixture. Perhaps the number of components is too high.')
            end
        end
    end
    methods (Hidden) %prtRvHmm wants this...  need a "friend" operator...
        function [R, membershipMat, componentRemoved, componentsToRemove] = removeComponents(R,X,membershipMat)
            nSamplesPerComponent = sum(membershipMat,1);
            componentsToRemove = nSamplesPerComponent < R.minimumComponentMembership;
            
            %Never remove ALL the components; if we try to do that, just
            %remove one
            if all(componentsToRemove) && isscalar(componentsToRemove)
                error('Attempt to remove the last remaining component in a mixture');
            end
            if all(componentsToRemove)
                componentsToRemove(nSamplesPerComponent > min(nSamplesPerComponent)) = false;
            end
            componentRemoved = any(componentsToRemove);
            
            if componentRemoved
                
                warning('prt:prtRvMixture:removeComponents','A component of this prtRvMixture had a responsibility below the threshold. This component has been removed from the model. %d components remain.',sum(~componentsToRemove));
                
                
                % One might assume we can do this. 
                % >> membershipMat = membershipMat(:,~componentsToRemove);
                % >> membershipMat = bsxfun(@rdivide,membershipMat,sum(membershipMat,2));
                % However, we may be removing a cluster that an observation
                % has a membership of 1. Therefore, the above would yield a
                % row of the membership matrix with NaNs.
                % Instead, we have to recalculate the membership matrix
                % from the remaining clusters. In order to do that though
                % we must update the mixing proportions first and then
                % after.
                R.components = R.components(~componentsToRemove);
                R.mixingProportions = prtRvMultinomial('probabilities',nSamplesPerComponent(~componentsToRemove)/sum(nSamplesPerComponent(~componentsToRemove)));
                
                % However if the components aren't yet valid (because this
                % is the first iteration) we have to deal with the NaNs.
                if R.components(1).isValid
                    membershipMat = expectedComponentMembership(R,X);
                else
                    membershipMat = membershipMat(:,~componentsToRemove);
                    
                    % When we renormalize it's possible that we create NaNs
                    % So we look for and fix this.
                    membershipMat = bsxfun(@rdivide,membershipMat,sum(membershipMat,2));
                    membershipMat(any(isnan(membershipMat),2),:) = 1/size(membershipMat,2);
                end
            end
        end
    end
end
