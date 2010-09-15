classdef prtRvGmm < prtRv
    properties
        nComponents = 1;
        covarianceStructure = 'full';
    end
    
    properties (SetAccess='private', Hidden=true)
        mixtureRv = prtRvMixture('components',prtRvMvn('covarianceStructure','full'),'mixingProportions',prtRvMultinomial('probabilities',1));
    end
    
    properties
        components
        mixingProportions
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
    end
    
    methods
        function R = prtRvGmm(varargin)
            R.name = 'Gaussian Mixture Model';
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
    end
    
	methods 
        function R = set.nComponents(R,N)
            assert(numel(N)==1 && N==floor(N) && N>0, 'nComponents must be a scalar positive integer')
            
            if isValid(R.mixtureRv)
                warning('prtRvGmm:parameterReset','Modifying the number of components causes the parameters of the prtRvGmm to be reset.')
            end
            
            R.mixtureRv = prtRvMixture('components',repmat(prtRvMvn('covarianceStructure',R.covarianceStructure),N,1),'mixingProportions',prtRvMultinomial('probabilities',1/N*ones(1,N)));
            R.nComponents = N;  
        end
        function R = set.covarianceStructure(R,val)
            for iComp = 1:R.nComponents
                R.mixtureRv.components(iComp).covarianceStructure = val;
            end
            R.covarianceStructure = val;
        end
        function R = set.components(R,vals)
            R.mixtureRv.components = vals;
        end
        function R = set.mixingProportions(R,vals)
            R.mixtureRv.mixingProportions = vals;
        end
    end
        
    
    methods
        function R = mle(R,X)
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
        function val = isValid(R)
            val = isValid(R.mixtureRv);
        end
        function val = plotLimits(R)
            val = plotLimits(R.mixtureRv);
        end
    end
end % classdef