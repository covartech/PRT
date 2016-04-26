function pathCell = prtUtilMatlabPath2StrCell(pathString)
%pathCell = prtUtilMatlabPath2StrCell(pathString)
% xxx Need Help xxx







if nargin == 0
    pathString = path;
end
pathCell = textscan(pathString,'%s','delimiter',';');
pathCell = pathCell{1};
