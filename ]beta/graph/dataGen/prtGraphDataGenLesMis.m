function graph = prtGraphDataGenLesMis
% graph = prtGraphDataGenSlashdot
%   Read lesmis.gml
%
% From the README:
% 
% The file lesmis.gml contains the weighted network of coappearances of
% characters in Victor Hugo's novel "Les Miserables".  Nodes represent
% characters as indicated by the labels and edges connect any pair of
% characters that appear in the same chapter of the book.  The values on
% the edges are the number of such coappearances.  The data on
% coappearances were taken from D. E. Knuth, The Stanford GraphBase: A
% Platform for Combinatorial Computing, Addison-Wesley, Reading, MA (1993).








baseDir = prtGraphDataDir;
gmlFile = 'lesmis.gml';
file = fullfile(baseDir,gmlFile);

[sparseGraph,names] = prtUtilReadGml(file);
graph = prtDataTypeGraph(sparseGraph,names);
