function KLD = prtRvUtilMvnKld(muQ,SigmaQ,muP,SigmaP)
% MVNKLD  Kulback Liebler Divergence between two Normal densities
%       KLD(Q||P)
%
%   KL-Divergence of Normal, Gamma, Dirichlet and Wishart densities
%      Penny, 2001
%
% Syntax: KLD = mvnKLD(muQ,SigmaQ,muP,SigmaP)
%
% Inputs:
%   muQ - The mean of the Q distribution
%   SigmaQ - The covariance matrix of the Q distribution
%   muP - The mean of the P distribution
%   SigmaP - The covariance matrix of the P distribution
%
% Outputs:
%   KLD - The KLD for the Normal distributions







muQ = muQ(:);
muP = muP(:);

KLD = 1/2 * (log(det(SigmaP)) - log(det(SigmaQ))) + ...
    1/2*trace(inv(SigmaP)*SigmaQ) + ...
    1/2*(muQ-muP)'*inv(SigmaP)*(muQ-muP) +...
    -length(muP)/2;
