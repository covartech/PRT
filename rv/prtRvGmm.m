classdef prtRvGmm < prtRv
    % prtRvGmm - Gaussian Mixture Model Random Variable
    %
    %   RV = prtRvGmm creates a prtRvGmm object with empty
    %   mixingProportions and prtRvMvn components. These parameters can be
    %   set manually or by calling the MLE method. A prtRvGmm is a mixture
    %   of multi-variance normal random variables.
    %
    %   RV = prtRvGmm(PROPERTY1, VALUE1,...) creates a prtRvGmm
    %   object RV with properties as specified by PROPERTY/VALUE pairs.
    %
    %   A prtRvGmm object inherits all properties from the prtRv class.
    %   In addition, it has the following properties:
    %
    %   nComponents         - A positive integer specifiying the number of
    %                         MVN components in the mixture.
    %   covarianceStructure - The covariance structure applied to each of
    %                         the prtRvMvn objects in the mixture. See prtRvMvn.
    %   covariancePool      - A logical specifying whether the components
    %                         should share a common covariance. If set to
    %                         true the covariance of the components are 
    %                         set to the weighted average of the maximum
    %                         likelihood estimate for the covariance 
    %                         matrices for the components.
    %   components          - An array of prtRvMvn objects.
    %   mixingProportions   - A discrete probability vector, representing
    %                         the probability of each component in the
    %                         mixture.
    %
    %  A prtRvGmm object inherits all methods from the prtRv class.
    %  The MLE method can be used to estimate the distribution parameters
    %  from data.
    %
    %  Examples:
    %       ds = prtDataGenOldFaithful;      % Load a data set
    %       rv = prtRvGmm('nComponents',2);  % Specify 2 components
    %       rv = mle(rv,ds);                 % Compute the ML estimate
    %       plotPdf(rv);                     % Plot the estimated PDF
    %       hold on;
    %       plot(ds);                        % Overlay the original data   
    %
    %   See also: prtRv, prtRvMvn, prtRvMultinomial, prtRvUniform,
    %             prtRvUniformImproper, prtRvVq
    
    properties (SetAccess = private)
        name = 'Gaussian Mixture Model';
        nameAbbreviation = 'RVGMM';
    end
    
    properties (SetAccess = protected)
        isSupervised = false;
        isCrossValidateValid = true;
    end    
    
    properties (Dependent = true)
        nComponents   % The number of components
        covarianceStructure   % The covariance structure
        covariancePool         % Flag indicating whether or not to pool the covariance
        components             % The mixture components
        mixingProportions      % The mixing proportions
    end
    
    properties (SetAccess = 'private', GetAccess = 'private', Hidden=true)
        nComponentsDepHelp = 1;
        covarianceStructureDepHelp = 'full'; 
        covariancePoolDepHelp = false;
    end
    
    properties (SetAccess='private', Hidden=true)
        mixtureRv = prtRvMixture('components',prtRvMvn('covarianceStructure','full'),'mixingProportions',prtRvMultinomial('probabilities',1));
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
    end
    
    methods
        function R = prtRvGmm(varargin)
            R = constructorInputParse(R,varargin{:});
        end
    end
    
    methods
        function val = get.nDimensions(R)
            val = R.mixtureRv.nDimensions;
        end
        function val = get.components(R)
            val = R.mixtureRv.components;
        end
        function val = get.mixingProportions(R)
            val = R.mixtureRv.mixingProportions;
        end
        function val = get.nComponents(R)
            val = R.nComponentsDepHelp;
        end
        function val = get.nComponentsDepHelp(R)
            val = R.mixtureRv.nComponents;
        end
        function val = get.covarianceStructure(R)
            val = R.covarianceStructureDepHelp;
        end
        function val = get.covariancePool(R)
            val = R.covariancePoolDepHelp;
        end
    end
    
	methods 
        function R = set.nComponents(R,N)
            assert(numel(N)==1 && N==floor(N) && N>0, 'nComponents must be a scalar positive integer')
            
            if isValid(R.mixtureRv)
                warning('prtRvGmm:parameterReset','Modifying the number of components causes the parameters of the prtRvGmm to be reset.')
            end
            
            R.mixtureRv = prtRvMixture('components',repmat(prtRvMvn('covarianceStructure',R.covarianceStructure),N,1),'mixingProportions',prtRvMultinomial('probabilities',1/N*ones(1,N)));
            
            R.nComponentsDepHelp = N;
        end
        function R = set.covarianceStructure(R,val)
            for iComp = 1:R.nComponents
                R.mixtureRv.components(iComp).covarianceStructure = val;
            end
            R.covarianceStructureDepHelp = val;
        end
        function R = set.components(R,vals)
            assert(all(isa(vals,'prtRvMvn')),'components must be of type prtRvMvn');
            
            R.mixtureRv.components = vals;
        end
        function R = set.mixingProportions(R,vals)
            R.mixtureRv.mixingProportions = vals;
        end
        function R = set.covariancePool(R,val)
            assert(numel(val) == 1 && islogical(val),'covariancePool must be a scalar logical');
            
            R.covariancePoolDepHelp = true;
            
            if R.covariancePoolDepHelp
                R.mixtureRv.postMaximizationFunction = @(RMix)R.postMaximizationFunction(RMix);
            end
            
        end
    end
        
    
    methods
        function R = mle(R,X)
            X = R.dataInputParse(X);
            
            R.mixtureRv.minimumComponentMembership = size(X,2)+5;
            % 5 is a rather arbitrarily safe choice. This is motivated by
            % common prior parameters for NiW distributions in Bayesian
            % GMMs.
            
            if size(X,1) < R.mixtureRv.minimumComponentMembership
                error('prt:prtRvGmm:mle','This data has too few observations to support a GMM with this many components.');
            end
            
            R.mixtureRv = mle(R.mixtureRv,X);
        end
        
        function [y, componentPdf] = pdf(R,X)
            [y, componentPdf] = pdf(R.mixtureRv,X);
        end 
        
        function [logy, componentLogPdf] = logPdf(R,X)
            [logy, componentLogPdf] = logPdf(R.mixtureRv,X);
        end 
        
        function y = cdf(R,X)
            y = cdf(R.mixtureRv,X);
        end
        
        function [vals, components] = draw(R,N)
            [vals, components] = draw(R.mixtureRv,N);
        end
    end

    methods (Hidden=true)
        
        function [gmmCell,bic] = bicOptimize(self,ds,componentRange)
            
            count = 1;
            gmmCell = repmat({self},length(componentRange),1);
            bic = nan(length(componentRange),1);
            for n = componentRange
                self.nComponents = componentRange(n);
                
                gmmCell{count} = self.train(ds);
                logLikelihood = gmmCell{count}.logPdf(ds);
                nParams = gmmCell{count}.getNumParams(ds.nFeatures);
                
                bic(count) = -2*sum(logLikelihood) + nParams*log(ds.nObservations);
                count = count + 1;
            end
        end
        
        function nParams = getNumParams(self,d)
            if nargin == 1
                d = self.dataSet.nFeatures;
            elseif isa(d,'prtDataSet')
                d = d.nFeatures;
            end
            nComponents = length(self.components);
            
            switch self.covarianceStructure
                case 'full'
                    nParamsPerCovariance = d*(d-1);
                case 'diagonal'
                    nParamsPerCovariance = d;
                case 'spherical'
                    nParamsPerCovariance = 1;
            end
            nParams = (1 + d + nParamsPerCovariance)*nComponents;
        end
        
        function [val, reasonStr] = isValid(R)
            if numel(R) > 1
                val = false(size(R));
                for iR = 1:numel(R)
                    [val(iR), reasonStr] = isValid(R(iR));
                end
                return
            end
            
            [val, reasonStr] = isValid(R.mixtureRv);
        end
        function val = plotLimits(R)
            val = plotLimits(R.mixtureRv);
        end
        
        function RMix = postMaximizationFunction(R,RMix)
            if ~R.covariancePool
                return
            end
            
            % Pool covariances
            meanCov = zeros(size(RMix.components(1).covariance));
            for iComp = 1:RMix.nComponents
                meanCov = meanCov + RMix.mixingProportions.probabilities(iComp)*RMix.components(iComp).covariance;
            end
            for iComp = 1:RMix.nComponents
                RMix.components(iComp).covariance = meanCov;
            end
        end
    end
end