% 
% See also: prtFeatSel, prtFeatSelExhaustive, prtFeatSelSfs,
% prtFeatSelStatic
%

g = subDir(fullfile(prtRoot,'featsel'),'*.m');

fprintf('See also: ');
for i = 1:length(g); 
    [p,f] = fileparts(g{i}); 
    fprintf('%s, ',f);
end; 
fprintf('\b\b');
fprintf('\n');
