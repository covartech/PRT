function prtPlotUtilGraphVizWriteDot(adj, filename, nodeLabels)
% Internal function, 
% xxx Need Help xxx
% prtPlotUtilGraphVizWriteDot(adj, fileName) Writes a Graph Viz DOT file
%   This writes a specific DOT file for use with the PRT.
%   This is not a general purpose DOT file writer.

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.



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
