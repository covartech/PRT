function graph = prtGraphDataGenSlashdot
% graph = prtGraphDataGenSlashdot

[baseDir,bigDataDir] = prtGraphDataDir;
gmlFile = fullfile(bigDataDir,'slashdotDatabase.mat');

if ~exist(gmlFile,'file')
    error('Could not find the bigData graph file %s; you can download it from here: %s',gmlFile,prtGraphDataUrl);
end
load(gmlFile,'slashdotGraph','slashdotNames');

graph = prtDataTypeGraph(slashdotGraph,slashdotNames);
