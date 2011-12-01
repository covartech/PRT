function varargout = prtUtilListPreProc
% prtUtilListPreProc - List all prtPreProc* files.
% 
% See also: prtPreProc, prtPreProcClass, prtPreProcHistEq, prtPreProcLda,
% prtPreProcLogDisc, prtPreProcMinMaxRows, prtPreProcPca, prtPreProcPls,
% prtPreProcZeroMeanColumns, prtPreProcZeroMeanRows, prtPreProcZmuv
%

g = prtUtilSubDir(fullfile(prtRoot,'preproc'),'*.m');

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
