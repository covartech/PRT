classdef prtRvMixture < prtRv
    % prtRvMixture - Mixture Random Variable
    %   Forms a mixture of other prtRv objects of the same dimensionality.
    %
    %   The prtRvMixture class is used to implement the prtRvGmm class but
    %   can also be used to implement other mixtures. The base prtRv object
    %   must implement the weightedMle() method.
    %
    %   RV = prtRvMixture creates a prtRvMixture object with empty 
    %   mixingProportions and components. These parameters can be set
    %   manually or by calling the MLE method.
    %
    %   RV = prtRvMixture(PROPERTY1, VALUE1,...) creates a prtRvMixture
    %   object RV with properties as specified by PROPERTY/VALUE pairs.
    %
    %   A prtRvMixture object inherits all properties from the prtRv class.
    %   In addition, it has the following properties:
    %
    %   components        - A vector of prtRv objects. The length of the
    %                       array specifies the number of components in the
    %                       mixture
    %   mixingProportions - A discrete probability vector, representing the 
    %                       probability of each component in the mixture.
    %
    %  A prtRvMixture object inherits all methods from the prtRv class.
    %  The MLE method can be used to estimate the distribution parameters
    %  from data.
    %
    %  Examples:
    %       ds = prtDataGenOldFaithful;
    %       rv = prtRvMixture('components',repmat(prtRvMvn,1,2));
    %       rv = mle(rv,ds);
    %       plotPdf(rv);
    %       hold on;
    %       plot(ds);
    %
    %   See also: prtRv, prtRvMvn, prtRvGmm, prtRvMultinomial,
    %   prtRvUniform, prtRvUniformImproper, prtRvVq
    
    properties
        components
    end
    
    properties (Dependent = true)
        mixingProportions 
        nComponents
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
            if isnumeric(weights)
                if isvector(weights) && prtUtilApproxEqual(sum(weights),1)
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
                assert(weights.nCategories == nSpecifiiedComponents,'The length of these mixingProportions does not mach the number of components of thie prtRvMixture.')
            end
            
            R.mixingProportionsDepHelper = weights;
        end
        function val = get.mixingProportions(R)
            val = R.mixingProportionsDepHelper;
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
            
            X = R.dataInputParse(X); % Basic error checking etc
            
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
            X = R.dataInputParse(X); % Basic error checking etc
            
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
            
            [logy, componentLogPdf] = logPdf(R,X);
            
            y = exp(logy);
            if nargout > 1
                componentPdf = exp(componentLogPdf);
            end
        end 
        
        function [logy, componentLogPdf] = logPdf(R,X)
            X = R.dataInputParse(X); % Basic error checking etc
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
           
            componentLogPdf = zeros(size(X,1),R.nComponents);
            
            logWeights = log(R.mixingProportions.probabilities);
            for iComp = 1:R.nComponents;
                componentLogPdf(:,iComp) = logPdf(R.components(iComp),X)+logWeights(iComp);
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