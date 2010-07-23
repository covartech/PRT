function DataSet = prtDataProstate(prostateFile)
%   prtReadProstate Read in data from a CSV formatted PROSTATE-like data file
%
% DataSet = prtReadProstate; Read in the data from the Prostate.UCI file
% available with the prt and on the web.
%
% DataSet = prtReadProstate(ProstateFile);  Read in the CSV formatted,
% file matching the specifications of ProstateFile
% (see: ProstateFile in <<prtRoot>>\data\)
%

if nargin == 0
    prostateFile = fullfile(prtRoot,'data','prostate','prostate.csv');
end

fid = fopen(prostateFile,'r');
varNames = textscan(fid,'%s %s %s %s %s %s %s %s %s %s',1,'whitespace',' \b\t""','Delimiter',',');
cellData = textscan(fid,'%f %f %f %f %f %f %f %f %f %f','whitespace',' \b\t"','Delimiter',',');
fclose(fid);

for i = 1:length(varNames)
    varNames{i} = strrep(varNames{i},'"','');
end
Y = cellData{end};
X = cat(2,cellData{2:end-1});  %drop the counting var, and the Y
varNames = varNames(2:end-1);
varNames = cellfun(@(c)c{1},varNames,'uniformoutput',false);

DataSet = prtDataSetClass(X,Y,'name','UCI Prostate Data');
DataSet = DataSet.setFeatureNames(varNames);