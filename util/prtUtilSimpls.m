function [Bpls, R, P, Q, T, U, V] = prtUtilSimpls(X,Y,nComponents)
% PRTUTILSIMPLS performs partial least squares regression using the SIMPLS
% algorithm.
%
% See: De Jong, S. 1993. SIMPLS: an alternative approach to partial least
%      squares regression. Chemometrics and intelligen Laboratory Systems,
%      18: 251-563
%
% http://www.sciencedirect.com/science?_ob=ArticleURL&_udi=B6TFP-44GGKFD-89&_user=38557&_rdoc=1&_fmt=&_orig=search&_sort=d&_docanchor=&view=c&_searchStrId=1090189883&_rerunOrigin=google&_acct=C000004358&_version=1&_urlVersion=0&_userid=38557&md5=ea492b3c33a94f652d43d04707199e68
%
% Syntax: [Bpls, R, P, Q, T, U] = prtUtilSimpls(X,Y,nComponents)
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
R = zeros(nDimensions,nVectors);
P = R;
V = P;
Q = zeros(size(Y,2),nVectors);
T = zeros(nSamples,nVectors);
U = T;

S = X'*Y;
for iVec = 1:nVectors
    % SVD. This is a little wasteful since we only need the first one. But
    % SVD is very fast so it doesn't really matter
    [r,dontNeed,dontNeed] = svd(S,'econ'); %#ok<ASGLU,NASGU>
    
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
