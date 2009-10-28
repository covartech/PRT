function [Bpls, W, b, P, C, T] = prtUtilPartialLeastSquares(X,Y,nComponents)

% Syntax: [Bpls, b, P, C] = partialLeastSquares(X,Y)
%
% Inputs:
%   X - Predictors data matrix
%   Y - Dependent data matrix or labels
%
% Outputs:
%   Bpls - The weights forming the linear regression line(s)
%   projectionMatrix - Matrix projecting X into lower-dimensional space
%   b - A vector of the energy of each term
%   P - X Loading matrix
%   C - Weigt matrix
%
% Example
%   See dprtPreProcessPls.m
%
% Other m-files required: DPRT
% Subfunctions: none
% MAT-files required: none

% See: Abidi, Herve.  Partial Least Square Regression PLS-Regression.
% Encycolpedia of Measurement and Statistics.  2007.

% Author: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 05-May-2008

warning('This works for classification but has issues with scaling in regression. This function is dead. See dprtUtilPls - Kenny');

E = X;
F = Y;

[nSamples, nDimensions] = size(X);

if nargin < 3
    nVectors = nDimensions;
else
    nVectors = nComponents;
end  

maxIterations = 1000;
convergenceThreshold = 1e-6;

U = zeros(nSamples,nVectors);
T = U;
C = zeros(size(Y,2),nVectors);
W = zeros(nDimensions,nVectors);
P = W;
b = zeros(nVectors,1);

%For notation see: Abidi, Herve.  Partial Least Square Regression PLS-Regression.
% Encycolpedia of Measurement and Statistics.  2007.

for iVec = 1:nVectors
    u = randn(nSamples,1);
    u = u./norm(u);
    for iter = 1:maxIterations
        w = E'*u;
        w = w./norm(w);
        t = E*w;
        t = t./norm(t);
        c = F'*t;
        c = c./norm(c);
        u = F*c;
        u = u./norm(u);
    
        if iter > 1 && norm(t-prevT) < convergenceThreshold
            break
        end
        prevT = t;
    end
    
    b(iVec) = t'*u;
    p = E'*t;
    
    % Remove the effect of this term.
	E = E - t*p';
    F = F - b(iVec)*t*c';
    
    U(:,iVec) = u;
    T(:,iVec) = t;
    C(:,iVec) = c;
    W(:,iVec) = w;
    P(:,iVec) = p;
end

Bpls = pinv(P')*diag(b)*C';
