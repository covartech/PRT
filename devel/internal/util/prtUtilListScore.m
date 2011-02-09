% 
% See also: prtScoreAuc, prtScoreConfusionMatrix, prtScoreCost,
% prtScorePercentCorrect, prtScoreRmse, prtScoreRoc, prtScoreRocNfa
%

g = subDir(fullfile(prtRoot,'score'),'*.m');

fprintf('See also: ');
for i = 1:length(g); 
    [p,f] = fileparts(g{i}); 
    fprintf('%s, ',f);
end; 
fprintf('\b\b');
fprintf('\n');
