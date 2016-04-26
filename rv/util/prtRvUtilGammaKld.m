function KLD = prtRvUtilGammaKld(bQ,cQ,bP,cP)
% GAMMAKLD  Kulback Liebler Divergence between two gamma densities
%       KLD(Q||P)
%   Here are gamma distributions are parameterized by b the shape parameter
%   and c the inverse scale parameter. The mean is then given by b/c and
%   the variances is b/(c^2)
%
%   KL-Divergence of Normal, Gamma, Dirichlet and Wishart densities
%      Penny, 2001
%
% Syntax: KLD = prtRvUtilGammaKld(bQ,cQ,bP,cP)
%
% Inputs:
%   bQ - shape parameter of distribution Q
%   cQ - inverse scale parameter of distribution Q
%   bP - shape parameter of distribution P
%   cP - inverse scale parameter of distribution P
%
% Outputs:
%   KLD - The KLD for the gamma distributions







KLD = gammaln(bP)-gammaln(bQ) + bP*log(cQ) - bP*log(cP) + (bQ-bP)*psi(bQ) + bQ*(cP-cQ)/cQ;
