classdef prtRvUniform < prtRv
    properties
        upperBounds
        lowerBounds
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
    end
    
    methods
        % The Constructor
        function R = prtRvUniform(varargin)
            R.name = 'Uniform Random Variable';
            
            R = constructorInputParse(R,varargin{:});
        end
        
        function R = mle(R,X)
           R.upperBounds = nanmax(X,[],1);
           R.lowerBounds = nanmin(X,[],1);
        end
        
        function vals = pdf(R,X)
            assert(R.isValid,'PDF cannot be evaluated because this RV object is not yet valid.')
            assert(size(X,2) == R.nDimensions,'Incorrect dimensionality for RV object.')
            
            
            isIn = true(size(X,1),1);
            for iDim = 1:size(X,2)
                isIn = isIn & X(:,iDim) >= R.lowerBounds(iDim) & X(:,iDim) <= R.upperBounds(iDim);
            end
                
            vals = zeros(size(X,1),1);
            vals(isIn) = 1/R.area();
        end
        
        function vals = logPdf(R,X)
            assert(R.isValid,'LOGPDF cannot be evaluated because this RV object is not yet valid.')
            
            vals = log(pdf(R,X));
        end
        
        function vals = cdf(R,X)
            vals = prod(max(bsxfun(@minus,bsxfun(@min,X,R.upperBounds),R.lowerBounds),0),2)./R.area();
        end
        
        function a = area(R)
            a = prod(R.upperBounds - R.lowerBounds);
        end
        
        function vals = draw(R,N)
            assert(numel(N)==1 && N==floor(N) && N > 0,'N must be a positive integer scalar.')
            
            vals = bsxfun(@plus,bsxfun(@times,rand(N,R.nDimensions),R.upperBounds - R.lowerBounds),R.lowerBounds);
        end
        
        function val = get.nDimensions(R)
            val = length(R.upperBounds);
        end
    end
    
    methods (Hidden = true)
        function val = isValid(R)
            val = ~isempty(R.upperBounds) && ~isempty(R.lowerBounds);
        end
        function val = plotLimits(R)
            if R.isValid
                val = zeros(2*R.nDimensions,1);
                val(1:2:end) = R.lowerBounds;
                val(2:2:end) = R.upperBounds;
            else
                error('prtRvUniform:plotLimits','Plotting limits can no be determined for this RV because it is not yet valid.')
            end
        end         
    end
end