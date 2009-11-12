function [gramm,nBasis,functionList] = prtKernelDc(x1,x2)
%[gramm,nBasis,functionList] = prtKernelDc(x1,x2)

functionList{1} = @(x)prtKernelDc(x1,1);

gramm = ones(size(x1,1),1);
nBasis = size(gramm,2);