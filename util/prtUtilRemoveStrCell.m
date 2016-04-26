function [strCell,IND,aIND] = prtUtilRemoveStrCell(strCell,str)
%[strCell,IND] = prtUtilRemoveStrCell(strCell,str);
%
%   Returns a cell array of strings NOT containing the character arrays in strCell
%   which contain the string str.  IND is the locations of the cells kept.
%
%   see also: prtUtilKeepStrCell
%
% xxx Need Help xxx








[garbage,aIND] = prtUtilKeepStrCell(strCell,str);

IND = setdiff(1:length(strCell),aIND);
strCell = {strCell{IND}};
