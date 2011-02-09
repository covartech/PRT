% 
% See also: prtEvalAuc, prtEvalMinCost, prtEvalPdAtPf,
% prtEvalPercentCorrect, prtEvalPfAtPd
%

g = subDir(fullfile(prtRoot,'eval'),'*.m');

fprintf('See also: ');
for i = 1:length(g); 
    [p,f] = fileparts(g{i}); 
    fprintf('%s, ',f);
end; 
fprintf('\b\b');
fprintf('\n');
