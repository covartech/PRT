classdef prtRvMvn < prtRv & prtRvMemebershipModel
    % prtRvMvn  Multivariate normal random variable
    %
    %   RV = prtRvMvn creates a prtRvMvn object with empty mean and
    %   covariance matrices. The mean and covariance matrices must be set
    %   either directly, or by calling the MLE method.
    %
    %   RV = prtRvMvn('covarianceStructure', VALUE) enforces a covariance
    %   structure, which may be either 'full', 'spherical', or 'diagonal'.
    %   Setting this property to 'spherical' or 'diagonal' will enforce
    %   this structure onto the existing covariance matrix, or one
    %   estimated by calling the MLE method.
    %
    %   RV = prtRvMvn(PROPERTY1, VALUE1,...) creates a prtRvMv object RV
    %   with properties as specified by PROPERTY/VALUE pairs.
    %
    %   A prtRvMvn object inherits all properties from the prtRv class. In
    %   addition, it has the following properties:
    %
    %   covarianceStructure - A string specifying the structure of the
    %                         covariance matrix to estimate or enforce. 
    %                         Valid values are 'full','spherical', or 
    %                         'diagonal'
    %   mu                  - The mean of the distribution, which is
    %                         a 1 x nDimensions vector.
    %   sigma               - The covariance matrix of the distribution,
    %                         which is a nDimensions x nDimensions 
    %                         matrix.
    %   
    %  A prtRvMvn object inherits all methods from the prtRv class. The MLE
    %  method can be used to estimate the distribution parameters from
    %  data.
    %
    %  Example:
    %
    %  dataSet    = prtDataGenUnimodal;   % Load a dataset consisting of 2
    %                                     % classes
    %  % Extract one of the classes from the dataSet
    %  dataSetOneClass = prtDataSetClass(dataSet.getObservationsByClass(1));
    %
    %  RV = prtRvMvn;                       % Create a prtRvMvn object
    %  RV = RV.mle(dataSetOneClass.getX);   % Compute the maximum
    %                                       % likelihood estimate from the
    %                                       % data
    %  RV.plotPdf                           % Plot the pdf
    %
    %  RVspec = prtRvMvn;                   % Create another prtRvMvn
    %                                       % object
    %  RVspec.mu = [1 2];                   % Specify the mean
    %  RVspec.sigma = [2 -1; -1 2]          % Specify the covariance
    %  figure;
    %  RVspec.plotPdf                       % Plot the pdf
    %  sample = RVspec.draw(1)              % Draw 1 random sample from the
    %                                       % Distribution
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


    properties (SetAccess = 'private')
        name = 'Multi-Variate Normal';
        nameAbbreviation = 'RVMVN';
    end
    
    properties (SetAccess = 'protected')
        isSupervised = false;
        isCrossValidateValid = true;
    end
    
    properties (Dependent)
        covarianceStructure  % The covariance structure
        mu                   % The mean vector
        sigma                % The covariance matrix
    end
    properties (SetAccess = 'private', GetAccess = 'private', Hidden = true)
        muDepHelper
        sigmaDepHelper
        covarianceStructureDepHelper = 'full';
    end
    
    properties (Hidden = true)
        covarianceBias = [];
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
    end
    
    properties (SetAccess = 'private', Hidden = true)
        trueCovariance
        badCovariance = false;
    end
    
    methods
        function R = prtRvMvn(varargin)
            R = constructorInputParse(R,varargin{:});
        end
        
        function R = mle(R,X)
           % MLE Compute the maximum likelihood estimate 
            %
            % RV = RV.mle(X) computes the maximum likelihood estimate based
            % the data X. X should be nObservations x nDimensions.        

            X = R.dataInputParse(X); % Basic error checking etc
            
            R.mu = mean(X,1);
            if size(X,1) == 1 
                % A single observation
                % This is bad..
                % You can't call cov for this case 
                % Since we always want to output sum( (x_i - u)'*(x_i - u))
                % We will output a matrix of zeros of the correct size.
                % Error checking for a propert covariance will happen later
                % after the bias has been applied.
                R.sigma = zeros(size(X,2));
            else
                R.sigma = cov(X);
            end
            
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
            
            assert(~R.badCovariance,'Covariance matrix is not positive definite. Consider modifying "covarianceStructure".');
            X = R.dataInputParse(X); % Basic error checking etc
            
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
            assert(isnumeric(X) && ndims(X)==2,'X must be a 2D numeric array.');
            
            vals = exp(prtRvUtilMvnLogPdf(X,R.mu,R.sigma));
        end
        
        function vals = logPdf(R,X)
            % LOGPDF Output the log pdf of the random variable evaluated at the points specified
            %
            % logpdf = RV.logpdf(X) returns the logarithm of value of the
            % pdf of the prtRv object evaluated at X. X must be an N x
            % nDims matrix, where N is the number of locations to evaluate
            % the pdf, and nDims is the same as the number of dimensions,
            % nDimensions, of the prtRv object RV.
            
            X = R.dataInputParse(X); % Basic error checking etc
            try
               vals = prtRvUtilMvnLogPdf(X,R.mu,R.sigma);
            catch ME
                [isValid, reasonStr] = R.isValid;
                assert(isValid,'LOGPDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
                assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
                throw(ME);
            end
        end
        
        function varargout = plotCdf(R,varargin)
            % PLOTCDF Plots the CDF of the prtRv
            assert(R.nDimensions == 1,'prtRvMvn.plotCdf can only be used for 1D RV objects.');
            
            varargout = cell(nargout,1); 
            
            [varargout{:}] = plotCdf@prtRv(R,varargin{:});
                
        end
        
        function vals = cdf(R,X)
            % CDF Output the cdf of the random variable evaluated at the points specified
            %
            % cdf = RV.cdf(X) returns the value of the cdf of the prtRv
            % object evaluated at X. X must be an N x nDims matrix, where
            % N is the number of locations to evaluate the pdf, and nDims
            % is the same as the number of dimensions, nDimensions, of the
            % prtRv object RV.
            
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'CDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            assert(~R.badCovariance,'Covariance matrix is not positive definite. Consider modifying "covarianceStructure"');
            X = R.dataInputParse(X); % Basic error checking etc
            
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
            vals = prtRvUtilMvnCdf(X,R.mu,R.sigma);
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
            
            assert(~R.badCovariance,'Covariance matrix is not positive definite. Consider modifying "covarianceStructure"');
            vals = prtRvUtilMvnDraw(R.mu,R.sigma,N);
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
            
            val = ~isempty(R.sigma) && ~isempty(R.mu);
            
            if val
                reasonStr = '';
            else
                badCov = isempty(R.sigma);
                badMean = isempty(R.mu);
                
                if badCov && ~badMean
                    reasonStr = 'because sigma has not been set';
                elseif ~badCov && badMean
                    reasonStr = 'because mu has not been set';
                elseif badCov && badMean
                    reasonStr = 'because mu and sigma have not been set';
                else
                    reasonStr = 'because of an unknown reason';
                end
            end
        end
        
        function val = plotLimits(R)
            [isValid, reasonStr] = R.isValid;
            if isValid
                minX = min(R.mu, [], 1)' - 2*sqrt(diag(R.sigma));
                maxX = max(R.mu, [], 1)' + 2*sqrt(diag(R.sigma));
                
                val = zeros(1,2*R.nDimensions);
                val(1:2:R.nDimensions*2-1) = minX;
                val(2:2:R.nDimensions*2) = maxX;
            else
                error('prtRvMvn:plotLimits','Plotting limits can not be determined for this RV. It is not yet valid %s',reasonStr)
            end
        end
        
        function R = weightedMle(R,X,weights)
            assert(numel(weights)==size(X,1),'The number of weights must mach the number of observations.');
            
            weights = weights(:);
            
            Nbar = sum(weights);
            R.mu = 1/Nbar*sum(bsxfun(@times,X,weights),1);
            X = bsxfun(@times,bsxfun(@minus,X,R.mu),sqrt(weights));
            R.sigma = 1/Nbar*(X'*X);
        end
    end
    
    % Get methods
    methods
        function val = get.nDimensions(R)
            val = getNumDimensions(R);
        end
        
        function val = get.mu(R)
            val = R.muDepHelper;
        end
        function val = get.sigma(R)
            val = R.sigmaDepHelper;
        end
        function val = get.covarianceStructure(R)
            val = R.covarianceStructureDepHelper;
        end
    end
    methods (Access = 'protected')
        function val = getNumDimensions(R)
            if ~isempty(R.mu)
                val = length(R.mu);
            elseif ~isempty(R.sigma)
                val = size(R.sigma,2);
            else
                val = [];
            end
        end
    end
    % Set Methods
    methods
        function R = set.covarianceStructure(R,covarianceStructure)
            % Find and fix known abbreviations
            
            assert(ischar(covarianceStructure),'covarianceStructure must be a string that is either, full, diagonal, or spherical');
            
            covarianceStructure = lower(covarianceStructure);
            
            if strcmpi(covarianceStructure,'diag')
                covarianceStructure = 'diagonal';
            end
            
            % Limit the options for the covariance structure
            if ~(strcmpi(covarianceStructure,'full') || ...
                    strcmpi(covarianceStructure,'diagonal') || ...
                    strcmpi(covarianceStructure,'spherical'))
                error('%s is not a valid covariance structure. Possible types are, full, diagonal, and spherical',covarianceStructure);
            end
            R.covarianceStructureDepHelper = covarianceStructure;
            
            % Redo the covariance to reflect the updated covarianceStructure
            if ~isempty(R.sigma)
                R.sigma = R.trueCovariance; % This will call set.sigma()
            end
        end
        
        function R = set.mu(R,meanVal)
            if ~isempty(R.sigma) && size(meanVal,2) ~= size(R.sigma,2)
                error('prtRvMvn:dimensions','Dimensions mismatch between supplied mu and prtRvMvn dimensionality');
            end
            R.muDepHelper = meanVal;
        end
        
        function R = set.sigma(R,sigma)
            if size(sigma,1) ~= size(sigma,2)
                error('Covariance matrix must be square.')
            end
            
            if ~isempty(R.mu) && size(sigma,1) ~= R.nDimensions
                error('prtRvMvn:dimensions','Dimensions mismatch between sigma and prtRvMvn dimensionality')
            end

            % Save this input as a true hidden sigma
            R.trueCovariance = sigma;
            
            % Enforce the covariance structure
            switch lower(R.covarianceStructure)
                case 'full'
                    R.sigmaDepHelper = sigma;
                case 'diagonal'
                    R.sigmaDepHelper = eye(size(sigma)).*sigma;
                case 'spherical'
                    R.sigmaDepHelper = eye(size(sigma))*mean(diag(sigma));
            end
            
            if ~isempty(R.covarianceBias)
                R.sigmaDepHelper = R.sigmaDepHelper + R.covarianceBias.*eye(size(sigma));
            end
            
            [dontNeed, cholErr] = chol(R.sigmaDepHelper); %#ok<ASGLU>
            if cholErr ~=0
                R.badCovariance = true;
                warning('prt:prtRvMvn','Covariance matrix is not positive definite. This may cause errors. Consider modifying "covarianceStructure".');
            end
        end
    end
end

