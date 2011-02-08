function [KL, meanKL, covKL] = prtRvUtilMvnWishartKld(qBeta,qNu,qMu,qSigma,pBeta,pNu,pMu,pSigma)

% meanCovQ = qSigma/qNu/qBeta;
% meanCovP = pSigma/pNu/pBeta;
% meanKL = mvnKLD(qMu,meanCovQ, pMu,meanCovP);
% This doesn't consider the uncertainty (qBeta)
% It is wrong
% Instead you have to do this.

D = length(qMu);
d = qMu(:)-pMu(:);
meanKL = 1/2*D*(pBeta./qBeta - log(pBeta./qBeta) - 1) ...
       + 1/2*qBeta* sum(sum(inv(qSigma).*(pBeta*(d*d')),1),2);
 
covKL = prtRvUtilWishartKld(qNu,qSigma,pNu,pSigma); 

KL = meanKL + covKL;