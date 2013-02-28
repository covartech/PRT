classdef prtRvUniform < prtRv
    % prtRvUniform  Uniform random variable
    %
    %   RV = prtRvUniform creates a prtRvUniform object with empty
    %   upperBounds and lowerBounds. The upperBounds and lowerBounds must
    %   be set either directly, or by calling the MLE method. upperBounds
    %   and lowerBounds specify the range of the uniform variable.
    %
    %   RV = prtRvUniform(PROPERTY1, VALUE1,...) creates a prtRvUniform
    %   object RV with properties as specified by PROPERTY/VALUE pairs.
    %
    %   A prtRvUniform object inherits all properties from the prtRv class.
    %   In addition, it has the following properties:
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
        name = 'Uniform Random Variable'
        nameAbbreviation = 'RVUnif';
    end
    
    properties (SetAccess = protected)
        isSupervised = false;
        isCrossValidateValid = true;
    end    
    
    properties
        upperBounds  % The lower bounds of the random variable
        lowerBounds  % The upper bounds of the random variable
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
    end
    
    methods
        % The Constructor
        function R = prtRvUniform(varargin)
            R = constructorInputParse(R,varargin{:});
        end
        
        function R = mle(R,X)
            X = R.dataInputParse(X); % Basic error checking etc
            R.upperBounds = max(X,[],1);
            R.lowerBounds = min(X,[],1);
        end
        
        function vals = pdf(R,X)
            
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'PDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
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
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'LOGPDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
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
            if nargin < 2
                N = 1;
            end
            
            assert(numel(N)==1 && N==floor(N) && N > 0,'N must be a positive integer scalar.')
            
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'DRAW cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            vals = bsxfun(@plus,bsxfun(@times,rand(N,R.nDimensions),R.upperBounds - R.lowerBounds),R.lowerBounds);
        end
        
        function val = get.nDimensions(R)
            val = length(R.upperBounds);
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
            
            badOrder = ~all(R.upperBounds>R.lowerBounds);
            
            val = ~isempty(R.upperBounds) && ~isempty(R.lowerBounds) && ~badOrder;
            
            if val
                reasonStr = '';
            else
                badUpper = isempty(R.upperBounds);
                badLower = isempty(R.lowerBounds);
                
                if badUpper && ~badLower
                    reasonStr = 'because upperBounds has not been set';
                elseif ~badUpper && badLower
                    reasonStr = 'because lowerBounds has not been set';
                elseif badUpper && badLower
                    reasonStr = 'because upperBounds and lowerBounds have not been set';
                elseif badOrder
                    reasonStr = 'because at least one entry of lowerBounds is greater than the corresponding entry of upperBounds';
                else
                    reasonStr = 'because of an unknown reason';
                end
            end
        end
        
        function val = plotLimits(R)
            [isValid, reasonStr] = R.isValid;
            if isValid
                
                range = R.upperBounds-R.lowerBounds;
                
                val = zeros(2*R.nDimensions,1);
                val(1:2:end) = R.lowerBounds-range/10;
                val(2:2:end) = R.upperBounds+range/10;
                
                
            else
                error('prtRvUniform:plotLimits','Plotting limits can not be determined for this RV. It is not yet valid %s.',reasonStr)
            end
        end
    end
end
