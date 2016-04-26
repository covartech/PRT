%% Example Comic Book social DB







clear all;
close all;
clear classes
clc;

graph = prtGraphDataGenComicBookDatabase;
graph = graph.retainByDegree(2000);

graph.explore;
