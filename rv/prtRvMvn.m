% PRTRVMVN  PRT Random Variable Object - Multi-Variate Normal
%
% Syntax:
%   R = prtRvMvn
%   R = prtRvMvn(covarianceStructure)
%   R = prtRvMvn(mu,Sigma)
%   R = prtRvMvn(mu,Sigma,covarianceStructure)
%
% Methods:
%   mle
%   pdf
%   logPdf    
%   cdf
%   draw
%   kld
%
% Inherited Methods
%   ezPdfPlot
%   ezCdfPlot

    
classdef prtRvMvn < prtRv
    properties
        covarianceStructure = 'full';
        mean
        covariance
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
        isPlottable
        isValid
        plotLimits
        displayName
    end 
    
    properties (SetAccess = 'private', Hidden = true)
        covarianceCholDecomp
        trueCovariance
    end

    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % The Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function R = prtRvMvn(varargin)
            switch nargin
                case 0
                    % Supply the default object
                case 1
                    if ischar(varargin{1})
                        % R = rv.mvn(covarianceStructure);
                        R.covarianceStructure = varargin{1};
                    else
                        % R = rv.mvn(trainingData);
                        R = mle(prtRvMvn,varargin{1});
                    end
                case 2
                    % R = rv.mvn(mu,Sigma)
                    R.mean = varargin{1}(:)';
                    R.covariance = varargin{2};
                case 3
                    % R = rv.mvn(mu,Sigma,covarianceStructure)
                    R.mean = varargin{1}(:)';
                    R.covariance = varargin{2};
                    R.covarianceStructure = varargin{3};
                otherwise
                    error('Invalid number of input arguments')
            end % switch nargin
        end % function rv.mvn
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Set methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
                R.covariance = R.trueCovariance;
            end
        end % function set.covarianceStructure
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function R = set.mean(R,meanVal)
            if ~isempty(R.covariance) && size(meanVal,2) ~= size(R.covariance,2)
                error('prtRvMvn:dimensions','Dimensions mismatch between supplied mean and rv.mvn dimensionality');
            end
            R.mean = meanVal;
        end % function set.mean
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function R = set.covariance(R,covariance)
            if size(covariance,1) ~= size(covariance,2)
                error('Covariance matrix must be square.')
            end

            if ~isempty(R.mean) && size(covariance,1) ~= R.nDimensions
                error('Dimensions mismatch between covariance and dprtRV dimensionality')
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
             
        end % function set.covariance
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Actually useful methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function R = mle(R,X)
            if ~isempty(R.nDimensions)
                warning('prtRvMvn:overwrite','A mean and/or covariance has already been specified for this rv.mvn object. These values have been over written and the dimensionality may have changed.');
            end
            R.mean = mean(X); %#ok
            R.covariance = cov(X);
        end % function mle
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        function R = weightedMle(R,X,weights)
            assert(size(weights,1)==size(X,1),'The number of weights must mach the number of observations.');

            Nbar = sum(weights);
            R.mean = 1/Nbar*sum(bsxfun(@times,X,weights));
            X = bsxfun(@times,bsxfun(@minus,X,R.mean),sqrt(weights));
            R.covariance = 1/Nbar*X'*X;
        end % function weightedMle
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        function initMembershipMat = initializeMixtureMembership(Rs,X,weights)
            learningInitialMembershipFactor = 0.9;
            if nargin < 3
                weights = ones(size(X,1),1);
            end
            
            kmMembership = kmeans(bsxfun(@times,X,sqrt(weights)),length(Rs));
            
            initMembershipMat = zeros(size(X,1),length(Rs));
            for iComp = 1:length(Rs)
                initMembershipMat(kmMembership == iComp, iComp) = learningInitialMembershipFactor;
            end
            initMembershipMat(initMembershipMat==0) = (1-learningInitialMembershipFactor)./(length(Rs)-1);

            % We should normalize this just in case the learningInitialMembershipFactor was set janky
            initMembershipMat = bsxfun(@rdivide,initMembershipMat,sum(initMembershipMat,2));
        end % function initializeMixtureMembership
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function vals = pdf(R,X)
            assert(R.isValid,'PDF cannot be evaluated because this RV object is not yet valid.')
            assert(size(X,2) == R.nDimensions,'Incorrect dimensionality for RV object.')
            vals = exp(prtRvUtilMvnLogPdf(X,R.mean,R.covariance));
        end % function pdf
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function vals = logPdf(R,X)
            assert(R.isValid,'LOGPDF cannot be evaluated be RV object is not yet valid.')
            assert(size(X,2) == R.nDimensions,'Incorrect dimensionality for RV object.')            
            vals = prtRvUtilMvnLogPdf(X,R.mean,R.covariance);
        end % function pdf
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function vals = cdf(R,X)
            assert(R.isValid,'CDF cannot be evaluated be RV object is not yet valid.')
            assert(size(X,2) == R.nDimensions,'Incorrect dimensionality for RV object.')            
            vals = mvncdf(X,R.mean,R.covariance);
        end % function cdf
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function vals = draw(R,N)
            vals = mvnrnd(R.mean,R.covariance,N);
        end % function draw
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = kld(R1,R2)
            if isa(R2,'prtRvMvn')
                val = prtRvUtilMvnKLD(R1.mean,R1.covariance,R2.mean,R2.covariance);
            else
                error('prtRvMvn:kld','Kullback Liebler divergence can only be calculated between similar RV objects. This limitation may be removed in a future relesase.')
            end
        end % function kld
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = get.isValid(R)
            val = ~isempty(R.covariance) && ~isempty(R.mean);
        end % function get.isValid
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = get.isPlottable(R)
            val = ~isempty(R.nDimensions) && R.nDimensions < 4 && R.isValid;
        end % function get.isPlottable
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = get.nDimensions(R)
            if ~isempty(R.mean)
                val = length(R.mean);
            elseif ~isempty(R.covariance)
                val = size(R.covariance,2);
            else
                val = [];
            end
        end % function get.nDimensions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = get.plotLimits(R)
            if R.isValid
                minX = min(R.mean, [], 1)' - 2*sqrt(diag(R.covariance));
                maxX = max(R.mean, [], 1)' + 2*sqrt(diag(R.covariance));
                
                val = zeros(1,2*R.nDimensions);
                val(1:2:R.nDimensions*2-1) = minX;
                val(2:2:R.nDimensions*2) = maxX;
            else
                error('prtRvMvn:plotLimits','Plotting limits can no be determined for this RV because it is not yet valid.')
            end
        end % function plotLimits
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function display(R)
            if numel(R) == 1
                display(struct('mean',R.mean,'covariance',R.covariance))
            else
                display@prtRv(R,inputname(1));
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = get.displayName(R) %#ok
            val = 'Multi-Variate Normal Random Variable';
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end % methods
end % classdef

