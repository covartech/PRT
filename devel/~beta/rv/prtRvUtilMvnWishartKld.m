function [KL, meanKL, covKL] = prtRvUtilMvnWishartKld(qBeta,qNu,qMu,qSigma,pBeta,pNu,pMu,pSigma)

D = length(qMu);
d = qMu(:)-pMu(:);
meanKL = 1/2*D*(pBeta./qBeta - log(pBeta./qBeta) - 1) ...
       + 1/2*qBeta* sum(sum(inv(qSigma).*(pBeta*(d*d')),1),2);
 
covKL = prtRvUtilWishartKld(qNu,qSigma,pNu,pSigma); 

KL = meanKL + covKL;