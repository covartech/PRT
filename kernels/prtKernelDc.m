function [gramm,nBasis] = prtKernelDc(x1,x2)

gramm = ones(size(x1,1),1);
nBasis = size(gramm,2);