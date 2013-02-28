function [strCell,ind] = prtUtilKeepStrCell(strCell,str)
%[strCell,ind] = prtUtilKeepStrCell(strCell,str)
%
%   Returns a cell array of strings containing the character arrays in strCell
%   which contain the string str.  ind is the locations of the cells kept.
%
%   see also: removestrcell
%
% xxx Need Help xxx

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
