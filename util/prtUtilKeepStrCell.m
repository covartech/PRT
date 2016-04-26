function [strCell,ind] = prtUtilKeepStrCell(strCell,str)
%[strCell,ind] = prtUtilKeepStrCell(strCell,str)
%
%   Returns a cell array of strings containing the character arrays in strCell
%   which contain the string str.  ind is the locations of the cells kept.
%
%   see also: removestrcell
%
% xxx Need Help xxx








%edit 11/4/2005
%allow cellular str

if isa(str,'char')
    str = {str};
end

ind = [];

for j = 1:length(str)
    for i = 1:length(strCell)
        if ~isempty(strfind(lower(strCell{i}),lower(str{j})))
            ind = [ind,i];
        end
    end
end
ind = unique(ind);
strCell = {strCell{ind}};
