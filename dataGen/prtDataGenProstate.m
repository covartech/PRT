function DataSet = prtDataGenProstate(prostateFile)
%   prtDataGenIris Read in data from the UCI PROSTATE data file
%
%   DataSet = prtDataGenIris reads in the data from the classic Prostate.UCI
%   file used in many pattern recognition texts and papers. For more
%   information about this data, see the following URL:
%
%   http://lib.stat.cmu.edu/S/Harrell/data/descriptions/prostate.html
%
%   Example:
% 
%   ds = prtDataGenProstate;
%   ds.plot;
%    
%   See also: prtDataSetClass, prtDataGenBiModal, prtDataGenIris,
%   prtDataGenMary, prtDataGenNoisySinc, prtDataGenOldFaithful,
%   prtDataGenSpiral, prtDataGenUnimodal, prtDataGenUnimodal, prtDataGenXor

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


%   prtDataGenProstate Read in data from a CSV formatted PROSTATE-like data file
%
% DataSet = prtDataGenProstate; Read in the data from the Prostate.UCI file
% available with the prt and on the web.
%
% DataSet = prtDataGenProstate(ProstateFile);  Read in the CSV formatted,
% file matching the specifications of ProstateFile
% (see: ProstateFile in <<prtRoot>>\data\)
%
% http://lib.stat.cmu.edu/S/Harrell/data/descriptions/prostate.html

if nargin == 0
    prostateFile = fullfile(prtRoot,'dataGen','dataStorage','prostate','prostate.csv');
end

fid = fopen(prostateFile,'r');
%patno,stage,rx,dtime,status,age,wt,pf,hx,sbp,dbp,ekg,hg,sz,sg,ap,bm,sdate
topLineSpec = repmat('%s ',1,18);
%1,3,0.2 mg estrogen,72,alive,75,76,normal activity,0,15,9,heart strain,13.79882813,2,8,0.299987793,0,2778
dataSpec = '%d %d %s %d %s %d %d %s %d %d %d %s %f %d %d %f %d %f';

varNames = textscan(fid,topLineSpec,1,'whitespace',' \b\t""','Delimiter',',');
cellData = textscan(fid,dataSpec,'whitespace',' \b\t"','Delimiter',',');
fclose(fid);

%handle the data
cellData{3} = prostateFixEstrogen(cellData{3});
cellData{3} = cat(1,cellData{3}{:});
[cellData{5},col5Labels] = prtUtilStringsToClassNumbers(cellData{5});
[cellData{8},col8Labels] = prtUtilStringsToClassNumbers(cellData{8});
[cellData{12},col12Labels] = prtUtilStringsToClassNumbers(cellData{12});

targetInd = 5;
featureInd = setdiff(2:length(cellData),targetInd);
Y = cellData{targetInd};
X = double(cat(2,cellData{featureInd}));  %drop the counting var, and the Y
colNames = varNames(featureInd);

varNames = cellfun(@(c)c{1},varNames,'uniformoutput',false);
colNames = varNames(featureInd);

userData = struct('column6IntegerExplanations',{col8Labels},...
    'column10IntegerExplanations',{col12Labels});

DataSet = prtDataSetClass(X,Y,'name','UCI Prostate Data');
DataSet = DataSet.setFeatureNames(colNames);
DataSet.userData = userData;
DataSet = DataSet.setClassNames(col5Labels);

function cellData = prostateFixEstrogen(cellData)
for i = 1:length(cellData)
    switch lower(cellData{i})
        case 'placebo'
            cellData{i} = 0;
        otherwise
            cellData{i} = str2double(cellData{i}(1:3));
    end
end
