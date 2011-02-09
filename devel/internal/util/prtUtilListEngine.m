% 
% See also: prtDataSetBase, prtDataSetClass, prtDataSetRegress,
% prtDataSetStandard, prtNewClass, prtNewCluster, prtNewKernel,
% prtNewOutlierRemoval, prtNewPreProc, prtNewRegress, prtAction,
% prtAlgorithm
%

g = subDir(fullfile(prtRoot,'engine'),'*.m');

fprintf('See also: ');
for i = 1:length(g); 
    [p,f] = fileparts(g{i}); 
    fprintf('%s, ',f);
end; 
fprintf('\b\b');
fprintf('\n');
