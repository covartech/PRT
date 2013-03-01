classdef prtRvMultinomial < prtRv & prtRvMemebershipModel
    % prtRvMultinomial  Multinomial random variable
    %
    %   RV = prtRvMultinomial creates a prtRvMultinomial object
    %   with an unknown number of categories with unspecified probabilities
    %   These properties can be set manually or by using the MLE method.
    %
    %   prtRvMultinomial operates on count matrices. Therfore, the DRAW()
    %   method outputs a matrix that is N x nCategories and has a single 1
    %   in each row. To draw integer categories you can use the
    %   DRAWINTEGER() method.  Similarly, the MLE function takes a count
    %   matrix as an input. Type help prtRvMultinomial.mle for more
    %   information.
    %
    %   RV = prtRvMultinomial(PROPERTY1, VALUE1,...) creates a
    %   prtRvMultinomial object RV with properties as specified by 
    %   PROPERTY/VALUE pairs.
    %
    %   A prtRvMultinomial object inherits all properties from the
    %   prtRv class. In addition, it has the following properties:
    %
    %   nCategories   - number of integers modeled by the RV
    %   probabilities - A 1 x nCategories vector of doubles less than 1
    %                   that sum to 1, representing the probability of
    %                   each of the integers
    %   
    %  A prtRvMultinomial object inherits all methods from the prtRv
    %  class. The MLE  method can be used to set the parameters from data.
    %  In addition, it has the the following methods:
    %   
    %   x = R.drawIntegers(N) - Draws N integers with the corresponding
    %                           probabilities
    %
    %  Example:
    %  
    %  data = rand(100,5);                  % Uniformly random data
    %  X = bsxfun(@eq,data,max(data,[],2)); % Generate data that has a 
    %                                       % single 1 in each row
    %
    %  RV = prtRvMultinomial;               % Generate a prtRvMultinomial
    %  RV = mle(RV,X);                      % Estimate the parameters
    %
    %  RV.plotPdf()                         % Plot the pdf (pmf)
    %
    %   See also: prtRv, prtRvMvn, prtRvGmm, prtRvVq, prtRvKde

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
        name = 'Multinomial Random Variable';
        nameAbbreviation = 'RVMulti';
    end
    
    properties (SetAccess = protected)
        isSupervised = false;
        isCrossValidateValid = true;
    end
    
    properties (Dependent)
        probabilities
    end
    
    properties (Dependent = true)
        nCategories  % The number of categories
    end
    
    properties (Hidden = true, SetAccess='private', GetAccess='private')
        probabilitiesDepHelper
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
    end
    
    properties (Hidden = true)
        approximatelyEqualThreshold = 1e-4;
        nDrawsPerObservationDraw = [];
    end
    
    methods
        % The Constructor
        function R = prtRvMultinomial(varargin)
            R = constructorInputParse(R,varargin{:});
        end
        
        function R = mle(R,X)
            % RV = RV.mle(X) computes the maximum likelihood estimate based
            % the data X. X should be nObservations x nDimensions. X must
            % be a count matrix, consisting of only zeros and ones. A one
            % in the ith column indicates that the sample in the jth row is
            % of class i.
            % 
            
            %             if ~isequal(unique(X(:)),[0;1])
            %                 error('prtRvMultinomial:invalidData','Input matrix must contain only ones and zeros');
            %             end
            
            % Do we really want to or need to enforce this?
            % Can't we allow learning of the probability from multinomial
            % draws that had N greater than 1?
            % I don't see why not. - KDM 2013-03-01
            %if ~prtUtilApproxEqual(sum(X,2),1,1e-6);
            %    error('prtRvMultinomial:invalidData','Rows of input data must contain no more than one "1"');
            %end
            
            X = R.dataInputParse(X); % Basic error checking etc
            
            N_bar = sum(X,1);
            R.probabilities = N_bar./sum(N_bar(:));
        end
        
        function vals = pdf(R,X)
            % PDF Output the pdf of the random variable evaluated at the points specified
            %
            % pdf = RV.pdf(X) returns  the pdf of the prtRv
            % object evaluated at X. X must be an N x nDims matrix, where
            % N is the number of locations to evaluate the pdf, and nDims
            % is the same as the number of dimensions, nDimensions, of the
            % prtRv object RV.
            
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'PDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            X = R.dataInputParse(X); % Basic error checking etc
            assert(isnumeric(X) && ndims(X)==2,'X must be a 2D numeric array.');
            assert(size(X,2) == R.nCategories,'Incorrect number of categories for this RV object. This RV object is defined to have %d categories, but the input data has only %d columns. Remember that prtRvMultinomial operates on count matrices.', R.nCategories, size(X,2))
            
            
            vals = sum(bsxfun(@times,X,R.probabilities),2);
        end
        
        function vals = logPdf(R,X)
            % LOGPDF Output the log pdf of the random variable evaluated at the points specified
            %
            % logpdf = RV.logpdf(X) returns the logarithm of value of the
            % pdf of the prtRv object evaluated at X. X must be an N x
            % nDims matrix, where N is the number of locations to evaluate
            % the pdf, and nDims is the same as the number of dimensions,
            % nDimensions, of the prtRv object RV.

            [isValid, reasonStr] = R.isValid;
            assert(isValid,'LOGPDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            vals = log(pdf(R,X));
        end
        
        function vals = draw(R,N)
            % DRAW  Draw random samples from the distribution described by the prtRv object
            %
            % VAL = RV.draw(N) generates N random samples drawn from the
            % distribution described by the prtRv object RV. VAL will be a
            % N x nDimensions vector, where nDimensions is the number of
            % dimensions of RV.
            
            assert(numel(N)==1 && all(N==floor(N)) && all(N > 0),'N must be a positive integer scalar.')
            
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'DRAW cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            if ~isempty(R.nDrawsPerObservationDraw)
                nObsToDraw = R.nDrawsPerObservationDraw;
                vals = zeros(N,R.nCategories);
                for iBag = 1:N
                    cVals = zeros(nObsToDraw,R.nCategories);
                    cVals(sub2ind([nObsToDraw, R.nCategories], (1:nObsToDraw)',drawIntegers(R,nObsToDraw))) = 1;
                    vals(iBag,:) = sum(cVals,1);
                end
            else
                vals = zeros(N,R.nCategories);
                vals(sub2ind([N, R.nCategories], (1:N)',drawIntegers(R,N))) = 1;
            end
        end
        
        function vals = drawIntegers(R,N)
            % DRAW  Draw random integer samples from the distribution described by the prtRv object
            %
            % VAL = RV.draw(N) generates N random integer samples drawn from the
            % distribution described by the prtRv object RV. VAL will be a
            % N x nDimensions vector, where nDimensions is the number of
            % dimensions of RV.
            
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'DRAWINTEGERS cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);

            assert(numel(N)==1 && N==floor(N) && N > 0,'N must be a positive integer scalar.')
            
            vals = prtRvUtilRandomSample(R.probabilities, N);
        end
        
        function varargout = plotPdf(R,varargin)
            %plotPdf Plot the pdf of the RV
            %
            % rv.plotPdf() plots the pdf of rv
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'plotPdf cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            h = bar(1:R.nCategories,R.probabilities,'k');
            ylim([0 1])
            xlim(R.plotLimits());
            
            varargout = {};
            if nargout
                varargout = {h};
            end
        end
        
        function plotCdf(R,varargin) %#ok<MANU>
            % plotCDF Not implemented for this prtRv
            error('prt:prtRvMultinomial','plotCdf is not implimented for this prtRv');
        end
        
    end
    
    % Set methods
    methods
        function R = set.probabilities(R,probs)
            assert(abs(sum(probs)-1) < R.approximatelyEqualThreshold,'Probability vector must must sum to 1.')
            
            R.probabilitiesDepHelper = probs(:)';
        end
        function R = set.nCategories(R,val) %#ok<MANU,INUSD>
            error('prt:prtRvMultinomial','nCategories is a dependent property that cannot be set by the user. To set the number of categories, set "probabilities" to be a vector of the desired length.');
        end
    end
    
    % Get methods
    methods
        function val = get.probabilities(R)
            val = R.probabilitiesDepHelper;
        end
        function val = get.nCategories(R)
            if ~isempty(R.probabilities)
                val = length(R.probabilities);
            else
                val = [];
            end
        end
        function val = get.nDimensions(R)
            val = R.nCategories;
        end
    end
    
    methods (Hidden = true)
        function [val, reasonStr] = isValid(R)
            if numel(R) > 1
                val = false(size(R));
                for iR = 1:numel(R)
                    [val(iR), reasonStr] = isValid(R(iR));
                end
                return
            end
            
            val = ~isempty(R.probabilities);
            
            if val
                reasonStr = '';
            else
                reasonStr = 'because probabilities has not been set';
            end
        end
        
        
        function val = plotLimits(R)
            [isValid, reasonStr] = R.isValid;
            if isValid
                val = [0.5 0.5+R.nCategories];
            else
                
                error('multinomial:plotLimits','Plotting limits can not yet be determined. This RV is not yet valid %s.',reasonStr)
            end
        end
        
        function val = isPlottable(R) %#ok
            val = true; % Always plottable
        end
        
        function R = weightedMle(R,X,weights)
            assert(numel(weights)==size(X,1),'The number of weights must mach the number of observations.');
            
            weights = weights(:);
            
            N_bar = sum(bsxfun(@times,X,weights),1);
            
            R.probabilities = N_bar./sum(N_bar(:));
        end
    end
end
