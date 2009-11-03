function [gramm,nBasis] = prtKernelLaplacian(x1,x2,c)
%   prtKernelRbf RBF Kernel function.
%
% Syntax: [gramm,nBasis] = rbfKernel(x1,x2,c);
%
% Sample Usage:
%

%%this is xuejun's technique to speed up this distance calc...

[n1, d] = size(x1);
[n2, nin] = size(x2);
if d ~= nin
    error('size(x1,2) must equal size(x2,2)');
end

dist2 = repmat(sum((x1.^2)', 1), [n2 1])' + ...
    repmat(sum((x2.^2)',1), [n1 1]) - ...
    2*x1*(x2');

%gramm = exp(-dist2/(c.^2));
gramm = exp(-bsxfun(@rdivide,sqrt(dist2),2*c.^2));

nBasis = size(gramm,2);