% 
% See also: prtDistanceChebychev, prtDistanceCityBlock, prtDistanceCustom,
% prtDistanceEarthMover, prtDistanceEuclidean, prtDistanceLNorm,
% prtDistanceMahalanobis, prtDistanceSquare
% 

g = subDir(fullfile(prtRoot,'distance'),'*.m');

fprintf('See also: ');
for i = 1:length(g); 
    [p,f] = fileparts(g{i}); 
    fprintf('%s, ',f);
end; 
fprintf('\b\b');
fprintf('\n');
