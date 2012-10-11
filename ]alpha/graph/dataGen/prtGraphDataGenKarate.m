function graph = prtGraphDataGenKarate
% graph = prtGraphDataGenKarate
%   

baseDir = prtGraphDataDir;
gmlFile = 'karate.gml';
file = fullfile(baseDir,gmlFile);

[sparseGraph,names] = prtUtilReadGml(file);
graph = prtDataTypeGraph(sparseGraph,names);