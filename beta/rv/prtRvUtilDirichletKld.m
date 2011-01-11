function KLD = prtRvUtilDirichletKld(lambdaQ,lambdaP)
% DIRICHLETKLD  Kulback Liebler Divergence between two dirichlet densities
%       KLD(Q||P)
%
%   KL-Divergence of Normal, Gamma, Dirichlet and Wishart densities
%      Penny, 2001
%
% Syntax: KLD = dirichletKLD(lambdaP, lambdaQ)
%
% Inputs:
%   lambdaQ - The vector of parameters for the Q distribution  
%   lambdaP - The vector of parameters for the P distribution
%
% Outputs:
%   KLD - The KLD for the Dirichlet distributions

lambdaQ(lambdaQ == 0) = eps;
lambdaP(lambdaP == 0) = eps;
KLD = gammaln(sum(lambdaQ)) - gammaln(sum(lambdaP)) + sum((lambdaQ - lambdaP).*(psi(lambdaQ) - psi(sum(lambdaQ)))) + sum(gammaln(lambdaP) - gammaln(lambdaQ));