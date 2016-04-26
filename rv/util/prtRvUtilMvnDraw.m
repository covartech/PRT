function X = prtRvUtilMvnDraw(mu,Sigma,N)
% prtRvUtilMvnDraw - Draw from a Multivariate Normal Distribution 
%
%   X = prtRvUtilMvnDraw(mu,Sigma,N)
%
%   Inputs:
%       mu    - mean vector, indicates the dimensionality of the MVN
%       Sigma - Can be either a square covariance matrix or a vector
%               specifiying the diagonal values of the covariance matrix.
%       N     - A positive integer specifying the number of samples to
%               draw.
%   Outputs:
%       X     - Double matrix of drawn values.







if nargin < 3 || isempty(N)
    N = 1;
else
    assert(numel(N)==1 && prtUtilIsPositiveInteger(N) ,'N must be a scalar positive integer');
end

if nargin < 1 || isempty(mu)
    mu = 0;
end

if nargin < 2 || isempty(Sigma)
    Sigma = ones(numel(mu),1);
end

if isvector(Sigma)
    % Diagonal sigma defined
    assert(numel(Sigma)==numel(mu),'Dimensionality of mu and Sigma must match');
    mu = mu(:);
    X = zeros(N,numel(mu));
    for iDim = 1:length(mu)
        X(:,iDim) = sqrt(Sigma(iDim))*randn([N, 1]) + mu(iDim);
    end
else
    % General covariance matrix
    assert(size(Sigma,1) == size(Sigma,2),'Sigma must be a square covariance matrix or a vector of diagonal entries');
	assert(size(Sigma,1)==numel(mu),'Dimensionality of mu and Sigma must match');
    
    [R, err] = chol(Sigma);
    if err ~= 0
        error('prtRvUtilMvnDraw:BadCovariance', ...
            'Sigma must be symmetric and positive definite.');
    end

    X = bsxfun(@plus,randn([N, numel(mu)])*R,mu(:)');
end
