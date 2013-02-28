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
  
