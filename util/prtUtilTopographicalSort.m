function seq = prtUtilTopographicalSort(adj)
% xxx Need Help xxx
% [seq] = toposort(adj)  A Topological ordering of nodes in a directed graph
% INPUT:  adj  -  adjacency matrix
% OUTPUT: seq  -  a topological ordered sequence of nodes
%                 or an empty matrix if graph contains cycles

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


N = size(adj);
indeg = sum(adj,1);
outdeg = sum(adj,2);
seq = [];
for i = 1:N,
    idx = find(indeg==0);    % Find nodes with indegree 0
    if isempty(idx),   % If can't find than graph contains a cycle
        seq = [];
        break;
    end;
    [dummy idx2] = max(outdeg(idx)); % Remove the node with the max number of connections
    indx = idx(idx2);
    seq = [seq, indx];
    indeg(indx) = -1;
    idx = find(adj(indx,:));
    indeg(idx) = indeg(idx)-1;
end 
