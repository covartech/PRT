function varargout = prtUtilListDecision
% prtUtilListDecision - List all prtDecision* files.
% 
% See also: prtDecision, prtDecisionBinary, prtDecisionBinaryMinPe,
% prtDecisionBinarySpecifiedPd, prtDecisionBinarySpecifiedPf,
% prtDecisionMap
% 

g = prtUtilSubDir(fullfile(prtRoot,'decision'),'*.m');

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
