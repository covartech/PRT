% 
% See also: prtCluster, prtClusterGmm, prtClusterKmeans

g = subDir(fullfile(prtRoot,'cluster'),'*.m');

fprintf('See also: ');
for i = 1:length(g); 
    [p,f] = fileparts(g{i}); 
    fprintf('%s, ',f);
end; 
fprintf('\b\b');
fprintf('\n');
