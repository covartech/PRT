function Y = prtRvUtilMvnCdf(X,mu,Sigma)
% prtRvUtilMvnCdf Multi-variate Normal CDF
%
% Syntax: Y = prtRvUtilMvnCdf(X,mu,Sigma)
%
% Inputs:
%   X - Locations at which to evaluate the log pdf
%   mu - The mean of the MVN distribution
%   Sigma - The covariance matrix of the MVN distribution
%
% Outputs:
%   Y - The value of the log of the pdf at the specified X values







if nargin < 2 || isempty(mu)
    mu = 0;
end

if nargin < 3 || isempty(Sigma)
    Sigma = 1;
end


if numel(mu) > 1 || numel(Sigma) > 1 || size(X,2) > 1
    error('prt:prtRvUtilMvnCdf','prtRvUtilMvnCdf only functions for 1D data.');
end

% Change this to not use the stats toolbox at somepoint
Y = prtRvUtilNormCdf(X,mu,Sigma);
