function [gramm,nBasis] = prtKernelPolynomial(x1,x2,p)

gramm = (x1*x2').^p;
nBasis = size(gramm,2);