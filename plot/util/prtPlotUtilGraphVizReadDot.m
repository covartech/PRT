function FileStruct = prtPlotUtilGraphVizReadDot(filename,varargin)
% Internal function, 
% xxx Need Help xxx
% prtPlotUtilGraphVizReadDot - Reads  GraphViz Dot file
%   Not all aspects of the DOT file format are supported.
%
%   FileStruct = prtPlotUtilGraphVizReadDot(filename)

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


p = inputParser;
p.addParamValue('extractEdges',true);
p.parse(varargin{:});
inputs = p.Results;

fid = fopen(filename);
fileStrCell = textscan(fid,'%s','Delimiter',';','commentstyle','c');
fileStrCell = fileStrCell{1};
fclose(fid);

FileStruct.GraphInfo = struct();
FileStruct.NodeInfo = struct();
FileStruct.Nodes = struct();
FileStruct.Edges = struct();

cEdge = 0;
cNode = 0;

skipNextLine = false;
for iLine = 1:length(fileStrCell)
    if skipNextLine
        skipNextLine = false;
        continue
    end
    
    % Read last string to check for multi-line definitions
    if strcmpi(fileStrCell{iLine}(end),'\')
        % We have a multilinestr
        skipNextLine = true;
        if iLine == length(fileStrCell)
            error('prt:prtPlotUtilGraphVizReadDot:badFile','Invalid DOT file encountered. prtPlotUtilGraphVizReadDot() is a very limited DOT file reader. Not all aspects of the DOT file spec are supported.');
        end
        fileStrCell{iLine} = cat(2,fileStrCell{iLine}(1:end-1),fileStrCell{iLine+1});
    else
        skipNextLine = false;
    end
    % Read first string which indicates the type of line
    lineFirstStr = textscan(fileStrCell{iLine},'%s');
    lineFirstStr = lineFirstStr{1}{1};  
    
    switch lower(lineFirstStr)
        case 'digraph'
            % Nothing to do.
            % Skip this line
            continue;
        case '}'
            % End of digraph line
            % Skip this line
            continue;
        case 'graph'
            % Info about the graph
            GraphInfoLine = regexp(fileStrCell{iLine},'(?<field>\w+)=(?<value>\w+)','names');

            fields = {GraphInfoLine.field};
            values = {GraphInfoLine.value};
            for iVal = 1:length(fields)
                FileStruct.GraphInfo.(fields{iVal}) = values{iVal};
            end
            continue;
        case 'node'
            % Info about all of the nodes
            
            NodeInfoLine = regexp(fileStrCell{iLine},'(?<field>\w+)=(?<value>\w+)','names');

            fields = {NodeInfoLine.field};
            values = {NodeInfoLine.value};
            for iVal = 1:length(fields)
                 FileStruct.NodeInfo.(fields{iVal}) = values{iVal};
            end
            continue;
    end
    
    % If we got here we assume that the line starts with a node name
    % We check if the line contains '->' or '--' to indicate if it is an edge node
    
    isEdgeDirected = ~isempty(strfind(fileStrCell{iLine},'->'));
    isEdgeNonDirected = ~isempty(strfind(fileStrCell{iLine},'--'));
    isNode = ~isEdgeDirected && ~isEdgeNonDirected;
    
    if isNode
        cNode = cNode + 1;
        FileStruct.Nodes(cNode).id = lineFirstStr;
        
        NodeInfoLineStrings = regexp(fileStrCell{iLine},'(?<field>\w+)=(?<value>\w+)','names');
        fields = {NodeInfoLineStrings.field};
        values = {NodeInfoLineStrings.value};
        for iVal = 1:length(fields)
            FileStruct.Nodes(cNode).(fields{iVal}) = values{iVal};
        end
        
        NodeInfoLineNumbers = regexp(fileStrCell{iLine},'(?<field>\w+)="(?<value>[\w,.-+]+)"','names');
        fields = {NodeInfoLineNumbers.field};
        values = {NodeInfoLineNumbers.value};
        for iVal = 1:length(fields)
            FileStruct.Nodes(cNode).(fields{iVal}) = str2num(values{iVal}); %#ok<ST2NM>
        end
        
    elseif isEdgeDirected || isEdgeNonDirected
        if ~inputs.extractEdges
            return; %don't extract edges(!); this assumes edges come after everything
        end
        
        cEdge = cEdge + 1;
        
        EdgeInfoNames = regexp(fileStrCell{iLine},'(?<startName>\w+)\s*->\s*(?<stopName>\w+)','names');
        
        FileStruct.Edges(cEdge).startId = EdgeInfoNames.startName;
        FileStruct.Edges(cEdge).stopId = EdgeInfoNames.stopName;
        
        FileStruct.Edges(cEdge).startIndex = nan; % Fix this later
        FileStruct.Edges(cEdge).stopIndex = nan; % Fix this later
        
        FileStruct.Edges(cEdge).isDirected = isEdgeDirected;
        
        
        % At this point we only parse the pos
       
        EdgeInfoPos = regexp(fileStrCell{iLine},'pos="(?<posString>[\w\s,.-+]+)"','names');
        posString = EdgeInfoPos.posString;
        % We skip the first two characters to skip the e, (what is that?)
        posMat = reshape(str2num(posString(3:end)),2,[])'; %#ok<ST2NM>
       
        FileStruct.Edges(cEdge).pos = posMat;
        
    else
        error('DOT file parse error. prtPlotUtilGraphVizReadDot() is a very limited DOT file reader. Not all aspects of the DOT file spec are supported.')
    end
end

for iEdge = 1:length(FileStruct.Edges)
    FileStruct.Edges(iEdge).startIndex = find(arrayfun(@(S)strcmpi(S.id,FileStruct.Edges(iEdge).startId),FileStruct.Nodes),1,'first');
    FileStruct.Edges(iEdge).stopIndex = find(arrayfun(@(S)strcmpi(S.id,FileStruct.Edges(iEdge).stopId),FileStruct.Nodes),1,'first');
end
