function y = prtRvUtilNormPdf(X,mu,sigma)
%Y = prtRvUtilNormPdf(X,mu,sigma)
%Y = prtRvUtilNormPdf(X)
%Y = prtRvUtilNormPdf(X,mu)

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


% Test Drop in replacement of normpdf from stats toolbox
% X = randn([2 3 3]); mu = 1; sigma = 2; prtUtilApproxEqual(prtRvUtilNormPdf(X,mu,sigma),normpdf(X,mu,sigma))

if nargin < 2 %|| isempty(mu) % normpdf returns [] if mu is []
    mu = 0;
end

if nargin < 3 %|| isempty(sigma) % normpdf returns [] if sigma is []
    sigma = 1;
end

xSize = size(X);

y = reshape(exp(prtRvUtilMvnLogPdf(X(:), mu, sigma.^2)),xSize);

