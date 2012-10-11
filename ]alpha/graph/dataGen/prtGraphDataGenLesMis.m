function graph = prtGraphDataGenLesMis
% graph = prtGraphDataGenSlashdot

baseDir = prtGraphDataDir;
gmlFile = 'lesmis.gml';
file = fullfile(baseDir,gmlFile);

[sparseGraph,names] = prtUtilReadGml(file);
graph = prtDataTypeGraph(sparseGraph,names);
