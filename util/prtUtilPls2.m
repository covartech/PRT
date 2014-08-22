function [Bpls, W, P, Q, T, U, B, xMeans, yMeans] = prtUtilPls2(X,Y,nComponents)
%[Bpls, R, P, Q, T, U, xMeans, yMeans] = prtUtilPls2(X,Y,nComponents)
% 
%   An alternative to SIMPLS, PLS2 as developed in:
%       Department of Statistics
%       ST02: Multivariate Data Analysis and Chemometrics
%       Bent Jørgensen and Yuri Goegebeur
%   http://statmaster.sdu.dk/courses/ST02

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

[nSamples, nDimensions] = size(X);

if nargin < 3
    nVectors = nDimensions;
else
    nVectors = nComponents;
end

% Initializations
xMeans = mean(X);
yMeans = mean(Y);
X = bsxfun(@minus,X,xMeans);
Y = bsxfun(@minus,Y,yMeans);

W = nan(size(X,2),nVectors);
T = nan(size(X,1),nVectors);
Q = nan(size(Y,2),nVectors);
U = nan(size(X,1),nVectors);
P = nan(size(X,2),nVectors);
B = zeros(nVectors,nVectors);

for iVec = 1:nVectors
    
    u = Y(:,ceil(rand*size(Y,2)));
    err = nan(1,1000);
    for iter = 1:1000;
        w = X'*u;
        w = w./norm(w);
        t = X*w;
        q = Y'*t;
        q = q./norm(q);
        
        uEst = Y*q;
        err(iter) = norm(u-uEst)./length(u);
        if err < eps
            break;
        end
    end
    b = t'*u./(t'*t);
    p = X'*u./(t'*t);
    
    X = X - t*p';
    Y = Y - b*t*q';
    
    W(:,iVec) = w;
    T(:,iVec) = t;
    Q(:,iVec) = q;
    U(:,iVec) = u;
    P(:,iVec) = p;
    B(iVec,iVec) = b;    
end

Bpls = W*B*Q';
% xOrig = bsxfun(@minus,xOrig,xMeans);
% yHat = xOrig*Bpls;
% yHat = bsxfun(@plus,yHat,yMeans);
% ds = prtDataSetClass(yHat,yOrig);
% prtScoreRoc(ds);