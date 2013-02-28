function [numeric,txt,raw] = prtUtilImportCsvXlsRead(csvFile)
%[numeric,txt,raw] = prtUtilImportCsvXlsRead(csvFile)
%   csvRead that acts more like xlsread.  Right now the only valid output
%   argument is "raw", but we can make numeric and txt work too; they're
%   included so calling syntax is like xlsread
%
%   Note, this function assumes that the first row of the CSV file has
%   header information, and all the remaining rows have data.
%   

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
