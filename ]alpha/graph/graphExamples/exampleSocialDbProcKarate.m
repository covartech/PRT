%% Example social DB

clear all;
close all;
clear classes
clc;

baseDir = prtGraphDataDir;
gmlFile = 'karate.gml';
file = fullfile(baseDir,gmlFile);

[sparseGraph,names] = prtUtilReadGml(file);
graph = prtDataTypeGraph(sparseGraph,names);

%%
close all;
plot(graph);

%%
graph.explore;
