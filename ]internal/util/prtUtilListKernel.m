function varargout = prtUtilListKernel
% prtUtilListKernel - List all prtKernel* files.
% 
% See also: prtKernel, prtKernelDc, prtKernelDirect,
% prtKernelHyperbolicTangent, prtKernelPolynomial, prtKernelRbf,
% prtKernelRbfNdimensionScale, prtKernelSet

g = prtUtilSubDir(fullfile(prtRoot,'kernels'),'*.m');

if nargout == 0
    fprintf('See also: ');
    for i = 1:length(g);
        [p,f] = fileparts(g{i});
        fprintf('%s, ',f);
    end;
    fprintf('\b\b');
    fprintf('\n');
else
    varargout = {g};
end
