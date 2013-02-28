function y = prtRvUtilStudentTLogPdf(x,mu,Sigma,dof)
% y = prtRvUtilStudentTLogPdf(x,mu,Sigma,dof)

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


[n, d] = size(x);

c = gammaln((d+dof)*0.5) - (d*0.5)*log(dof*pi) - gammaln(dof*0.5) - 0.5*prtUtilLogDet(Sigma);

diff = bsxfun(@minus,x,mu);

logpdf = c - (dof+d)*0.5 * log(1 + (1/dof)*sum((diff/chol(Sigma)).^2,2));
%logpdf = c - (dof+d)*0.5 * log(1 + sum(diff.*(inv(dof*Sigma)*diff),1));

y = logpdf(:);
