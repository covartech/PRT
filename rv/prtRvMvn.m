classdef prtRvMvn < prtRv
    % prtRvMvn  Multivariate normal random variable
    %
    %   rv = prtRvMvn; generates the default prt multivariate normal random
    %      variable.
    %
    %   rv = prtRvMvn(X); generates a multivariate normal random variable
    %   using maximum likelihood estimation (mle) based on the data in the
    %   matrix X.  X should be size nObservations x nDimensions.
    %
    %   rv = prtRvMvn(X,paramName1,paramVal1,...) generates a multivariate 
    %   normal random variable using maximum likelihood estimation (mle) 
    %   based on the data in the matrix X.  X should be size 
    %   nObservations x nDimensions. MLE estimation is applied after the
    %   parameter name / value pairs have been parsed.  See below for valid
    %   parameter value pairs.
    %
    %   rv = prtRvMvn(paramName1,paramVal1,...) generates a multivariate 
    %   normal random variable using the parameter name / value pairs have 
    %   specified.  See below for valid parameter / value pairs.
    %
    % Fields (valid parameter names):
    %   covarianceStructure - A string specifying the structure of the
    %   covariance matrix to estimate or enforce; one of 'full',
    %   'spherical', 'diagonal'
    %
    %   mean - The mean of the distribution; a 1 x nDimensions vector.
    %
    %   covariance - The covariance of the distribution - a nDimensions x
    %   nDimensions matrix.
    %   
    % Methods:
    %   mle
    %   pdf
    %   logPdf
    %   cdf
    %   draw
    %
    % Inherited Methods
    %   plotPdf
    %   plotCdf
    
    properties
        covarianceStructure = 'full';
        mean
        covariance
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
            % R = prtRvMvn(X);
            % R = prtRvMvn(X, paramStr1, paramVal1,...);
            % R = prtRvMvn(paramStr1, paramVal1,...);
            
            R.name = 'Multi-Variate Normal';
            R = constructorInputParse(R,varargin{:});
        end
        
        function R = mle(R,X)
            if ~isempty(R.nDimensions)
                warning('prtRvMvn:overwrite','A mean and/or covariance has already been specified for this rv.mvn object. These values have been over written and the dimensionality may have changed.');
            end
            R.mean = mean(X); %#ok
            R.covariance = cov(X);
        end
        
        function vals = pdf(R,X)
            assert(R.isValid,'PDF cannot be evaluated because the RV object is not yet valid.')
            assert(size(X,2) == R.nDimensions,'Incorrect dimensionality for RV object.')
            vals = exp(prtRvUtilMvnLogPdf(X,R.mean,R.covariance));
        end
        
        function vals = logPdf(R,X)
            assert(R.isValid,'LOGPDF cannot be evaluated because the RV object is not yet valid.')
            assert(size(X,2) == R.nDimensions,'Incorrect dimensionality for RV object.')
            vals = prtRvUtilMvnLogPdf(X,R.mean,R.covariance);
        end
        
        function vals = cdf(R,X)
            assert(R.isValid,'CDF cannot be evaluated because the RV object is not yet valid.')
            assert(size(X,2) == R.nDimensions,'Incorrect dimensionality for RV object.')
            vals = prtRvUtilMvnCdf(X,R.mean,R.covariance);
        end
        
        function vals = draw(R,N)
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
            
            kmMembership = kmeans(X,length(Rs),'emptyaction','singleton');
            
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
    end
    
    % Set Methods
    methods
        function R = set.covarianceStructure(R,covarianceStructure)
            % Limit the options for the covariance structure
            if ~(strcmpi(covarianceStructure,'full') || ...
                    strcmpi(covarianceStructure,'diagonal') || ...
                    strcmpi(covarianceStructure,'spherical'))
                error('%s is not a valid covariance structure. Possible types are, full, diagonal, and spherical',covarianceStructure);
            end
            R.covarianceStructure = covarianceStructure;
            
            % Redo the covariance to reflect the updated covarianceStructure
            if ~isempty(R.covariance)
                R.covariance = R.trueCovariance; % This will call set.covariance()
            end
        end
        
        function R = set.mean(R,meanVal)
            if ~isempty(R.covariance) && size(meanVal,2) ~= size(R.covariance,2)
                error('prtRvMvn:dimensions','Dimensions mismatch between supplied mean and prtRvMvn dimensionality');
            end
            R.mean = meanVal;
        end
        
        function R = set.covariance(R,covariance)
            if size(covariance,1) ~= size(covariance,2)
                error('Covariance matrix must be square.')
            end
            
            if ~isempty(R.mean) && size(covariance,1) ~= R.nDimensions
                error('prtRvMvn:dimensions','Dimensions mismatch between covariance and prtRvMvn dimensionality')
            end
            
            [cholCovR, posDefError] = cholcov(covariance,0);
            if posDefError ~= 0
                error('Covariance matrix must be positive definite.')
            end
            
            % Save this input as a true hidden covariance
            R.trueCovariance = covariance;
            
            % Enforce the covariance structure
            switch R.covarianceStructure
                case 'full'
                    R.covariance = covariance;
                case 'diagonal'
                    R.covariance = eye(size(covariance)).*covariance;
                case 'spherical'
                    R.covariance = eye(size(covariance))*mean(diag(covariance)); %#ok
            end
            
            R.covarianceCholDecomp = cholcov(R.covariance,0);
        end
    end
end

