function KLD = prtRvUtilWishartKld(q,Q,p,P)
% WISHARTKLD  Kulback Liebler Divergence between two Wishart densities
%       KLD(Q||P)
%
%   KL-Divergence of Normal, Gamma, Dirichlet and Wishart densities
%      Penny, 2001
%
% Syntax: KLD = wishartKLD(aQ,BQ,aP,BP)
%
% Inputs:
%   aQ - The strength parameter of the Q distribution
%   BQ - The mean parameter of the Q distribution
%   aP - The strength parameter of the P distribution
%   BP - The mean parameter of the P distribution
%
% Outputs:
%   KLD - The KLD for the Wishart distributions





d = size(Q,1);

dims = 1:d;

KLD = p/2*(prtUtilLogDet(Q) - prtUtilLogDet(P)) + q/2*(trace(inv(Q)*P) - d) + prtRvUtilGeneralizedGammaLn(p/2,d) - prtRvUtilGeneralizedGammaLn(q/2,d) + (q/2 - p/2)*sum(psi((q+1-dims)/2));

if KLD < 0
    KLD = 0; % This only happens in the range of 0;
end
