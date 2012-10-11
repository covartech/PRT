%% Example social DB

clear all;
close all;
clear classes
clc;

[baseDir,bigDataDir] = prtGraphDataDir;
gmlFile = fullfile(bigDataDir,'slashdotDatabase.mat');

if ~exist(gmlFile,'file')
    error('Could not find the bigData graph file %s; you can download it from here: %s',gmlFile,prtGraphDataUrl);
end
load(gmlFile,'slashdotGraph','slashdotNames');

%%
graph = prtDataTypeGraph(slashdotGraph,slashdotNames);
graph = graph.retainByDegree(100);

%%
graph = graph.optimizePlotLocations;
plot(graph);

%% 
graph.explore;
