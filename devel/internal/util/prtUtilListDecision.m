% 
% See also: prtDecision, prtDecisionBinary, prtDecisionBinaryMinPe,
% prtDecisionBinarySpecifiedPd, prtDecisionBinarySpecifiedPf,
% prtDecisionMap
% 

g = subDir(fullfile(prtRoot,'decision'),'*.m');

fprintf('See also: ');
for i = 1:length(g); 
    [p,f] = fileparts(g{i}); 
    fprintf('%s, ',f);
end; 
fprintf('\b\b');
fprintf('\n');
