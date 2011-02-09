function varargout = prtUtilListEngine
% prtUtilListEngine - List all PRT Engine files.
% 
% See also: prtDataSetBase, prtDataSetClass, prtDataSetRegress,
% prtDataSetStandard, prtNewClass, prtNewCluster, prtNewKernel,
% prtNewOutlierRemoval, prtNewPreProc, prtNewRegress, prtAction,
% prtAlgorithm
%

g = subDir(fullfile(prtRoot,'engine'),'*.m');

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
