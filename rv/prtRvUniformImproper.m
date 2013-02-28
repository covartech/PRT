classdef prtRvUniformImproper < prtRv
    % prtRvUniformImproper  Improper uniform random variable
    %
    %   RV = prtRvUniformImproper creates a prtRvUniformImproper object
    %   with unknown dimensionality nDimensions. nDimensions can be set
    %   manually or using the MLE method. A prtRvUniformImproper
    %   models an improper pdf that always yields a value of 1 no matter
    %   the input. prtRvUniformImproper is sometimes useful for creating 
    %   one class classifiers. See the examples below for more information
    %
    %   The draw method of prtRvUniformImproper draws values uniformly
    %   distributed from realmin to realmax in each dimension.
    %
    %   RV = prtRvUniformImproper(PROPERTY1, VALUE1,...) creates a
    %   prtRvMultinomial object RV with properties as specified by
    %   PROPERTY/VALUE pairs.
    %
    %   A prtRvUniformImproper object inherits all properties from the
    %   prtRv class. In addition, it has the following properties:
    %
    %   nDimensions - dimensionality of the data modeled by this RV.
    %   
    %  A prtRvUniformImproper object inherits all methods from the prtRv
    %  class. The MLE  method can be used to set the parameters from data.
    %
    %  Example:
    %
    %  % In this example we show that the PDF of a prtRvUniformImproper is
    %  % always 1
    %  dataSet = prtDataGenUnimodal;        % Load a dataset consisting of
    %                                       % 2 features
    %  dataSet = retainFeatures(dataSet,1); % Retain only the first feature
    %                                       % only for the example.
    %
    %  RV = prtRvUniformImproper;           % Create a prtRvUniform object
    %  RV = RV.mle(dataSet);                % Compute the bounds
    %
    %  RV.plotPdf([-10 10]);                % We must manually specify
    %                                       % plot limits since
    %                                       % prtRvUniformImproper does not
    %                                       % have actual plot limits
    %
    %
    %  % In this example we show how to build a one class MAP classifier
    %  dataSet = prtDataGenUnimodal;        % Load a dataset consisting of
    %                                       % 2 features
    %  
    %  % Create and train a GLRT classifier that uses a 
    %  % prtRvUniformImproper to model class 0 and a prtRvMvn to model
    %  % class 1
    %  glrtClass = train(prtClassGlrt('rvH0',prtRvUniformImproper,'rvH1',prtRvMvn),dataSet);
    %
    %  plot(glrtClass) % Contours only show the log-likelihood of class 1
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
        name = 'Improper Uniform Random Variable'
        nameAbbreviation = 'RVImUnif';
    end
    
    properties (SetAccess = protected)
        isSupervised = false;
        isCrossValidateValid = true;
    end        
    
    properties (Hidden = true, SetAccess = 'private', GetAccess = 'private')
        nDimensionsPrivate
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
    end
    
    methods
        % The Constructor
        function R = prtRvUniformImproper(varargin)
            R = constructorInputParse(R,varargin{:});
        end
        
        function R = mle(R,X)
            X = R.dataInputParse(X); % Basic error checking etc
           R.nDimensionsPrivate = size(X,2);
        end
        
        function vals = pdf(R,X)
            X = R.dataInputParse(X); % Basic error checking etc
            
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'PDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            vals = ones(size(X,1),1);
        end
        
        function vals = logPdf(R,X)
            X = R.dataInputParse(X); % Basic error checking etc
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'LOGPDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            vals = log(pdf(R,X));
        end
        
        function vals = cdf(R,X)
            X = R.dataInputParse(X); % Basic error checking etc
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'CDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
            vals = nan(size(X,1),1);
        end
        
        function vals = draw(R,N)
            if nargin < 2
                N = 1;
            end
            
            assert(numel(N)==1 && N==floor(N) && N > 0,'N must be a positive integer scalar.')
            
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'DRAW cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            vals = bsxfun(@times,bsxfun(@times,rand(N,R.nDimensions),realmax),sign(randn(N,1)));
        end
        
        function R = set.nDimensions(R,N)
            assert(numel(N)==1 && N==floor(N) && N > 0,'nDimensions must be a positive integer scalar.')
            R.nDimensionsPrivate = N;
        end
        
        function val = get.nDimensions(R)
            val = R.nDimensionsPrivate;
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
            
            val = true;
            reasonStr = '';
        end
        function val = plotLimits(R)
            [isValid, reasonStr] = R.isValid;
            if isValid
                val = zeros(2*R.nDimensions,1);
                val(1:2:end) = Inf;
                val(2:2:end) = -Inf;
                % We send backwards limits so that we don't effect plot
                % limits if you were to check the limits of a set of RVs.
                % In this case this RV would not change the resulting
                % max(upperBounds), min(lowerBounds)
            else
                error('prtRvUniformImproper:plotLimits','Plotting limits can not be determined for this RV. It is not yet valid %s.',reasonStr)
            end
        end         
    end
end
