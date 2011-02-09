% 
% See also: prtPreProc, prtPreProcClass, prtPreProcHistEq, prtPreProcLda,
% prtPreProcLogDisc, prtPreProcMinMaxRows, prtPreProcPca, prtPreProcPls,
% prtPreProcZeroMeanColumns, prtPreProcZeroMeanRows, prtPreProcZmuv
%

g = subDir(fullfile(prtRoot,'preproc'),'*.m');

fprintf('See also: ');
for i = 1:length(g); 
    [p,f] = fileparts(g{i}); 
    fprintf('%s, ',f);
end; 
fprintf('\b\b');
fprintf('\n');
