function varargout = prtUtilListFeatSel
% prtUtilListFeatSel - List all prtFeatSel* files.
% 
% See also: prtFeatSel, prtFeatSelExhaustive, prtFeatSelSfs,
% prtFeatSelStatic
%

g = prtUtilSubDir(fullfile(prtRoot,'featsel'),'*.m');

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
