function graph = prtGraphDataGenComicBookDatabase
% graph = prtGraphDataGenComicBookDatabase

[~,bigDataDir] = prtGraphDataDir;
gmlFile = fullfile(bigDataDir,'cbdbDatabase.mat');

if ~exist(gmlFile,'file')
    error('Could not find the bigData graph file %s; you can download it from here: %s',gmlFile,prtGraphDataUrl);
end
load(gmlFile,cbdbGraph,cbdbCharacterNames);

graph = prtDataTypeGraph(cbdbGraph,cbdbCharacterNames);
