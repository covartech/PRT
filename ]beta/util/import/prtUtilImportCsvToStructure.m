function [structure,nonNumericFields,fieldNames] = prtUtilImportCsvToStructure(csvFile)
%structure = prtUtilImportCsvToStructure(csvFile)
% Translate a well-formed CSV file into a structure.
%
%   Well-formed means that the first row has values that indicate column
%   names, and that are valid MATLAB field names, and remaining rows are
%   string or numeric values, where each column has a consistent type

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


excelFiles = {'.xlsx','.xls'};
[~,~,e] = fileparts(csvFile);
if any(strcmpi(e,excelFiles));
    [numeric,txt,csvCell] = xlsread(csvFile);
else
    [numeric,txt,csvCell] = prtUtilImportCsvXlsRead(csvFile);
end

[structure,nonNumericFields,fieldNames] = prtUtilImportCsvCellToStructure(csvCell);
