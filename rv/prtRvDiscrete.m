classdef prtRvDiscrete < prtRv
    % prtRvDiscrete  Discrete random variable
    %   Models a discrete density on a set of numeric symbols
    %   If input to mle(), X, is a vector it is interpreted as a 1D vector
    %   of symbol observations. If X is an nObs x nDim matrix it is
    %   interpreted as nObs observations of nDim dimensional symbols.
    %
    %   RV = prtRvDiscrete creates a prtRvDiscrete object with an unknown
    %   symbols and unspecified probabilities. These properties
    %   can be set manually or by using the MLE method. Both of these
    %   properties must be set to make the RV valid.
    %
    %   RV = prtRvDiscrete(PROPERTY1, VALUE1,...) creates a
    %   prtRvDiscrete object RV with properties as specified by 
    %   PROPERTY/VALUE pairs.
    %
    %   A prtRvDiscrete object inherits all properties from the
    %   prtRv class. In addition, it has the following properties:
    %
    %   nCategories   - number of integers modeled by the RV
    %   probabilities - 1 x nCategories vector of doubles less than 1
    %                   that sum to 1, representing the probability of
    %                   each of the integers
    %   symbols       - nCategories x M matrix of symbols
    %                   M specifies the dimensionality of the RV object.
    %   
    %  A prtRvDiscrete object inherits all methods from the prtRv
    %  class. The MLE  method can be used to set the parameters from data.
    %
    %  Example:
    %  
    %      rv = prtRvDiscrete('symbols',(10:12)','probabilities',[0.3 0.3 0.4]);
    %      plotPdf(rv);
    %
    %      % Plot MVN distributed data as discrete
    %      rv = mle(prtRvDiscrete,draw(prtRvMvn('Mean',[1 2],'Covariance',2*eye(2)),100));
    %      plotPdf(rv);
    %
    %   See also: prtRv, prtRvMvn, prtRvGmm, prtRvVq, prtRvKde,
    %             prtRvMultinomial
    
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
            if isvector(val)
                % We assume that they wanted a single set of symbols
                % instead of a single multi-dimensional symbol.
                val = val(:);
            end
            
            assert(~R.InternalMultinomial.isValid || R.nCategories == size(val,1),'Number of specified symbols does not match the current number of categories.')
            assert(isnumeric(val) && ndims(val)==2,'symbols must be a 2D numeric array.')
            
            R.symbolsDepHelp = val;
        end
        
        function val = get.symbols(R)
            val = R.symbolsDepHelp;
        end
        
        function R = mle(R,X)
            X = R.dataInputParse(X); % Basic error checking etc
            
            assert(isnumeric(X) && ndims(X)==2,'Input data must be a 2D numeric array or a prtDataSet.');
            
            R = weightedMle(R,X,ones(size(X,1),1));
        end
        
        function vals = pdf(R,X)
            
            X = R.dataInputParse(X); % Basic error checking etc
            
            assert(R.isValid,'PDF cannot be evaluated because this RV object is not yet valid.')
            
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
            
            assert(isnumeric(X) && ndims(X)==2,'X must be a 2D numeric array.');
            
            [dontNeed, symbolInds] = ismember(X,R.symbols,'rows'); %#ok
            
            vals = R.probabilities(symbolInds);
            vals = vals(:);
        end
        
        function vals = logPdf(R,X)
            assert(R.isValid,'LOGPDF cannot be evaluated because this RV object is not yet valid.')
            
            X = R.dataInputParse(X); % Basic error checking etc
            
            vals = log(pdf(R,X));
        end
        
        function vals = draw(R,N)
            if nargin < 2 || isempty(N)
                N = 1;
            end
            assert(R.isValid,'DRAW cannot be called because this RV is not yet valid.');
            assert(numel(N)==1 && N==floor(N) && N > 0,'N must be a positive integer scalar.')
            
            vals = R.symbols(drawIntegers(R.InternalMultinomial,N),:);
        end
        
        
        function varargout = plotPdf(R,varargin)
            if ~R.isPlottable
                if R.isValid
                    error('prt:prtRv:plot','This RV object cannont be plotted because it has too many dimensions for plotting.')
                else
                    error('prt:prtRv:plot','This RV object cannot be plotted because it is not yet valid.');
                end
            end
            
            switch R.nDimensions
                case 1
                    h = plotPdf(R.InternalMultinomial);
                    symStrs = R.symbolsStrs();
                    xTick = get(gca,'XTick');
                    set(gca,'XTickLabel',symStrs(xTick));
                case 2
                    z = R.InternalMultinomial.probabilities(:);
                    UserOptions = prtUserOptions;
                    colorMapInds = gray2ind(mat2gray(z),UserOptions.RvPlotOptions.nColorMapSamples);
                    cMap = UserOptions.RvPlotOptions.colorMapFunction(UserOptions.RvPlotOptions.nColorMapSamples);
                    
                    cMap = prtPlotUtilDarkenColors(cMap);
                    
                    holdState = get(gca,'NextPlot');
                    h = zeros(size(cMap,1));
                    for iColor = 1:size(cMap,1)
                        cInds = colorMapInds == iColor;
                        if any(cInds)
                            cColor = cMap(iColor,:);
                            h(iColor) = stem3(R.symbols(cInds,1),R.symbols(cInds,2),R.InternalMultinomial.probabilities(cInds),'fill','color',cColor);
                            hold on
                        end
                    end
                    set(gca,'NextPlot',holdState);
                    
                otherwise
                    error('prt:prtRvDiscreteplotPdf','Discrete RV objects can only be plotted in one or two dimensions');
            end
            
            varargout = {};
            if nargout
                varargout = {h};
            end
        end
        function plotCdf(R,varargin) %#ok<MANU>
            error('prt:prtRvDiscrete','plotCdf is not implimented for this prtRv');
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
            val = isValid(R.InternalMultinomial) && ~isempty(R.symbols);
        end
        function val = plotLimits(R)
            val = plotLimits(R.InternalMultinomial);
        end
        
        function val = isPlottable(R)
            val = isPlottable(R.InternalMultinomial) && ~isempty(R.symbols);
        end
        
        function R = weightedMle(R,X,weights)
            if isvector(X)
                % A single symbol... interperet as a vector of 1D symbols
                X = X(:);
                if numel(weights) == 1
                    weights = weights.*ones(size(X));
                end
            end
            assert(numel(weights)==size(X,1),'The number of weights must mach the number of observations.');
            
            [R.symbols, dontNeed, symbolInd] = unique(X,'rows'); %#ok
            
            occuranceLogical = false(size(X,1),size(R.symbols,1));
            occuranceLogical(sub2ind(size(occuranceLogical),(1:size(X,1))',symbolInd)) = true;
            
            R.InternalMultinomial = R.InternalMultinomial.weightedMle(occuranceLogical, weights);
        end
    end
end