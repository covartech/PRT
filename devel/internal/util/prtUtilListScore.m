function varargout = prtUtilListScore
% prtUtilListScore - List all prtScore* files.
% 
% See also: prtScoreAuc, prtScoreConfusionMatrix, prtScoreCost,
% prtScorePercentCorrect, prtScoreRmse, prtScoreRoc, prtScoreRocNfa

g = prtUtilSubDir(fullfile(prtRoot,'score'),'*.m');

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
