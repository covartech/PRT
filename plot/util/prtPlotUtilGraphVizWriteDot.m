function prtPlotUtilGraphVizWriteDot(adj, filename, nodeLabels)
% Internal function, 
% xxx Need Help xxx
% prtPlotUtilGraphVizWriteDot(adj, fileName) Writes a Graph Viz DOT file
%   This writes a specific DOT file for use with the PRT.
%   This is not a general purpose DOT file writer.








if nargin < 3 || isempty(nodeLabels)
    useNodeLabels = false;    
else
    useNodeLabels = true;
end

fid = fopen(filename, 'w');

C = onCleanup(@()fclose(fid)); % Even if we error

fprintf(fid, 'digraph G {\n');
fprintf(fid, 'center = 1;\n');
fprintf(fid, 'size=\"%d,%d\";\n', 10, 10);

%Can speed this up, too
nNodes = length(adj);
for node = 1:nNodes
    if useNodeLabels
        fprintf(fid, '%d [label="%s"];\n', node, nodeLabels{node});
    else
        fprintf(fid, '%d;\n', node);
    end
end

%Much faster than below.
[ii,jj] = find(adj);
inds = sub2ind(size(adj),ii,jj);
weights = full(adj(inds));
edgeStrings = sprintf('%d -> %d [weight=%d];\n',[ii,jj,weights(:)]');
fprintf(fid,'%s',edgeStrings);
fprintf(fid, '}'); 

%OnCleanup
%fclose(fid);

% for node1 = 1:nNodes
%     arcs = find(adj(node1,:));
%     
%     for node2 = arcs
%         fprintf(fid,'%d -> %d;\n',node1,node2);
%     end
% end
% fprintf(fid, '}'); 
%
% fclose(fid); % On Cleanup will take care of it.
