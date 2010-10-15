% xxx Need Help xxx
% PRTRVMVN  PRT Random Variable Object - Multi-Variate Normal
%
% Syntax:
%   R = prtRvMixture
%   R = prtRvMixture(RVs)
%   R = prtRvMixture(nComponents,baseRV)
%   R = prtRvMixture(RVs,mixingWeights)
%
% Methods:
%   mle
%   pdf
%   logPdf
%   cdf
%   draw
%   kld
%
% Inherited Methods
%   ezPdfPlot
%   ezCdfPlot


classdef prtRvMixture < prtRv
    properties
        components
        mixingProportions = prtRvMultinomial;
    end
    
    properties (Dependent = true)
        nComponents
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
    end
    
    properties (Hidden = true)
        postMaximizationFunction = @(R)R;
        
        learningResults
        learningMaxIterations = 1000;
        learningConvergenceThreshold = 1e-6;
        learningApproximatelyEqualThreshold = 1e-4;
    end
    
    methods
        function R = prtRvMixture(varargin)
            R.name = 'Mixture Random Variable';
            R = constructorInputParse(R,varargin{:});
        end
    end
    
    
    
    % Set methods
    methods
        function R = set.mixingProportions(R,weights)
            if ~isempty(weights) % For loading and saving
                assert(isa(weights,'prtRvMultinomial'),'Mixing weights must be a prtRvMultinomial')
            end
            R.mixingProportions = weights;
        end
        
        function R = set.components(R,CompArray)
            if ~isempty(CompArray)
                assert(isa(CompArray(1),'prtRv'),'components must be a prtRv');
                assert(prtUtilIsMethodIncludeHidden(CompArray(1),'weightedMle'),'The %s class is not capable of mixture modeling as it does not have a weightedMle method.',class(CompArray(1)));
                assert(isvector(CompArray),'components must be an array of prtRv objects');
            end
            
            R.components = CompArray;
        end
    end
    
    methods
        
        function R = mle(R,X)
            
            membershipMat = initialComponentMembership(R,X);
            
            pLogLikelihood = nan;
            R.learningResults.iterationLogLikelihood = [];
            for iteration = 1:R.learningMaxIterations
                
                R = maximizeParameters(R,X,membershipMat);
                
                R = R.postMaximizationFunction(R);
                
                membershipMat = expectedComponentMembership(R,X);
                
                cLogLikelihood = sum(logPdf(R,X));
                
                R.learningResults.iterationLogLikelihood(end+1) = cLogLikelihood;
                
                if abs(cLogLikelihood - pLogLikelihood)*abs(mean([cLogLikelihood  pLogLikelihood])) < R.learningConvergenceThreshold
                    break
                elseif (pLogLikelihood - cLogLikelihood) > R.learningApproximatelyEqualThreshold
                    warning('prtRvMixture:learning','Log-Likelihood has decreased!!! Exiting.');
                    break
                else
                    pLogLikelihood = cLogLikelihood;
                end
            end
            R.learningResults.nIterations = iteration;
            R.learningResults.logLikelihood = cLogLikelihood;

        end
        
        function [y, componentPdf] = pdf(R,X)
            assert(size(X,2) == R.nDimensions,'Incorrect data dimensionality for this prtRvMixture');
            
            [logy, componentLogPdf] = logPdf(R,X);
            
            y = exp(logy);
            if nargout > 1
                componentPdf = exp(componentLogPdf);
            end
        end 
        
        function [logy, componentLogPdf] = logPdf(R,X)
            assert(size(X,2) == R.nDimensions,'Incorrect data dimensionality for this prtRvMixture');
            componentLogPdf = zeros(size(X,1),R.nComponents);
            
            logWeights = log(R.mixingProportions.probabilities);
            for iComp = 1:R.nComponents;
                componentLogPdf(:,iComp) = logPdf(R.components(iComp),X)+logWeights(iComp);
            end
            
            logy = prtUtilSumExp(componentLogPdf')';
        end 
        
        function y = cdf(R,X)
            assert(size(X,2) == R.nDimensions,'Incorrect data dimensionality for this prtRvMixture');
            
            y = zeros(size(X,1),1);
            for iComp = 1:R.nComponents;
                y = y + cdf(R.components(iComp),X)*R.mixingProportions.probabilities(iComp);
            end
        end
        
        function [vals, components] = draw(R,N)
            assert(R.isValid,'prtRvMixture must be valid before it can be drawn from.')
            
            components = drawIntegers(R.mixingProportions,N);
            
            vals = zeros(N,R.nDimensions);
            for iComp = 1:R.nComponents
                cSamples = components==iComp;
                cNSamples = sum(cSamples);
                vals(cSamples,:) = draw(R.components(iComp),cNSamples);
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
        function val = isValid(R)
            if ~isempty(R.components)
                % This should work but doesnt for nested mixtures
                val = all(isValid(R.components)) && ~isempty(R.mixingProportions);
            else
                val = false;
            end
        end
    end
    
    methods (Hidden = true)
        function val = plotLimits(R)
            if R.isValid
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
                error('prtRvMixture:plotLimits','Plotting limits can not be determined for this prtRvMixture because it is not yet valid.')
            end
        end

    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % These Methods are private helper functions for mle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = 'private')
        
        function initMembershipMat = initialComponentMembership(R,X)
            initMembershipMat = initializeMixtureMembership(R.components,X);
        end
        
        function membershipMat = expectedComponentMembership(R,X)

            [logy, membershipMat] = logPdf(R,X); %#ok
            
            membershipMat = exp(bsxfun(@minus,membershipMat,prtUtilSumExp(membershipMat')'));
        end
        
        function R = maximizeParameters(R,X,membershipMat)
            for iComp = 1:R.nComponents
                R.components(iComp) = weightedMle(R.components(iComp),X,membershipMat(:,iComp));
            end
            R.mixingProportions = R.mixingProportions.mle(membershipMat);
            
        end
    end 
end