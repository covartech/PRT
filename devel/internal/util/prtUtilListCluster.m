function varargout = prtUtilListCluster
% prtUtilListCluster - List all prtCluster* files.
% 
% See also: prtCluster, prtClusterGmm, prtClusterKmeans

g = subDir(fullfile(prtRoot,'cluster'),'*.m');

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