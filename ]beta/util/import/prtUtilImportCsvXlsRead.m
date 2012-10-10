function [numeric,txt,raw] = prtUtilImportCsvXlsRead(csvFile)
%[numeric,txt,raw] = prtUtilImportCsvXlsRead(csvFile)
%   csvRead that acts more like xlsread.  Right now the only valid output
%   argument is "raw", but we can make numeric and txt work too; they're
%   included so calling syntax is like xlsread
%
%   Note, this function assumes that the first row of the CSV file has
%   header information, and all the remaining rows have data.
%   

fid = fopen(csvFile,'r');

% Get first row and determine the number of columns
tline = fgetl(fid);
firstRow = textscan(tline,'%q','Delimiter',',');
nColumns = length(firstRow{1});

% Rewind the file pointer and read in the entire file
fseek(fid,0,-1);
raw = textscan(fid,'%q','Delimiter',',');
raw = reshape(raw{1},nColumns,[])';

fclose(fid);

% Find and convert numeric columns
for i = 1:size(raw,2)
    
    % Attempt to convert first row of data in this column to a number 
    if ~isnan(str2double(raw(2,i))) || strcmpi(raw(2,i),'nan') || isempty(raw{2,i})
        % Convert the entire column
        raw(2:end,i) = cellfun(@(c)str2double(c),raw(2:end,i),'uniformOutput',false);
    end
end

% These outputs are provided so that this function has the same calling
% syntax as xlsread()
numeric = nan;
txt = nan;
