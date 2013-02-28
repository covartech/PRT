function [PCSCORE, COEFF, eigenvalues] = prtUtilPcaHd(X,nFeaturesOut)
%[PCSCORE, COEFF] = prtUtilPcaHd(X,nFeaturesOut)
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
if nargin < 2 || isempty(nFeaturesOut)

    nFeaturesOut = size(X,2);
end

N = size(X,1);
[V, L] = eig((1/N)*(X*X'));

[lambda, sortedLInd] = sort(diag(L),'descend');
V = V(:,sortedLInd);

if nFeaturesOut < 1
    percentEnergy = cumsum(lambda)./sum(lambda);
    nFeaturesOut = find(percentEnergy > nFeaturesOut,1,'first');
end

COEFF = zeros(size(X,2),nFeaturesOut);
for iL = 1:nFeaturesOut
    COEFF(:,iL) = 1/((N*lambda(iL))^(1/2))*X'*V(:,iL);
end

eigenvalues = lambda;
PCSCORE =  X*real(COEFF);
