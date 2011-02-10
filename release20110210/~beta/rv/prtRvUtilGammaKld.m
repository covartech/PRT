function KLD = prtRvUtilGammaKld(bQ,cQ,bP,cP)
% GAMMAKLD  Kulback Liebler Divergence between two gamma densities
%       KLD(Q||P)
%   Here are gamma distributions are parameterized by b the scale parameter
%   and c the shape parameter.
%       The mean is then given by b*c and the variances is c*b^2
%
%   KL-Divergence of Normal, Gamma, Dirichlet and Wishart densities
%      Penny, 2001
%
% Syntax: KLD = gammaKLD(bP,cP,bQ,cQ)
%
% Inputs:
%   bQ - scale parameter of distribution Q
%   cQ - shape parameter of distribution Q
%   bP - scale parameter of distribution P
%   cP - shape parameter of distribution P
%
% Outputs:
%   KLD - The KLD for the gamma distributions

% Here are two different versions the one from Penny and one I derived.
% DON'T LOOK AT WIKIPEDIA!!!! As of 20-Nov-2008 it is wrong.

KLD = (cQ - 1)*psi(cQ) - log(bQ) - cQ ...
    - gammaln(cQ) + gammaln(cP) + cP*log(bP) ...
    - (cP - 1)*(psi(cQ) + log(bQ)) + bQ*cQ / bP;

% This is the one I derived they are the same
% KLD2 = gammaln(cP) + cP*log(bP) - cQ*log(bQ) - gammaln(cQ) + (cQ - cP)*(psi(cQ) + log(bQ)) - cQ + cQ*bQ/bP;
% disp([KLD, KLD2])