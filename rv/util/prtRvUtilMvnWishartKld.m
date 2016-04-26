function [KL, meanKL, covKL] = prtRvUtilMvnWishartKld(qBeta,qNu,qMu,qSigma,pBeta,pNu,pMu,pSigma)







D = length(qMu);
d = qMu(:)-pMu(:);

% Several different ways to calculate the last term. The last method is the
% best computationally and for accuracy with the inverse.

% meanKL = 1/2*D*(qBeta./pBeta - log(pBeta./qBeta) - 1) ...
%        + 1/2*qNu* sum(sum(inv(qSigma).*(pBeta*(d*d')),1),2);

% meanKL = 1/2*D*(qBeta./pBeta + log(pBeta./qBeta) - 1) ...
%         + 1/2*d'*(inv(qSigma/qNu)*pBeta)*d;

T = chol(qSigma/qNu);
term3 = sum((d(:)'/T).^2,2)*pBeta;

meanKL = 1/2*D*(qBeta./pBeta + log(pBeta./qBeta) - 1) + 1/2*term3;

covKL = prtRvUtilWishartKld(qNu,qSigma,pNu,pSigma); 

KL = meanKL + covKL;
