% 
% See also: prtKernel, prtKernelDc, prtKernelDirect,
% prtKernelHyperbolicTangent, prtKernelPolynomial, prtKernelRbf,
% prtKernelRbfNdimensionScale, prtKernelSet

g = subDir(fullfile(prtRoot,'kernel'),'*.m');

fprintf('See also: ');
for i = 1:length(g); 
    [p,f] = fileparts(g{i}); 
    fprintf('%s, ',f);
end; 
fprintf('\b\b');
fprintf('\n');
