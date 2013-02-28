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
