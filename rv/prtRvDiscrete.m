classdef prtRvDiscrete < prtRv & prtRvMemebershipModel
    % prtRvDiscrete  Discrete random variable.
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
    %      rv = mle(prtRvDiscrete,draw(prtRvMvn('mu',[1 2],'sigma',2*eye(2)),100));
    %      plotPdf(rv);
    %
    %   See also: prtRv, prtRvMvn, prtRvGmm, prtRvVq, prtRvKde,
    %             prtRvMultinomial

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
        name = 'Discrete Random Variable';
        nameAbbreviation = 'RVDisc';
    end
    
    properties (SetAccess = protected)
        isSupervised = false;
        isCrossValidateValid = true;
    end
    
    properties (Dependent = true)
        probabilities   % The probabilities of each symbol
        nCategories     % The number of categories
        symbols         % The symbols
    end
    
    properties (Dependent = true, Hidden=true)
        InternalMultinomial
        nDimensions
    end
    properties (Hidden = true)
        inferSymbols = true;    %logical; if true, infer symbols during 
                                %MLE; if false, check if there are provided
                                %symbols - if there are, use the provided
                                %symbols, ignoring symbols that are not
                                %pre-specified
    end
    
    properties (SetAccess = 'private', GetAccess = 'private', Hidden=true)
        InternalMultinomialDepHelp = prtRvMultinomial();
        symbolsDepHelp
    end
    
    methods
        % The Constructor
        function R = prtRvDiscrete(varargin)
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
            
            % Although the below might be more intuitive for setting the
            % symbols directly, it can cause problems in more sophisticated
            % processing. Consider cross-validating a classifier that uses
            % prtRvDiscrete to model the classes. It is possible that a
            % training fold may only contain 1 observation of a
            % multidimensional data set. This will lead to difficult to
            % understand errors.
            %
            % See also prtRvDiscrete.weightedMle()
            %
            % if isvector(val)
            %     % We assume that they wanted a single set of symbols
            %     % instead of a single multi-dimensional symbol.
            %     val = val(:);
            % end
            
            assert(~R.InternalMultinomial.isValid || R.nCategories == size(val,1),'Number of specified symbols does not match the current number of categories. symbols must be specified as a nCategories by nDimensions matrix.')
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
            
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'PDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
            
            assert(isnumeric(X) && ndims(X)==2,'X must be a 2D numeric array.');
            
            [isValidSymbol, symbolInds] = ismember(X,R.symbols,'rows');

            vals = zeros(size(X,1),1);
            vals(isValidSymbol) = R.probabilities(symbolInds(isValidSymbol));
        end
        
        function vals = logPdf(R,X)
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'LOGPDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            X = R.dataInputParse(X); % Basic error checking etc
            
            vals = log(pdf(R,X));
        end
        
        function vals = draw(R,N)
            if nargin < 2 || isempty(N)
                N = 1;
            end
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'DRAW cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            assert(numel(N)==1 && N==floor(N) && N > 0,'N must be a positive integer scalar.')
            
            vals = R.symbols(drawIntegers(R.InternalMultinomial,N),:);
        end
        
        
        function varargout = plotPdf(R,varargin)
            if ~R.isPlottable
                [isValid, reasonStr] = R.isValid;
                if isValid
                    error('prt:prtRv:plot','This RV object cannont be plotted because it has too many dimensions for plotting.')
                else
                    error('prt:prtRv:plot','This RV object cannot be plotted. It is not yet valid %s',reasonStr);
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
                    
                    colorMapInds = gray2ind(mat2gray(z),R.plotOptions.nColorMapSamples);
                    cMap = R.plotOptions.colorMapFunction(R.plotOptions.nColorMapSamples);
                    
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
        
        
    end
    
    
    methods (Hidden = true)
        
        function cs = symbolsStrs(R)
            cs = cell(size(R.symbols,1),1);
            for iS = 1:size(R.symbols,1)
                cs{iS} = mat2str(R.symbols(iS,:),2);
            end
        end
        
        function [val, reasonStr] = isValid(R)
            if numel(R) > 1
                val = false(size(R));
                for iR = 1:numel(R)
                    [val(iR), reasonStr] = isValid(R(iR));
                end
                return
            end
            
            val = isValid(R.InternalMultinomial) && ~isempty(R.symbols);
            
            if val
                reasonStr = '';
            else
                badProbs = isempty(R.probabilities);
                badSymbols = isempty(R.symbols);
                
                if badProbs && ~badSymbols
                    reasonStr = 'because probabilities has not been set';
                elseif ~badProbs && badSymbols
                    reasonStr = 'because symbols has not been set';
                elseif badProbs && badSymbols
                    reasonStr = 'because probabilities and symbols have not been set';
                else
                    reasonStr = 'because of an unknown reason';
                end
            end
            
        end
        function val = plotLimits(R)
            val = plotLimits(R.InternalMultinomial);
        end
        
        function val = isPlottable(R)
            val = isPlottable(R.InternalMultinomial) && ~isempty(R.symbols);
        end
        
        function R = weightedMle(R,X,weights)
            
            % Although the below might be more intuitive for setting the
            % symbols directly, it can cause problems in more sophisticated
            % processing. Consider cross-validating a classifier that uses
            % prtRvDiscrete to model the classes. It is possible that a
            % training fold may only contain 1 observation of a
            % multidimensional data set. This will lead to difficult to
            % understand errors.
            %
            % See also prtRvDiscrete.set.symbols()
            %
            % if isvector(X)
            %     % A single symbol... interperet as a vector of 1D symbols
            %     X = X(:);
            %     if numel(weights) == 1
            %         weights = weights.*ones(size(X));
            %     end
            % end
            
            assert(numel(weights)==size(X,1),'The number of weights must mach the number of observations.');
            
            if isempty(R.symbols) || R.inferSymbols
                [R.symbols, dontNeed, symbolInd] = unique(X,'rows'); %#ok
                
                occuranceLogical = false(size(X,1),size(R.symbols,1));
                occuranceLogical(sub2ind(size(occuranceLogical),(1:size(X,1))',symbolInd)) = true;
            else
                %Check for missing symbols, and warn:
                [tempSymbols, dontNeed, symbolInd] = unique(X,'rows'); %#ok
                missingSymbols = setdiff(tempSymbols,R.symbols,'rows');
                if ~isempty(missingSymbols)
                    warning('prtRvDiscrete:weightedMle','Discrete RV with manual symbols trained on data containing new discrete values');
                end
                
                %Otherwise, build the logical occurence matrix
                occuranceLogical = false(size(X,1),size(R.symbols,1));
                for j = 1:size(R.symbols,1)
                    occuranceLogical(:,j) = all(X == repmat(R.symbols(j,:),size(X,1),1),2);
                end
                
            end
            
            R.InternalMultinomial = R.InternalMultinomial.weightedMle(occuranceLogical, weights);
        end
    end
end
