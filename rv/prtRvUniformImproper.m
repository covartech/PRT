classdef prtRvUniformImproper < prtRv
    % xxx Need Help xxx
    properties (Hidden = true, SetAccess = 'private', GetAccess = 'private')
        nDimensionsPrivate
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
    end
    
    methods
        % The Constructor
        function R = prtRvUniformImproper(varargin)
            R.name = 'Improper Uniform Random Variable';
            
            R = constructorInputParse(R,varargin{:});
        end
        
        function R = mle(R,X)
           R.nDimensionsPrivate = size(X,2);
        end
        
        function vals = pdf(R,X)
            assert(size(X,2) == R.nDimensions,'Incorrect dimensionality for RV object.')
            vals = ones(size(X,1),1);
        end
        
        function vals = logPdf(R,X)
            assert(size(X,2) == R.nDimensions,'Incorrect dimensionality for RV object.')
            vals = log(pdf(R,X));
        end
        
        function vals = cdf(R,X)
            assert(size(X,2) == R.nDimensions,'Incorrect dimensionality for RV object.')
            vals = nan(size(X,1),1);
        end
        
        function vals = draw(R,N)
            assert(numel(N)==1 && N==floor(N) && N > 0,'N must be a positive integer scalar.')
            
            vals = bsxfun(@plus,bsxfun(@times,rand(N,R.nDimensions),realmax - realmin),realmin);
        end
        
        function val = get.nDimensions(R)
            val = R.nDimensionsPrivate;
        end
    end
    
    methods (Hidden = true)
        function val = isValid(R)
            val = ~isempty(R.nDimensionsPrivate);
        end
        function val = plotLimits(R)
            if R.isValid
                val = zeros(2*R.nDimensions,1);
                val(1:2:end) = Inf;
                val(2:2:end) = -Inf;
                % We send backwards limits so that we don't effect plot
                % limits if you were to check the limits of a set of RVs.
                % In this case this RV would not change the resulting
                % max(upperBounds), min(lowerBounds)
            else
                error('prtRvUniformImproper:plotLimits','Plotting limits can no be determined for this RV because it is not yet valid.')
            end
        end         
    end
end