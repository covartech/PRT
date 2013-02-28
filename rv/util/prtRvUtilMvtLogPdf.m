function y = prtRvUtilMvtLogPdf(x,mu,Sigma,dof)
% y = prtRvUtilMvtLogPdf(x,mu,Sigma,dof)
% xxx Need Help xxx

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


d = size(x,2);

[R,err] = cholcov(Sigma,0);
if err ~= 0
    error('mvtLogPdf:BadCovariance', ...
        'SIGMA must be symmetric and positive definite.');
end

% Create array of standardized data
xRinv = bsxfun(@minus,x,mu(:)') / R;

c = gammaln((d+dof)*0.5) - (d*0.5)*log(dof*pi) - gammaln(dof*0.5) - 0.5*log(det(Sigma));

y = c - (dof+d)*0.5*log(1 +1/dof*sum(xRinv.^2, 2));
