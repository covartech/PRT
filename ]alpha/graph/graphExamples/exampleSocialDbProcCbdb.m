%% Example social DB

clear all;
close all;
clear classes
clc;

[baseDir,bigDataDir] = prtGraphDataDir;
gmlFile = fullfile(bigDataDir,'cbdbDatabase.mat');

if ~exist(gmlFile,'file')
    error('Could not find the bigData graph file %s; you can download it from here: %s',gmlFile,prtGraphDataUrl);
end
load(gmlFile,cbdbGraph,cbdbCharacterNames);

graph = prtDataTypeGraph(cbdbGraph,cbdbCharacterNames);
graph = graph.retainByDegree(2000);

%%
graph = graph.optimizePlotLocations;

%%
graph.explore;
