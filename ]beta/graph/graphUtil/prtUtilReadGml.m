function [graph,nodeNames,nodeInfo] = prtUtilReadGml(file)
%[graph,names,etc] = prtUtilReadGml(file)
%  Read graph-spec files with .gml formating.







etc = [];

fid = fopen(file,'r');
directed = false;

nodeList = [];
edgeList = [];
while ~feof(fid)
    str = fgetl(fid);
    str = lower(str);
    
    if ~isempty(strfind(str,'directed'))
        temp = regexp(str,'directed (?<directed>[0-9]*)','names');
        directed = logical(str2double(temp.directed));
    end
    
    if ~isempty(strfind(str,']')) || ~isempty(strfind(str,'['))
        continue;
    else
        if ~isempty(strfind(str,'node'))
            newNode = readNode(fid);
            if isempty(nodeList)
                nodeList = newNode;
            else
                nodeList = cat(1,nodeList,newNode);
            end
        end
        if ~isempty(strfind(str,'edge'));
            newEdge = readEdge(fid);
            if isempty(edgeList)
                edgeList = newEdge;
            else
                edgeList = cat(1,edgeList,newEdge);
            end
        end
    end
end
fclose all;

nodeNames = {nodeList.id}';
nodeVals = cat(1,nodeList.val);
edgeVals = cat(1,edgeList.connection);

edgeIndices = zeros(size(edgeVals));
for i = 1:size(edgeVals,1)
    edgeIndices(i,:) = [find(edgeVals(i,1) == nodeVals),find(edgeVals(i,2) == nodeVals)];
end
    
graph = sparse(edgeIndices(:,1),edgeIndices(:,2),1,length(nodeVals),length(nodeVals));
if ~directed
    graph = graph + sparse(edgeIndices(:,2),edgeIndices(:,1),1,length(nodeVals),length(nodeVals));
end
nodeInfo = nodeList;

%
function newEdge = readEdge(fid)

newEdge = struct('connection',[]);
while true
    str = fgetl(fid);
    if ~isempty(strfind(str,'['))
        
    elseif ~isempty(strfind(str,']'))
        return;
    elseif ~isempty(strfind(str,'source'))
        temp1 = regexp(str,'source (?<nodeNumber>[0-9].*)','names');
        int1 = str2double(temp1.nodeNumber);
        
        str = fgetl(fid);
        temp2 = regexp(str,'target (?<nodeNumber>[0-9].*)','names');
        int2 = str2double(temp2.nodeNumber);
        newEdge.connection = [int1,int2];
    end
end
            
            
function newNode = readNode(fid)

newNode = struct('val',[],'id','');
while true
    str = fgetl(fid);
    str = strtrim(str);
    if ~isempty(strfind(str,'['))
        
    elseif ~isempty(strfind(str,']'))
        return;
    elseif ~isempty(regexp(str,'^id','once'))
        temp = regexp(str,'id (?<nodeNumber>[0-9].*)','names');
        int = str2double(temp.nodeNumber);
        newNode.val = int;
        newNode.id = sprintf('Node %d',int);
    elseif ~isempty(regexp(str,'^label','once'))
        temp = regexp(str,'label (?<nodeLabel>["A-Z].*)','names');
        temp.nodeLabel = strrep(temp.nodeLabel,'"','');
        newNode.id = temp.nodeLabel;
    elseif ~isempty(regexp(str,'^value','once'))
        temp = regexp(str,'value (?<value>.*)','names');
        newNode.value = str2double(temp.value);
    else
        warning('I didnt know what to do');
    end
end
