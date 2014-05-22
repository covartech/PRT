function cVal = prtUtilFindPrtActionsAndConvertToStructures(cVal)

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


if isa(cVal,'prtAction')
    cVal = cVal.toStructure;
elseif iscell(cVal)
    % Current element is a cell that may contain prtActions
    for iCell = 1:numel(cVal)
        cVal{iCell} = prtUtilFindPrtActionsAndConvertToStructures(cVal{iCell});
    end
elseif isstruct(cVal)
    subFieldNames = fieldnames(cVal);
    for iField = 1:length(subFieldNames)
        cVal.(subFieldNames{iField}) =  prtUtilFindPrtActionsAndConvertToStructures(cVal.(subFieldNames{iField}));
    end
end
