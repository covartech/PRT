function seq = prtUtilTopographicalSort(adj)
% xxx Need Help xxx
% [seq] = toposort(adj)  A Topological ordering of nodes in a directed graph
% INPUT:  adj  -  adjacency matrix
% OUTPUT: seq  -  a topological ordered sequence of nodes
%                 or an empty matrix if graph contains cycles

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