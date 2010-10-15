classdef prtRvDiscrete < prtRv
    % xxx Need Help xxx
    properties (Dependent = true)
        probabilities
        nCategories
        symbols
    end
    
    properties (Dependent = true, Hidden=true)
        InternalMultinomial
        nDimensions
    end
    
    properties (SetAccess = 'private', GetAccess = 'private', Hidden=true)
        InternalMultinomialDepHelp = prtRvMultinomial();
        symbolsDepHelp
    end
    
    methods
        % The Constructor
        function R = prtRvDiscrete(varargin)
            R.name = 'Discrete Random Variable';
            
            R = constructorInputParse(R,varargin{:});
        end
        function val = get.nCategories(R)
            val = R.InternalMultinomial.nCategories;
        end
        function val = get.probabilities(R)
            val = R.InternalMultinomial.probabilities;
        end
        
        function val = get.InternalMultinomial(R)
            val = R.InternalMultinomialDepHelp;
        end
        
        function R = set.InternalMultinomial(R,val)
            assert(isa(val,'prtRvMultinomial'),'InternalMultinomial must be a prtRvMultinomial.')
            R.InternalMultinomialDepHelp = val;
        end
        
        function R = set.nCategories(R,val)
            R.InternalMultinomial.nCategories = val;
        end
        function R = set.probabilities(R,val)
            if ~isempty(R.symbols)
                assert(size(R.symbols,1) == numel(val),'size mismatch between probabilities and symbols')
            end
            R.InternalMultinomial.probabilities = val(:);
        end

        function val = get.nDimensions(R)
            val = size(R.symbols,2);
        end
        
        function R = set.symbols(R,val)
            assert(~R.InternalMultinomial.isValid || R.nCategories == size(val,1),'Number of specified symbols does not match the current number of categories.')
            assert(isnumeric(val) && ndims(val)==2,'symbols must be a 2D numeric array.')
            
            R.symbolsDepHelp = val;
        end
        
        function val = get.symbols(R)
            val = R.symbolsDepHelp;
        end
        
        function R = mle(R,X)
            assert(size(X,2) == R.nDimensions,'Incorrect dimensionality for this prtRv');
            assert(isnumeric(X) && ndims(X)==2,'X must be a 2D numeric array.');
            
            R = weightedMle(R,X,ones(size(X,1),1));
        end
        
        function vals = pdf(R,X)
            assert(R.isValid,'PDF cannot be evaluated because this RV object is not yet valid.')
            assert(isnumeric(X) && ndims(X)==2,'X must be a 2D numeric array.');
            
            [dontNeed, symbolInds] = ismember(X,R.symbols,'rows'); %#ok
            
            vals = R.probabilities(symbolInds);
            vals = vals(:);
        end
        
        function vals = logPdf(R,X)
            assert(R.isValid,'LOGPDF cannot be evaluated because this RV object is not yet valid.')
            
            vals = log(pdf(R,X));
        end
        
        function vals = draw(R,N)
            if nargin < 2 || isempty(N)
                N = 1;
            end
            
            assert(numel(N)==1 && N==floor(N) && N > 0,'N must be a positive integer scalar.')
            
            
            
            vals = R.symbols(drawIntegers(R.InternalMultinomial,N),:);
        end
        
        
        function varargout = plotPdf(R,varargin)
            h = plotPdf(R.InternalMultinomial);
            
            xTick = get(gca,'XTick');
            symStrs = R.symbolsStrs();
            set(gca,'XTickLabel',symStrs(xTick));
            
            varargout = {};
            if nargout
                varargout = {h};
            end
        end
        
        function varargout = plotCdf(R,varargin)
            h = plotCdf(R.InternalMultinomial);
            
            xTick = get(gca,'XTick');
            symStrs = R.symbolsStrs();
            set(gca,'XTickLabel',symStrs(xTick));
           
            varargout = {};
            if nargout
                varargout = {h};
            end
        end
        
        function cs = symbolsStrs(R)
            cs = cell(size(R.symbols,1),1);
            for iS = 1:size(R.symbols,1)
                cs{iS} = mat2str(R.symbols(iS,:),2);
            end
        end
        
    end
    
    methods (Hidden = true)
        function val = isValid(R)
            val = isValid(R.InternalMultinomial);
        end
        function val = plotLimits(R)
            val = plotLimits(R.InternalMultinomial);
        end
    
        function val = isPlottable(R)
            val = isPlottable(R.InternalMultinomial);
        end
        
        function R = weightedMle(R,X,weights)
            assert(numel(weights)==size(X,1),'The number of weights must mach the number of observations.');
            
            [symbols, dontNeed, symbolInd] = unique(X,'rows'); %#ok
            
            occuranceLogical = false(size(X,1),size(symbols,1));
            occuranceLogical(sub2ind(size(occuranceLogical),(1:size(X,1))',symbolInd)) = true;
            
            R.InternalMultinomial = R.InternalMultinomial.weightedMle(occuranceLogical, weights);
        end
    end
end