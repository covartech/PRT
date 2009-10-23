function [gramm,nBasis] = prtKernelRbfNdimensionScale(x1,x2,sigma)
%[gramm,nBasis] = prtKernelRbfNdimensionScale(x1,x2,sigma)
%   sigma <- sqrt(sigma.^2*nDim)

nDim = size(x1,2);
%sqrt(sigma.^2*nDim);
[gramm,nBasis] = prtKernelRbf(x1,x2,sqrt(sigma.^2*nDim));