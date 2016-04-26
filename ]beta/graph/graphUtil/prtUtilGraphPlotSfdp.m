function pos = prtUtilGraphPlotSfdp(graph)
% pos = prtUtilGraphPlotSfdp(graph)







fileIn = fullfile(tempdir,'_tempIn.dot');
fileOut = fullfile(tempdir,'_tempOut.dot');
prtPlotUtilGraphVizWriteDot(graph, fileIn);
cmd = sprintf('sfdp -Tdot -o%s %s',fileOut,fileIn);
system(cmd);
FileStruct = prtPlotUtilGraphVizReadDot(fileOut,'extractEdges',false);

nodes = FileStruct.Nodes;
pos = cat(1,nodes.pos);
