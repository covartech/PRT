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
