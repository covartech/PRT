function Y = prtRvUtilMvnLogPdf(X,mu,Sigma)
% prtRvUtilMvnLogPdf Multi-variate Normal Log PDF
%
% Syntax: Y = mvnLogPdf(X,mu,Sigma)
%
% Inputs:
%   X - Locations at which to evaluate the log pdf
%   mu - The mean of the MVN distribution
%   Sigma - The covariance matrix of the MVN distribution
%
% Outputs:
%   Y - The value of the log of the pdf at the specified X values
% 







if nargin < 2 || isempty(mu)
    mu = zeros(1,size(X,2));
end

if nargin < 3 || isempty(Sigma)
    Sigma = eye(size(X,2));
end

% Make sure Sigma is a valid covariance matrix
[R,err] = chol(Sigma);
if err ~= 0
    error('prtRvUtilMvnLogPdf:BadCovariance', ...
        'SIGMA must be symmetric and positive definite.');
end

% Create array of standardized data, and compute log(sqrt(det(Sigma)))
xRinv = bsxfun(@minus,X,mu(:)') / R;
logSqrtDetSigma = sum(log(diag(R)));

Y = -0.5*sum(xRinv.^2, 2) - logSqrtDetSigma - length(mu)*log(2*pi)/2;
  
