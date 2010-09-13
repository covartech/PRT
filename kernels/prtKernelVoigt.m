function [gramm,nBasis] = prtKernelVoigt(x1,x2,sigma,gamma)
%   prtKernelRbf RBF Kernel function.
%
% Syntax: [gramm,nBasis] = prtKernelVoigt(x1,x2,sigma,gamma);
%
% Sample Usage:
%

%error('This is the old kernel format.  we require new kerne;s');
N = 12; %number of terms in cef estimate in voigtProfile

[n1, d] = size(x1);
[n2, nin] = size(x2);
if d ~= nin
    error('size(x1,2) must equal size(x2,2)');
end
if d ~= 1
    error('prtKernelVoigt requires 1-dimensional observations');
end

d = bsxfun(@minus,x1,x2');

gramm = prtUtilVoigtProfile(d,sigma,gamma,N);
nBasis = size(gramm,2);