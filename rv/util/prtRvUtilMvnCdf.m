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


% Change this to not use the stats toolbox at somepoint
Y = mvncdf(X,mu,Sigma);