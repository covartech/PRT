classdef prtRvMvb < prtRv & prtRvMemebershipModel
    % prtRvMvv  Multivariate binary random variable
    %
    %   RV = prtRvMvv creates a prtRvMvv object with empty probability
    %   vector. The probability vector must be set either directly, or by
    %   calling the MLE method.
    %
    %   RV = prtRvMvn(PROPERTY1, VALUE1,...) creates a prtRvMvb object RV
    %   with properties as specified by PROPERTY/VALUE pairs.
    %
    %   A prtRvMvb object inherits all properties from the prtRv class. In
    %   addition, it has the following properties:
    %
    %   probabilities - 1 x nDimensions vector with values between 0 and 1
    %                   specifying the probability of each dimension taking
    %                   the value true.
    %   
    %  Example:
    %
    %   See also: prtRv, prtRvGmm, prtRvMultinomial, prtRvUniform,
    %   prtRvUniformImproper, prtRvVq, prtRvDiscrete

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
        name = 'Multi-Variate Binary';
        nameAbbreviation = 'RVMVB';
    end
    
    properties (SetAccess = protected)
        isSupervised = false;
        isCrossValidateValid = true;
    end
    
    properties (Dependent)
        probabilities
    end
    properties (Dependent, SetAccess = 'private')
        logProbabilities
        logOneMinusProbabilities
    end
    properties (Hidden, Dependent)
        minProbability
        maxProbability
    end
    properties (Hidden, SetAccess='private', GetAccess='private')
        minProbabilityDepHelper = 0;
        maxProbabilityDepHelper = 1;
        probabilitiesDepHelper
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
    end
    
    methods
        function R = prtRvMvb(varargin)
            R.name = 'Multi-Variate Binary';
            R = constructorInputParse(R,varargin{:});
        end
        
        function R = mle(R,X)
           % MLE Compute the maximum likelihood estimate 
            %
            % RV = RV.mle(X) computes the maximum likelihood estimate based
            % the data X. X should be nObservations x nDimensions.        

            X = R.dataInputParse(X); % Basic error checking etc
            
            R = weightedMle(R,X,ones(size(X,1),1));
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
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
            assert((isnumeric(X) || islogical(X)) && ndims(X)==2,'X must be a 2D numeric or logical array.');
            
            vals = prod(bsxfun(@times,X,R.probabilities) + bsxfun(@times,~X,1-R.probabilities),2);
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
            
            X = R.dataInputParse(X); % Basic error checking etc
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
            assert((isnumeric(X) || islogical(X)) && ndims(X)==2,'X must be a 2D numeric or logical array.');
            
            term1 = bsxfun(@times,X,R.logProbabilities); term1(isnan(term1)) = 0; %false*-inf = NaN;
            term2 = bsxfun(@times,~X,R.logOneMinusProbabilities); term2(isnan(term2)) = 0; %false*-inf = NaN;
            vals = sum(term1 + term2,2);
        end
        
        function vals = draw(R,N)
            % DRAW  Draw random samples from the distribution described by the prtRv object
            %
            % VAL = RV.draw(N) generates N random samples drawn from the
            % distribution described by the prtRv object RV. VAL will be a
            % N x nDimensions vector, where nDimensions is the number of
            % dimensions of RV.
            
            assert(numel(N)==1 && N==floor(N) && N > 0,'N must be a positive integer scalar.')
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'DRAW cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            vals = bsxfun(@ge , rand(N,R.nDimensions), R.probabilities);
        end
    end
    
    methods (Hidden=true)
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
        
        function R = weightedMle(R,X,weights)
            
            assert(numel(weights)==size(X,1),'The number of weights must mach the number of observations.');
            
            if ~islogical(X) 
                assert(isnumeric(X) && all(all(X >= 0 & X<=1)),'prt:prtRvMvb:mle','input data to prtRvMvb.mle must contain values between 0 and 1')
            end
            
            weights = weights(:);
            
            R.probabilities = sum(bsxfun(@times,X,weights))/sum(weights);
            
        end
        
        function initMembershipMat = initializeMixtureMembership(Rs,X)
            
            learningInitialMembershipFactor = 0.9;
            
            [classMeans,kmMembership] = prtUtilKmeans(X,length(Rs),'handleEmptyClusters','random','distanceMetricFn',@prtDistanceHamming,'maxIterations',100,'logicalMeans',true); %#ok<ASGLU>
            
            initMembershipMat = zeros(size(X,1),length(Rs));
            for iComp = 1:length(Rs)
                initMembershipMat(kmMembership == iComp, iComp) = learningInitialMembershipFactor;
            end
            initMembershipMat(initMembershipMat==0) = (1-learningInitialMembershipFactor)./(length(Rs)-1);
            
            % We should normalize this just in case the
            % learningInitialMembershipFactor was set poorly
            initMembershipMat = bsxfun(@rdivide,initMembershipMat,sum(initMembershipMat,2));
        end
    end
    
    % Get methods
    methods
        function val = get.nDimensions(R)
            val = getNumDimensions(R);
        end
        function val = get.probabilities(R)
            val = R.probabilitiesDepHelper;
        end
        function val = get.minProbability(R)
            val = R.minProbabilityDepHelper;
        end
        function val = get.maxProbability(R)
            val = R.maxProbabilityDepHelper;
        end
        function val = get.logProbabilities(R)
            val = log(R.probabilities);
        end
        function val = get.logOneMinusProbabilities(R)
            val = log(1 - R.probabilities);
        end
    end
    
    methods (Access = 'protected')
        function val = getNumDimensions(R)
            if ~isempty(R.probabilities)
                val = length(R.probabilities);
            else
                val = [];
            end
        end
    end
    % Set Methods
    methods
        function R = set.probabilities(R,val)
            assert((isnumeric(val) || islogical(val)) && isvector(val),'probabilities must be a vector of values between 0 and 1 (inclusively');
            assert(all(val<=1 & val>=0),'prt:prtRvMvb:badProbabilities','probabilities must have values between 0 and 1 (inclusively)')
            
            val = val(:)';
            
            val(val>R.maxProbability) = R.maxProbability;
            val(val<R.minProbability) = R.minProbability;
            
            R.probabilitiesDepHelper = val;
        end
        
        function R = set.minProbability(R,val)
            assert(prtUtilIsPositiveScalar(val) && val<=1 && val>=0,'minProbability must be a value between 0 and 1 (inclusively)');
            R.minProbabilityDepHelper = val;
        end
        function R = set.maxProbability(R,val)
            assert(prtUtilIsPositiveScalar(val) && val<=1 && val>=0,'maxProbability must be a value between 0 and 1 (inclusively)');
            R.maxProbabilityDepHelper = val;
        end
        
    end
end

