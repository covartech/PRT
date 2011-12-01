function varargout = prtUtilListDistance
% prtUtilListDistance - List all prtDistance* files.
% 
% See also: prtDistanceChebychev, prtDistanceCityBlock, prtDistanceCustom,
% prtDistanceEarthMover, prtDistanceEuclidean, prtDistanceLNorm,
% prtDistanceMahalanobis, prtDistanceSquare
% 

g = prtUtilSubDir(fullfile(prtRoot,'distance'),'*.m');

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
