function [structure,nonNumericFields] = prtUtilImportCsvToStructure(csvFile)
%structure = prtUtilImportCsvToStructure(csvFile)
% Translate a well-formed CSV file into a structure.
%
%   Well-formed means that the first row has values that indicate column
%   names, and that are valid MATLAB field names, and remaining rows are
%   string or numeric values, where each column has a consistent type

excelFiles = {'.xlsx','.xls'};
[~,~,e] = fileparts(csvFile);
if any(strcmpi(e,excelFiles));
    [numeric,txt,csvCell] = xlsread(csvFile);
else
    [numeric,txt,csvCell] = prtUtilImportCsvXlsRead(csvFile);
end

[structure,nonNumericFields] = prtUtilImportCsvCellToStructure(csvCell);