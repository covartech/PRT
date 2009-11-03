function [gramm,nBasis] = prtKernelVoigt(x1,x2,sigma,gamma)
%   prtKernelRbf RBF Kernel function.
%
% Syntax: [gramm,nBasis] = rbfKernel(x1,x2,c);
%
% Sample Usage:
%

N = 10; %number of terms in cef estimate in voigtProfile

[n1, d] = size(x1);
[n2, nin] = size(x2);
if d ~= nin
    error('size(x1,2) must equal size(x2,2)');
end
if d ~= 1
    error('prtKernelVoigt requires 1-dimensional observations');
end

d = bsxfun(@minus,x1,x2');

gramm = voigtProfile(d,sigma,gamma,N);
nBasis = size(gramm,2);