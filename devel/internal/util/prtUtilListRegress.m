% 
% See also: prtRegress, prtRegressLslr, prtRegressRvm,
% prtRegressRvmSequential


g = subDir(fullfile(prtRoot,'regress'),'*.m');

fprintf('See also: ');
for i = 1:length(g); 
    [p,f] = fileparts(g{i}); 
    fprintf('%s, ',f);
end; 
fprintf('\b\b');
fprintf('\n');
