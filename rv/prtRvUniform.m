classdef prtRvUniform < prtRv
    % prtRvUniform  Uniform random variable
    %   The variables UPPERBOUNDS and LOWERBOUNDS specify the randge of the
    %   uniform variable. 
    %
    %   RV = prtRvUniform creates a prtRvUniform object with empty 
    %   UPPDERBOUNDS and LOWERBOUNDS. The UPPDERBOUNDS and LOWERBOUNDS must
    %   be set either directly, or by calling the MLE method.
    %
    %   RV = prtRvUniform(PROPERTY1, VALUE1,...) creates a prtRvUniform
    %   object RV with properties as specified by PROPERTY/VALUE pairs.
    %
    %   A prtRvUniform object inherits all properties from the prtRv class.
    %   In
    %   addition, it has the following properties:
    %
    %   upperBounds - 1 x nDims double vector specifying the upper bound of
    %                 the region with uniform density
    %   lowerBounds - 1 x nDims double vector specifying the lower bound of
    %                 the region with uniform density
    %   
    %  A prtRvUniform object inherits all methods from the prtRv class.
    %  The MLE  method can be used to estimate the distribution parameters
    %  from data.
    %
    %  Example:
    %
    %  dataSet = prtDataGenUnimodal;        % Load a dataset consisting of
    %                                       % 2 features
    %  dataSet = retainFeatures(dataSet,1); % Retain only the first feature
    %
    %  RV = prtRvUniform;                   % Create a prtRvUniform object
    %  RV = RV.mle(dataSet);                % Compute the bounds
    %                                       % form the data
    %  RV.plotPdf                           % Plot the pdf
    %  
    %   See also: prtRv, prtRvMvn, prtRvGmm, prtRvMultinomial,
    %   prtRvVq, prtRvKde
    
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
            X = R.dataInputParse(X); % Basic error checking etc
            R.upperBounds = nanmax(X,[],1);
            R.lowerBounds = nanmin(X,[],1);
        end
        
        function vals = pdf(R,X)
            assert(R.isValid,'PDF cannot be evaluated because this RV object is not yet valid.')
            X = R.dataInputParse(X); % Basic error checking etc
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
            
            
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
            X = R.dataInputParse(X); % Basic error checking etc
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
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
                
                range = R.upperBounds-R.lowerBounds;
                
                val = zeros(2*R.nDimensions,1);
                val(1:2:end) = R.lowerBounds-range/10;
                val(2:2:end) = R.upperBounds+range/10;
                
                
            else
                error('prtRvUniform:plotLimits','Plotting limits can no be determined for this RV because it is not yet valid.')
            end
        end
    end
end