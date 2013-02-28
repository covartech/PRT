function prtUtilPrintAvailableActions(ActionStruct,layer)
% Internal
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


if nargin < 1 || isempty(ActionStruct)
    ActionStruct = prtUtilAvailableActions;
end
if nargin < 2 || isempty(layer)
    layer = 0;
end

for iName = 1:length(ActionStruct)
    fprintf(cat(2,repmat('\t',1,layer),'%s\n'),ActionStruct(iName).name);
    if ~isempty(ActionStruct(iName).Children)
        for iChild = 1:length(ActionStruct(iName).Children);
            prtUtilPrintAvailableActions(ActionStruct(iName).Children(iChild),layer+1)
        end
    end
end
