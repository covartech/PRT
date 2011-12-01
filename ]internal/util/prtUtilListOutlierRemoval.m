function varargout = prtUtilListOutlierRemoval
% prtUtilListOutlierRemoval - List all prtOutlierRemoval* files.
% 
% See also: prtOutlierRemoval, prtOutlierRemovalMissingData,
% prtOutlierRemovalNStd, prtOutlierRemovalNonFinite,

g = prtUtilSubDir(fullfile(prtRoot,'outlierremoval'),'*.m');

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
