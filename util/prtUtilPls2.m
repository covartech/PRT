function [Bpls, W, P, Q, T, U, B, xMeans, yMeans] = prtUtilPls2(X,Y,nComponents)
%[Bpls, R, P, Q, T, U, xMeans, yMeans] = prtUtilPls2(X,Y,nComponents)
% 
%   An alternative to SIMPLS, PLS2 as developed in:
%       Department of Statistics
%       ST02: Multivariate Data Analysis and Chemometrics
%       Bent Jørgensen and Yuri Goegebeur
%   http://statmaster.sdu.dk/courses/ST02






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
