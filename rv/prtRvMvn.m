classdef prtRvMvn < prtRv
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
    %   mean                - The mean of the distribution, which is
    %                         a 1 x nDimensions vector.
    %   covariance          - The covariance matrix of the distribution,
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
    %  RVspec.mean = [1 2];                 % Specify the mean
    %  RVspec.covariance = [2 -1; -1 2]     % Specify the covariance
    %  figure;
    %  RVspec.plotPdf                       % Plot the pdf
    %  sample = RVspec.draw(1)              % Draw 1 random sample from the
    %                                       % Distribution
    %
    %   See also: prtRv, prtRvGmm, prtRvMultinomial, prtRvUniform,
    %   prtRvUniformImproper, prtRvVq
    

    
    properties (Dependent)
        covarianceStructure  % The covariance structure
        mean                 % The mean vector
        covariance           % The covariance matrix
    end
    properties (SetAccess = 'private', GetAccess = 'private', Hidden = true)
        meanDepHelper
        covarianceDepHelper
        covarianceStructureDepHelper = 'full';
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
    end
    
    properties (SetAccess = 'private', Hidden = true)
        covarianceCholDecomp
        trueCovariance
    end
    
    methods
        function R = prtRvMvn(varargin)
            
            R.name = 'Multi-Variate Normal';
            R = constructorInputParse(R,varargin{:});
        end
        
        function R = mle(R,X)
            % MLE Compute the maximum likelihood estimate 
            %
            % RV = RV.mle(X) computes the maximum likelihood estimate based
            % the data X. X should be nObservations x nDimensions.
            
            X = R.dataInputParse(X); % Basic error checking etc
            
            R.mean = mean(X);
            R.covariance = cov(X);
        end
        
        function vals = pdf(R,X)
            % PDF Output the pdf of the random variable evaluated at the points specified
            %
            % pdf = RV.pdf(X) returns  the pdf of the prtRv
            % object evaluated at X. X must be an N x nDims matrix, where
            % N is the number of locations to evaluate the pdf, and nDims
            % is the same as the number of dimensions, nDimensions, of the
            % prtRv object RV.
            
            assert(R.isValid,'PDF cannot be evaluated because the RV object is not yet valid.')
            
            X = R.dataInputParse(X); % Basic error checking etc
            
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
            assert(isnumeric(X) && ndims(X)==2,'X must be a 2D numeric array.');
            
            vals = exp(prtRvUtilMvnLogPdf(X,R.mean,R.covariance));
        end
        
        function vals = logPdf(R,X)
            % LOGPDF Output the log pdf of the random variable evaluated at the points specified
            %
            % logpdf = RV.logpdf(X) returns the logarithm of value of the
            % pdf of the prtRv object evaluated at X. X must be an N x
            % nDims matrix, where N is the number of locations to evaluate
            % the pdf, and nDims is the same as the number of dimensions,
            % nDimensions, of the prtRv object RV.
            assert(R.isValid,'LOGPDF cannot be evaluated because the RV object is not yet valid.')
            
            X = R.dataInputParse(X); % Basic error checking etc
            
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
            vals = prtRvUtilMvnLogPdf(X,R.mean,R.covariance);
        end
        
        function varargout = plotCdf(R,varargin)
            
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
            
            assert(R.isValid,'CDF cannot be evaluated because the RV object is not yet valid.')
            
            X = R.dataInputParse(X); % Basic error checking etc
            
            assert(size(X,2) == R.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), R.nDimensions)
            vals = prtRvUtilMvnCdf(X,R.mean,R.covariance);
        end
        
        function vals = draw(R,N)
            % DRAW  Draw random samples from the distribution described by the prtRv object
            %
            % VAL = RV.draw(N) generates N random samples drawn from the
            % distribution described by the prtRv object RV. VAL will be a
            % N x nDimensions vector, where nDimensions is the number of
            % dimensions of RV.
            
            assert(numel(N)==1 && N==floor(N) && N > 0,'N must be a positive integer scalar.')
            vals = prtRvUtilMvnDraw(R.mean,R.covariance,N);
        end
    end
    
    methods (Hidden=true)
        function val = isValid(R)
            val = false(size(R));
            for iR = 1:numel(R)
                val(iR) = ~isempty(R(iR).covariance) && ~isempty(R(iR).mean);
            end
        end
        function val = plotLimits(R)
            if R.isValid
                minX = min(R.mean, [], 1)' - 2*sqrt(diag(R.covariance));
                maxX = max(R.mean, [], 1)' + 2*sqrt(diag(R.covariance));
                
                val = zeros(1,2*R.nDimensions);
                val(1:2:R.nDimensions*2-1) = minX;
                val(2:2:R.nDimensions*2) = maxX;
            else
                error('prtRvMvn:plotLimits','Plotting limits can no be determined for this RV because it is not yet valid.')
            end
        end
        
        function R = weightedMle(R,X,weights)
            assert(numel(weights)==size(X,1),'The number of weights must mach the number of observations.');
            
            weights = weights(:);
            
            Nbar = sum(weights);
            R.mean = 1/Nbar*sum(bsxfun(@times,X,weights));
            X = bsxfun(@times,bsxfun(@minus,X,R.mean),sqrt(weights));
            R.covariance = 1/Nbar*(X'*X);
        end
        
        function initMembershipMat = initializeMixtureMembership(Rs,X)
            
            learningInitialMembershipFactor = 0.9;
            
            [classMeans,kmMembership] = prtUtilKmeans(X,length(Rs),'handleEmptyClusters','random'); %#ok<ASGLU>
            
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
            if ~isempty(R.mean)
                val = length(R.mean);
            elseif ~isempty(R.covariance)
                val = size(R.covariance,2);
            else
                val = [];
            end
        end
        
        function val = get.mean(R)
            val = R.meanDepHelper;
        end
        function val = get.covariance(R)
            val = R.covarianceDepHelper;
        end
        function val = get.covarianceStructure(R)
            val = R.covarianceStructureDepHelper;
        end
    end
    
    % Set Methods
    methods
        function R = set.covarianceStructure(R,covarianceStructure)
            % Find and fix known abbreviations
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
            if ~isempty(R.covariance)
                R.covariance = R.trueCovariance; % This will call set.covariance()
            end
        end
        
        function R = set.mean(R,meanVal)
            if ~isempty(R.covariance) && size(meanVal,2) ~= size(R.covariance,2)
                error('prtRvMvn:dimensions','Dimensions mismatch between supplied mean and prtRvMvn dimensionality');
            end
            R.meanDepHelper = meanVal;
        end
        
        function R = set.covariance(R,covariance)
            if size(covariance,1) ~= size(covariance,2)
                error('Covariance matrix must be square.')
            end
            
            if ~isempty(R.mean) && size(covariance,1) ~= R.nDimensions
                error('prtRvMvn:dimensions','Dimensions mismatch between covariance and prtRvMvn dimensionality')
            end
            
            [cholCovR, posDefError] = cholcov(covariance,0); %#ok<ASGLU>
            if posDefError ~= 0
                error('Covariance matrix must be positive definite.')
            end
            
            % Save this input as a true hidden covariance
            R.trueCovariance = covariance;
            
            % Enforce the covariance structure
            switch R.covarianceStructure
                case 'full'
                    R.covarianceDepHelper = covariance;
                case 'diagonal'
                    R.covarianceDepHelper = eye(size(covariance)).*covariance;
                case 'spherical'
                    R.covarianceDepHelper = eye(size(covariance))*mean(diag(covariance));
            end
            
            R.covarianceCholDecomp = cholcov(R.covariance,0);
        end
    end
end

