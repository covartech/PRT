function [Bpls, W, P, Q, T] = prtUtilPls(DataSet,nComponents)
% prtUtilPls performs partial least squares regression
%   This does not sphere the data first.
%
% Syntax: [Bpls, W, P, Q, T] = partialLeastSquares(X,Y)
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

X = DataSet.getObservations;
Y = DataSet.getTargets;

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

T = zeros(nSamples,nVectors);
U = T;
Q = zeros(size(Y,2),nVectors);
C = Q;
W = zeros(nDimensions,nVectors);
P = W;

%For notation see: Abidi, Herve.  Partial Least Square Regression PLS-Regression.
% Encycolpedia of Measurement and Statistics.  2007.

for iVec = 1:nVectors
    u = randn(nSamples,1);
    u = u./norm(u);
    for iter = 1:maxIterations
        w = E'*u;
        w = w./norm(w);
        t = E*w;
        normT = norm(t);
        t = t./normT;
        c = F'*t;
        c = c./norm(c);
        u = F*c;
        u = u./norm(u);
    
        if iter > 1 && norm(t-prevT) < convergenceThreshold
            break
        end
        prevT = t;
    end

    p = E'*t; % the current loadings for X % or p = X'*t % amazingly the same
    q = F'*t; % the current loadings for Y % or q = Y'*t % amazingly the same
    
    % Remove the effect of this term. 
	E = E - t*p';
    F = F - t*q';

    % Save everything
    U(:,iVec) = u;
    T(:,iVec) = t;
    C(:,iVec) = c;
    Q(:,iVec) = q;
    W(:,iVec) = w./normT; % To get proper scaling.
    P(:,iVec) = p;
end


Bpls = W*Q';
