function [Bpls, R, P, Q, T, U] = prtUtilNipalsSparse(X,Y,nComponents)
% PRTUTILNIPALSSPARSE performs partial least squares regression using the 
% Sprase SIMPLS algorithm.
%
% See: Chun and Keles, 2010. Sparse partial least squares regression for
%      simultaneous dimension reduction and variable selection. Journal of
%      the Royal Statistical Society, Series B. 72, Part1 pp.3-25.
%
% Syntax: [Bpls, R, P, Q, T, U] = prtUtilNipalsSparse(X,Y,nComponents)
%
% Inputs:
%   X - Predictors data matrix - Assumed to be demeaned
%   Y - Dependent data matrix or labels - Assumed to be demeaned
%
% Outputs:
%   Bpls - The weights   Y approx= X*Bpls
%   W - XY Covariance decomposition
%   P - X Loadings
%   Q - Y Loadings
%   T - X Scores
%   U - Y Scores
%

% Copyright 2011, New Folder Consulting, L.L.C.

[nSamples, nDimensions] = size(X);

if nargin < 3
    nVectors = nDimensions;
else
    nVectors = nComponents;
end  

kappa = 1/4; %(0, 1/2) exclusive

kappaPrime = (1-kappa)/(1-2*kappa);

% Initializations
% R = zeros(nDimensions,nVectors);
% P = R;
% V = P;
% Q = zeros(size(Y,2),nVectors);
% T = zeros(nSamples,nVectors);
% U = T;

% S = X'*Y;
for iVec = 1:nVectors
    
    %Z = X'*Y;
    keyboard
    
    % SVD. This is a little wasteful since we only need the first one. But
    % SVD is very fast so it doesn't really matter
    [r,dontNeed,dontNeed] = svd(S,'econ');
    
    r = r(:,1); % We only need the first solution

    t = X*r; % the current score for X
    t = t - mean(t);
    normT = norm(t);
    t = t./normT;
    r = r./normT;
    p = X'*t; % the current loadings for X
    q = Y'*t; % the current loadings for Y
    u = Y*q; % the current scores for Y

    % To deflate S project onto the normalized V 
    % We need to make sure that V is really orthogonal
    % This is simple Gram-Schimdt
    v = p;
    if iVec > 1
        v = v - V(:,1:(iVec-1))*(V(:,1:(iVec-1)).'*v);
        u = u - T(:,1:(iVec-1))*(T(:,1:(iVec-1)).'*u);
    end
    v = v ./ norm(v);

    % Deflate S
    S = S - v*(v'*S);
    
    % Save everything
    R(:,iVec) = r; % X,Y Covariance Orthogonal Decomposition
    P(:,iVec) = p; % X Loadings
    Q(:,iVec) = q; % Y Loadings
    T(:,iVec) = t; % X Scores
    U(:,iVec) = u; % Y Scores
    V(:,iVec) = v; % Normalized X Loadings
end

Bpls = R*Q'; % Regression Weights