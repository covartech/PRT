function varargout = prtUtilListRegress
% prtUtilListRegress - List all prtRegress* files.
% 
% See also: prtRegress, prtRegressLslr, prtRegressRvm,
% prtRegressRvmSequential


g = prtUtilSubDir(fullfile(prtRoot,'regress'),'*.m');

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
